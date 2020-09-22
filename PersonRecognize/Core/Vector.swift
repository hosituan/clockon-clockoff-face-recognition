//
//  Vector.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 22/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation

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

