//
//  K-dTree.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 04/10/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
//import KDTree


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


//var c = 0
//
//extension Vector: KDTreePoint {
//    static var dimensions = 128
//
//    func kdDimension(_ dimension: Int) -> Double {
//        
//        return self.vector[dimension]
////
////        c += 1
////        print(dimension)
////        if dimension == 0 {
////            return self.vector[0]
////        }
////        else {
////
////            return self.vector[127]
////        }
//
//    }
//
//    func squaredDistance(to otherPoint: Vector) -> Double {
//        return l2distance(self.vector, otherPoint.vector)
//    }
//}
//
//
//
//func find(vector: Vector) -> String {
//
//    
//    
//    let start = DispatchTime.now()
//    let v6 = tree!.nearest(to: vector)
//
//    
//    let end = DispatchTime.now()
//    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
//    let timeInterval = Double(nanoTime) / 1_000_000_000
//    print(timeInterval)
//    print(c)
//    return v6?.name ?? "Unkn"
//    
//}
