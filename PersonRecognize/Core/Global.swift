
//
//  Global.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 30/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML

//Machine Learning Model

let fnet = FaceNet()
let fDetector = FaceDetector()
var vectors = [Vector]()
var vectorHelper = VectorHelper()


let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)
let labelUrl = documentDirectory.appendingPathComponent("label")
var currentFrame: UIImage?
var userDict:[String: String] = loadLabel()
var userList: [String] = []

var attendList: [User] = []


 
