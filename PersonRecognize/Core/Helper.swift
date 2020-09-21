//
//  Helper.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 30/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML

let applicationDocumentsDirectory: URL = {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}()

@discardableResult func copyIfNotExists(from: URL, to: URL) -> Bool {
    if !FileManager.default.fileExists(atPath: to.path) {
        do {
            try FileManager.default.copyItem(at: from, to: to)
            return true
        } catch {
            print("Error: \(error)")
        }
    }
    return false
}

func removeIfExists(at url: URL) {
    try? FileManager.default.removeItem(at: url)
}

func createDirectory(at url: URL) {
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
}

func contentsOfDirectory(at url: URL) -> [URL]? {
    try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
}

func removeAllData() {
    let url1 = applicationDocumentsDirectory.appendingPathComponent("train")
    let url2 = applicationDocumentsDirectory.appendingPathComponent("test")
    let url3 = applicationDocumentsDirectory.appendingPathComponent("label")
    
    try? FileManager.default.removeItem(at: url1)
    try? FileManager.default.removeItem(at: url2)
    try? FileManager.default.removeItem(at: url3)
}



func contentsOfDirectory(at url: URL, matching predicate: (URL) -> Bool) -> [URL] {
    contentsOfDirectory(at: url)?.filter(predicate) ?? []
}

extension UIViewController {
    func showDialog(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}



func manualCreate() {
    let dictionary = NSMutableDictionary(capacity: 0)
    
    dictionary.setValue("quyen", forKey: "user7")
    dictionary.write(to: labelUrl, atomically: true)
    dictionary.setValue("Anh Toan", forKey: "user6")
    dictionary.write(to: labelUrl, atomically: true)
}
