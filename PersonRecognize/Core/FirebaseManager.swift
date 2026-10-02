//
//  FirebaseManager.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 24/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import FaceKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Foundation

class FirebaseManager {
    init() {
        FirebaseApp.configure()
    }

    /// Firebase keys may not contain . # $ [ ] or /.
    static func key(_ value: String) -> String {
        String(value.map { ".#$[]/".contains($0) ? "_" : $0 })
    }

    // MARK: Face templates

    func uploadIdentity(_ identity: Identity) async throws {
        let json = String(decoding: try JSONEncoder().encode(identity), as: UTF8.self)
        try await Database.database().reference()
            .child(FACE_IDENTITIES).child(Self.key(identity.id))
            .setValue(["id": identity.id, "json": json])
    }

    func loadIdentities() async throws -> [Identity] {
        let snapshot = try await Database.database().reference().child(FACE_IDENTITIES).getData()
        guard let values = snapshot.value as? [String: Any] else { return [] }
        return values.values.compactMap { value in
            guard let json = (value as? [String: Any])?["json"] as? String else {
                print("Skipping malformed identity.")
                return nil
            }
            return try? JSONDecoder().decode(Identity.self, from: Data(json.utf8))
        }
    }

    // MARK: Log times

    func loadLogTimes(completionHandler: @escaping ([Users]) -> Void) {
        Database.database().reference().child(LOG_TIME).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            var attendList: [Users] = []
            for case let item as [String: Any] in (snapshot.value as? [String: Any])?.values.map({ $0 }) ?? [] {
                guard let name = item["name"] as? String,
                      let imgUrl = item["imageURL"] as? String,
                      let time = item["time"] as? String
                else {
                    print("Error at get log times.")
                    continue
                }
                attendList.append(Users(name: name, imageURL: imgUrl, time: time))
            }
            completionHandler(attendList.sorted(by: { $0.time > $1.time }))
        }) { (error) in
            print(error.localizedDescription)
            completionHandler([])
        }
    }

    /// Uploads the photo, then the log entry. The handler is called exactly once.
    func uploadLogTimes(user: User, completionHandler: @escaping (Error?) -> Void) {
        let key = Self.key("\(user.name) - \(user.time)")
        // Default bucket from GoogleService-Info.plist, so it always matches the configured project.
        let storageRef = Storage.storage().reference().child(key)
        guard let imageData = user.image.jpegData(compressionQuality: 0.8) else {
            completionHandler(CocoaError(.fileWriteUnknown))
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error {
                completionHandler(error)
                return
            }
            storageRef.downloadURL { url, error in
                guard let url else {
                    completionHandler(error ?? CocoaError(.fileReadUnknown))
                    return
                }
                let dict: [String: Any] = ["name": user.name, "imageURL": url.absoluteString, "time": user.time]
                Database.database().reference().child(LOG_TIME).child(key).updateChildValues(dict) { error, _ in
                    if error == nil { print("Uploaded log time.") }
                    completionHandler(error)
                }
            }
        }
    }

    // MARK: Users

    func loadUsers(completionHandler: @escaping ([String: Int]) -> Void) {
        Database.database().reference().child(USER_CHILD).queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? [String: Any] ?? [:]
            completionHandler(data.compactMapValues { $0 as? Int })
        }) { (error) in
            print(error.localizedDescription)
            completionHandler([:])
        }
    }

    func uploadUser(name: String, user_id: Int, completionHandler: @escaping () -> Void) {
        Database.database().reference().child(USER_CHILD).updateChildValues([Self.key(name): user_id]) { error, _ in
            if error == nil { print("update user.") }
            completionHandler()
        }
    }
}
