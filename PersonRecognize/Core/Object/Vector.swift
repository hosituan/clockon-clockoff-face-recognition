//
//  Vector.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 22/09/2020.
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
extension Sequence where Iterator.Element: Hashable {
    func uniq() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        return filter { seen.update(with: $0) == nil }
    }
}

extension Vector : Hashable {
    //var hash : [Double] { return self.vector }
}

func == (lhs: Vector, rhs: Vector) -> Bool {
    return lhs.vector == rhs.vector
}

