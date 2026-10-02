//
//  User.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 15/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

//local user
struct User {
    var name: String
    var image: UIImage
    var time: String
}

//upload user
struct Users: Codable {
    var name: String
    var imageURL: String
    var time: String
}
