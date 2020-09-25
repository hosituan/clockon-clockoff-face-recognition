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


class FirebaseManager {
    init() {
        FirebaseApp.configure()
    }
    
    func uploadVector(vectors: [Vector]) {
        for vector in vectors {
            let dict: Dictionary<String, Any>  = [
                "name": vector.name,
                "vector": arrayToString(array: vector.vector),
                "distance": vector.distance
            ]
            Database.database().reference().child("Vectors").child(vector.name).updateChildValues(dict, withCompletionBlock: {
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
}
