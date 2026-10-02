//
//  Define.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 25/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation

//define in Firebase DB
let LOG_TIME = "LogTimes"
let USER_CHILD = "Users"
// FaceKit templates. Kept apart from the old "K-mean Vectors": those came from a different
// face crop and are not comparable with FaceKit embeddings, so users must be re-enrolled.
let FACE_IDENTITIES = "FaceKit Identities"

//Define unknown
let UNKNOWN = "Unknown"
let TAKE_PHOTO_NAME = "Unknown - Take Photo"

//Local user list
let SAVED_USERS = "SavedUserList"

//Date time formatter
let DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

//Seconds before the same person can be logged again
let VALID_TIME = 60
