//
//  FirebaseManager.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 24/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class FirebaseManager {
    init() {
        FirebaseApp.configure()
    }
    
    func uploadAllVectors(vectors: [Vector], child: String, completionHandler: @escaping () -> Void) {
        
        for i in 0..<vectors.count {
            let vector = vectors[i]
            let dict: Dictionary<String, Any>  = [
                "name": vector.name,
                "vector": arrayToString(array: vector.vector),
                "distance": vector.distance
            ]
            let childString = "\(vector.name) - \(i)"
            Database.database().reference().child(child).child(vector.name).child(childString).updateChildValues(dict, withCompletionBlock: {
                (error, ref) in
                if error == nil {
                    //print("uploaded vector")
                }
                completionHandler()
            })
            
            
        }
    }
    func uploadKMeanVectors(vectors: [Vector], child: String, completionHandler: @escaping () -> Void) {
        
        for i in 0..<vectors.count {
            let vector = vectors[i]
            let dict: Dictionary<String, Any>  = [
                "name": vector.name,
                "vector": arrayToString(array: vector.vector),
                "distance": vector.distance
            ]
            let childString = "\(vector.name) - \(i)"
            Database.database().reference().child(child).child(childString).updateChildValues(dict, withCompletionBlock: {
                (error, ref) in
                if error == nil {
                    //print("uploaded vector")
                }
                completionHandler()
            })
        }
    }
    
//    func loadLogTimes(completionHandler: @escaping ([Users]) -> Void) {
//        var attendList: [Users] = []
//        Database.database().reference().child(LOG_TIME).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let data = snapshot.value as? [String: Any] {
//                let dataArray = Array(data)
//                let values = dataArray.map { $0.1 }
//                for dict in values {
//                    let item = dict as! NSDictionary
//                    guard let name = item["name"] as? String,
//                          let imgUrl = item["imageURL"] as? String,
//                          let time = item["time"] as? String
//                    else {
//                        print("Error at get log times.")
//                        continue
//                    }
//                    let object = Users(name: name, imageURL: imgUrl, time: time)
//                    attendList.append(object)
//                }
//                completionHandler(attendList.sorted(by: { $0.time > $1.time }))
//            }
//            else {
//                completionHandler(attendList)
//            }
//            
//        }) { (error) in
//            print(error.localizedDescription)
//            completionHandler(attendList)
//        }
//        
//    }
    
    func loadVector(completionHandler: @escaping ([Vector]) -> Void) {
        var vectors = [Vector]()
        Database.database().reference().child(KMEAN_VECTOR).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = snapshot.value as? [String: Any] {
                let dataArray = Array(data)
                
                let values = dataArray.map { $0.1 }
                for dict in values {
                    let item = dict as! NSDictionary
                    
                    guard let name = item["name"] as? String,
                          let vector = item["vector"] as? String,
                          let distance = item["distance"] as? Double
                    else {
                        print("Error at get vectors")
                        continue
                    }
                    let object = Vector(name: name, vector: stringToArray(string: vector), distance: distance)
                    vectors.append(object)
                }
                
            }
            completionHandler(vectors)
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(vectors)
        }
    }
    
    func loadAllVector(name: String, completionHandler: @escaping ([Vector]) -> Void) {
        var vectors = [Vector]()
        Database.database().reference().child(ALL_VECTOR).child(name).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = snapshot.value as? [String: Any] {
                let dataArray = Array(data)
                
                let values = dataArray.map { $0.1 }
                for dict in values {
                    let item = dict as! NSDictionary
                    
                    guard let name = item["name"] as? String,
                          let vector = item["vector"] as? String,
                          let distance = item["distance"] as? Double
                    else {
                        print("Error at get vectors")
                        continue
                    }
                    let object = Vector(name: name, vector: stringToArray(string: vector), distance: distance)
                    vectors.append(object)
                }
                
            }
            completionHandler(vectors)
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(vectors)
        }

    }
    
    func uploadLogTimes(user: User) {
        
        let storageRef = Storage.storage().reference(forURL: STORAGE_URL).child("\(user.name) - \(user.time.dropLast(10))")
        
        let metadata = StorageMetadata()
        
        if let imageData = user.image.jpegData(compressionQuality: 1.0) {
            metadata.contentType = "image/jpg"
            print(metadata)
            print(imageData)
            //upload image to firebase storage
            storageRef.putData(imageData, metadata: metadata, completion: {
                (StorageMetadata, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                else {
                    storageRef.downloadURL(completion: {
                        (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any>  = [
                                "name": user.name,
                                "imageURL": metaImageUrl,
                                "time": user.time
                            ]
                            Database.database().reference().child(LOG_TIME).child("\(user.name) - \(user.time.dropLast(10))").updateChildValues(dict, withCompletionBlock: {
                                (error, ref) in
                                if error == nil {
                                    print("Uploaded log time.")
                                }
                            })
                            
                        }
                    })
                }
            })
        }
        
        
        
    }
    
    func loadUsers(completionHandler: @escaping ([String: Int]) -> Void) {
        var userList: [String: Int] = [:]
        Database.database().reference().child(USER_CHILD).queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                userList = data as! [String: Int]
                completionHandler(userList)
                
            }
            else {
                completionHandler(userList)
            }
            
        })
        { (error) in
            print(error.localizedDescription)
            completionHandler(userList)
        }
    }
    func uploadUser(name: String, user_id: Int, completionHandler: @escaping () -> Void) {
        let dict = [name : user_id]
        Database.database().reference().child(USER_CHILD).updateChildValues(dict, withCompletionBlock: {
            (error, ref) in
            if error == nil {
                print("update user.")
            }
            completionHandler()
        })
    }
}
