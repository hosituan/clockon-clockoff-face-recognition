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

class FirebaseManager {
    init() {
        FirebaseApp.configure()
    }
    
    func uploadVector(vectors: [Vector], child: String) {
        var childString = child

        for i in 0..<vectors.count {
            let vector = vectors[i]
            let dict: Dictionary<String, Any>  = [
                "name": vector.name,
                "vector": arrayToString(array: vector.vector),
                "distance": vector.distance
            ]
            print(child)
            if child == "All vectors" {
                childString = "\(vector.name) - \(i)"
            }
            else {
                childString = vector.name
            }
            Database.database().reference().child(child).child(childString).updateChildValues(dict, withCompletionBlock: {
                (error, ref) in
                if error == nil {
                    print("uploaded vector")
                }
            })


        }
    }
    
    func loadVector(completionHandler: @escaping ([Vector]) -> Void) {
        Database.database().reference().child("Vectors").queryLimited(toLast: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let dataArray = Array(data)
                var vectors = [Vector]()
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
                completionHandler(vectors)
                
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func uploadLogTimes(user: User) {
        
        let storageRef = Storage.storage().reference(forURL: "gs://person-recognition-6df29.appspot.com").child("\(user.name) - \(user.time)")

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
                            Database.database().reference().child("LogTimes").child("\(user.name) - \(user.time)").updateChildValues(dict, withCompletionBlock: {
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
    
}
