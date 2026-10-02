
//
//  Global.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 30/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)

var attendList: [Users] = [] //load from firebase
var localUserList: [User] = [] //recently logged users, used to skip duplicate logs
var userDict = [String: Int]()

//Save User Local List
let defaults = UserDefaults.standard
var savedUserList = defaults.stringArray(forKey: SAVED_USERS) ?? [String]()

let fb = FirebaseManager()

//date time formatter
let formatter = DateFormatter()
