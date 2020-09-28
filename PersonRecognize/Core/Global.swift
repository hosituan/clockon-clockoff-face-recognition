
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

//the most important variable
var kMeanVectors = [Vector]()


var numberOfVectors = 0
var vectorHelper = VectorHelper()


let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)

var currentFrame: UIImage?

var currentLabel = UNKNOWN
var timeDetected = ""
var numberOfFramesDeteced = 0 //number frames detected
let validFrames = 5 //after getting 3 frames, users have been verified


var attendList: [Users] = []
var localUserList: [User] = [] //to ignore append user.

//Save User Local List
let defaults = UserDefaults.standard
var savedUserList = defaults.stringArray(forKey: SAVED_USERS) ?? [String]()
//defaults.set(savedUserList, forKey: SAVED_USERS)



//Realm
let realm = try! Realm()
let fb  = FirebaseManager()


let KMeans = KMeansSwift.sharedInstance
