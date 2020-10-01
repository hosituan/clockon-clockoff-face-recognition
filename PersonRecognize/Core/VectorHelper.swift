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
        //let frame = CIImage(image: image)!
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let vector = fnet.run(image: i)
            if vector.count  ==  128 {
                return (Vector(name: name, vector: vector))
            }
            else  { return nil }
        }
        else {
            //print("Not found face!")
        }
        
        return nil
    }
    
    func addVector(name: String, completionHandler: @escaping ([Vector]) -> Void) {
        let imageList = trainingDataset.getImage(label: name)
        //print(imageList.count)
        var vectors: [Vector] = []
        print(imageList.count)
        if imageList.count > 0  {
            for item in imageList {
                if let vector = createVector(name: name, image: item!) {
                    vectors.append(vector)
                }
                
            }
            completionHandler(vectors)
        }
        else {
            completionHandler(vectors)
        }
        //print(vectors.count)
    }
    
    func saveVector(_ vector: Vector) {
        let item = SavedVector()
        item.name = vector.name
        item.vector = arrayToString(array: vector.vector)
        //print(vector.vector)
        item.distance = vector.distance
        
        try! realm.write {
            realm.add(item)
            //print("saved vector")
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
    
    func getResult(image: UIImage) -> Vector {
        var array: [Vector] = []
        var result = Vector(name: "Unknown", vector: [], distance: 10)
        let image = image
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let targetVector = fnet.run(image: i)
            //for vector in vectors {
            for vector in  kMeanVectors {
                let distance = l2distance(targetVector, vector.vector)
                //print("\(vector.name): \(distance * 1000)")
                if distance * 1000 < 700 {
                    print("\(vector.name): \(distance * 1000)")
                    array.append(vector)
                    if distance < result.distance {
                        result = vector
                        result.distance = distance
                        //print("result: \(result.name)")
                        //print("vector: \(vector.name)")
                    }
                }
            }
            if result.distance * 1000 < 400  {
                result.distance = 100
                return result
            }
            let groupedItems = Dictionary(grouping: array, by: {$0.name})
            var max = 0
            var count = 0
            for item in groupedItems {
                if item.value.count > max {
                    max = item.value.count
                    count = 1
                }
                else if item.value.count == max {
                    count += 1
                }
            }
            switch max {
                case 1:
                    result.distance = 70
                case 2:
                    result.distance = 90
                case 3:
                    result.distance = 100
                default:
                    result.distance = 0
            }
            return result
        }
        result.distance = 0
        return result
    }
}



//MARK: - Global function

func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
    return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
}

//get  KMean Vector from all
func getKMeanVector(vectors: [Vector]) -> [Vector] {
    var vectorList: [Vector] = []
    let groupedItems = Dictionary(grouping: vectors, by: {$0.name})
    print(groupedItems.count)
    for item in groupedItems {
        getKMeanVectorSameName(vectors: item.value) { (result) in
            vectorList.append(contentsOf: result)
        }
    }
    return vectorList
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

