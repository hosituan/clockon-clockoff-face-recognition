
//
//  Global.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 30/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML
import RealmSwift

//Machine Learning Model
let fnet = FaceNet()
let fDetector = FaceDetector()
var vectors = [Vector]()
var avgVectors = [Vector]()
var numberOfVectors = 0
var vectorHelper = VectorHelper()


let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)

var currentFrame: UIImage?
var currentLabel = "Unknown"
var numberOfFramesDeteced = 0
let validFrames = 3

var attendList: [User] = []

//Save User List
let defaults = UserDefaults.standard
var savedUserList = defaults.stringArray(forKey: "SavedUserList") ?? [String]()

//Realm
let realm = try! Realm()

let fb  = FirebaseManager()
