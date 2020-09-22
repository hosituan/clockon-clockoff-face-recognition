////
////  Labels.swift
////  PersonRez
////
////  Created by Hồ Sĩ Tuấn on 06/09/2020.
////  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
////
//
//import Foundation
//
//func loadLabel() -> Dictionary<String,String> {
//    if let dictionary = NSMutableDictionary(contentsOf: labelUrl){
//        print("exist")
//        let userDict = dictionary as! Dictionary<String,String>
//        return userDict
//    }
//    else {
//        print("creating")
//        createLabelFolder()
//        return loadLabel()
//    }
//}
//
//func saveLabel(at: String, value: String) {
//    var userDict = loadLabel()
//    userDict[at] = value
//    print("saved label \(at):\(value)")
//    let dictionary = (userDict as NSDictionary).mutableCopy() as! NSMutableDictionary
//    dictionary.write(to: labelUrl, atomically: true)
//}
//
//func createLabelFolder() {
//    let count = 50
//
//    let dictionary = NSMutableDictionary(capacity: 0)
//
//
//    dictionary.write(to: labelUrl, atomically: true)
//
//    for i in 0...count {
//        let label = "user\(i)"
//        dictionary.setValue("", forKey: label)
//        dictionary.write(to: labelUrl, atomically: true)
//        createDirectory(at: documentDirectory.appendingPathComponent("train").appendingPathComponent(label))
//    }
//}
