//
//  FaceService.swift
//  PersonRecognize
//
//  Owns the FaceKit recognizer: local encrypted template store, enrollment from the
//  saved training images, and sync of templates with Firebase.
//

import CryptoKit
import FaceKit
import Foundation
import Security
import UIKit

final class FaceService {
    static let shared = FaceService()

    private var loading: Task<FaceRecognizer, Error>?

    private init() {}

    /// The recognizer, created on first use (loading the model takes a moment).
    func recognizer() async throws -> FaceRecognizer {
        if loading == nil {
            loading = Task {
                let url = try FileManager.default
                    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("FaceKit/identities.bin")
                return try await FaceRecognizer(store: FileFaceStore(url: url, key: try Self.storeKey()))
            }
        }
        return try await loading!.value
    }

    /// Enrolls `name` from the images saved under the training dataset and uploads the templates.
    @discardableResult
    func enrollFromLocalImages(name: String) async throws -> Identity {
        let images = trainingDataset.getImage(label: name).compactMap { $0?.cgImage }
        let identity = try await recognizer().enroll(id: name, images: images)
        try await fb.uploadIdentity(identity)
        return identity
    }

    /// Replaces local templates with the server copy. Returns the number of identities.
    func syncFromServer() async throws -> Int {
        let identities = try await fb.loadIdentities()
        try await recognizer().replaceAll(with: identities)
        return identities.count
    }

    func identityCount() async -> Int {
        (try? await recognizer().identities.count) ?? 0
    }

    // MARK: Keychain

    /// AES key for the local template file, created once and kept in the Keychain.
    private static func storeKey() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "PersonRecognize.FaceKit",
            kSecAttrAccount as String: "identities",
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query.merging([kSecReturnData as String: true]) { $1 } as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let attributes = query.merging([
            kSecValueData as String: key.withUnsafeBytes { Data($0) },
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]) { $1 }
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        return key
    }
}
