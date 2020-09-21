
//
//  Global.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 30/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML

let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)
let labelUrl = documentDirectory.appendingPathComponent("label")
var imageLabelDictionary : [UIImage:String] = [:]
var updatableModel : MLModel?
var imageConstraint: MLImageConstraint!
var model = Model()
var currentFrame: UIImage?
var userDict:[String: String] = loadLabel()
var faceList: [[UIImage : String]] = [[:]]
var userList: [String] = []

var attendList: [User] = []

