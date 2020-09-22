//
//  Models.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 22/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import UIKit


let fnet = FaceNet()
let fDetector = FaceDetector()
var vectors = [Vector]()
var vectorHelper = VectorHelper()

class VectorHelper  {
    
    func createVector(name: String, image: UIImage) -> Vector? {
        let image = image
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let vector = fnet.run(image: i)
            //print(i)
            //print(vector)
            return (Vector(name: name, vector: vector))
        }
        
        return nil
    }
    
    func addVector(name: String) {
        let imageList = trainingDataset.getImage(label: name)
        print(imageList.count)
        if imageList.count > 0  {
            for item in imageList {
                if let vector = createVector(name: name, image: item!) {
                    vectors.append(vector)
                }
                
            }
        }
        
        
    }
    
    func getResult(image: UIImage) -> String {
        var result = Vector(name: "", vector: [], distance: 10)
        let image = image
        let frame = CIImage(image: image)!
        let img = fDetector.extractFaces(frame: frame)
        if let i = img.first {
            let targetVector = fnet.run(image: i)
            print(vectors.count)
            for vector in vectors {
                let distance = l2distance(targetVector, vector.vector)
                if distance < result.distance && vector.name != "" {
                    result = vector
                    result.distance = distance
                    //print("result: \(result.name)")
                    //print("vector: \(vector.name)")
                }
            }
        }
        
        return result.name
        
    }
}

func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
    return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
}


struct Vector {
    var name: String
    var vector: [Double]
    var distance: Double
}
extension Vector {
    init(name: String, vector: [Double]) {
        self.init(name: name,
                  vector: vector,
                  distance: 0)
    }
}
