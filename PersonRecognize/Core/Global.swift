
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
//import KDTree

//Machine Learning Model
let fnet = FaceNet()
let fDetector = FaceDetector()

var vectorHelper = VectorHelper()


let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)

//var currentFrame: UIImage?

var currentLabel = UNKNOWN

var numberOfFramesDeteced = 0 //number frames detected
let validFrames = 5 //after getting 5 frames, users have been verified

var attendList: [Users] = [] //load from firebase
var localUserList: [User] = [] //copy of attenList, use it to ignore appended users
var userDict = [String: Int]()

//Save User Local List
let defaults = UserDefaults.standard
var savedUserList = defaults.stringArray(forKey: SAVED_USERS) ?? [String]()
//defaults.set(savedUserList, forKey: SAVED_USERS)



//Realm
let realm = try! Realm()
let fb  = FirebaseManager()

//KMeans to reduce number  of vectors
let KMeans = KMeansSwift.sharedInstance
var kMeanVectors = [Vector]()

//date time formatter
let formatter = DateFormatter()


//var tree: KDTree<Vector>?


