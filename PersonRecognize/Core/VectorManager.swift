//
//  Models.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 22/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift



class VectorHelper  {
    
    
    func createVector(name: String, image: UIImage) -> Vector? {
        let image = image
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let vector = fnet.run(image: i)
            return (Vector(name: name, vector: vector))
        }
        else {
            //print("Not found face!")
        }
        
        return nil
    }
    
    func addVector(name: String) {
        let imageList = trainingDataset.getImage(label: name)
        //print(imageList.count)
        
        if imageList.count > 0  {
            for item in imageList {
                if let vector = createVector(name: name, image: item!) {
                    vectors.append(vector)
                    saveVector(vector: vector)
                }
                
            }
        }
        //print(vectors.count)
        
        
    }
    
    func saveVector(vector: Vector) {
        let item = SavedVector()
        item.name = vector.name
        item.vector = arrayToString(array: vector.vector)
        //print(vector.vector)
        item.distance = vector.distance

        try! realm.write {
            realm.add(item)
            print("saved vector")
        }
    }
    
    func loadVector() -> [Vector] {
        var vectors:[Vector] = []
        let items = realm.objects(SavedVector.self)
        for item in items {
            let vector = Vector(name: item.name, vector: stringToArray(string: item.vector), distance: item.distance)
            vectors.append(vector)
        }
        

        return vectors
    }
    func getResult(image: UIImage) -> String {
        var result = Vector(name: "Unknown", vector: [], distance: 10)
        let image = image
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let targetVector = fnet.run(image: i)
            //print(vectors.count)
            //for vector in vectors {
            for vector in  avgVectors {
                let distance = l2distance(targetVector, vector.vector)
                //print("\(vector.name): \(distance * 1000)")
                if distance < result.distance && vector.name != "" {
                    result = vector
                    result.distance = distance
//                    print("result: \(result.name)")
//                    print("vector: \(vector.name)")
                }
            }
        }
        if result.distance * 1000 <= 790 {
            return result.name
        }
        else { return "Unknown" }
        
        
        
    }
}

func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
    return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
}

func arrayToString(array: [Double]) -> String {
    var str = ""
    //print(array.count)
    //print(array)
    for item in array {
        str += ",\(item)"
    }
    //print(str)
    return str
}

func stringToArray(string: String) -> [Double] {
    var vector: [Double] = []
    var array = string.components(separatedBy: ",")
    array.removeFirst()
    //print(array.count)
    for item in array {
        //print(item)
        vector.append(Double(item)!)
    }
    return vector
}


func averageVector(vectors: [Vector]) -> Vector {
    //print(vectors.count)
    var array: [Double] = []
    for i in 0...127 {
        var sum: Double = 0
        for item in vectors {
            sum += item.vector[i]
            
        }
        array.append(sum / 128)
    }
    let vector = Vector(name: vectors[0].name, vector: array)
    return vector
}


func splitVectorByName(vector: [Vector]) -> [Vector] {
    var vectorList: [Vector] = []
    let groupedItems = Dictionary(grouping: vectors, by: {$0.name})
    for item in groupedItems {
        var vectors: [Vector] =  []
        for i in item.value {
            vectors.append(i)
        }
        vectorList.append(averageVector(vectors: vectors))
    }
    return vectorList
}

