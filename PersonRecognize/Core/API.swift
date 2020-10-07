//
//  GetAPI.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 01/10/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import Alamofire

let postTimeURL = ""


func postLogs(user: Users, completionHandler: @escaping (Error?) -> Void) {
    let api_url = "\(SERVER_URL)/api/timeLog/create"
    let status = user.name != "Unknown - Take Photo" ? "FACE_CHECKED" : "PENDING"
    var dictionary: [String: Any]
    if let user_id = userDict[user.name] {
        dictionary = [
            "user_id": user_id,
            "time_log" : user.time,
            "image" : user.imageURL,
            "status": status
        ]
    }
    else {
        dictionary = [
            "time_log" : user.time,
            "image" : user.imageURL,
            "status": status
        ]
    }
    
    print(dictionary)
    let params = dictionary
    let headers: HTTPHeaders = [
        "X-HHR-Secret-Key" : API_KEY,
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    AF.request(api_url, method: .post, parameters: params , encoding: URLEncoding.httpBody, headers: headers).responseJSON { AFdata in
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: AFdata.data!) as? [String: Any] else {
                print("Error: Cannot convert data to JSON object")
                return
            }
            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                print("Error: Cannot convert JSON object to Pretty JSON data")
                return
            }
            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                print("Error: Could print JSON in String")
                return
            }
            
            print(prettyPrintedJson)
        } catch {
            print("Error: Trying to convert JSON data to string")
            return
        }
    }
}

func uploadLogs(user: User, completionHandler: @escaping (Error?) -> Void) {
    
    let api_url = "\(SERVER_URL)/api/files/upload"
    guard let imgData = user.image.jpegData(compressionQuality: 0.9) else {
        return
    }
    AF.upload(
        multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file" , fileName: "\(user.name) - \(user.time).jpeg", mimeType: "image/jpeg")
        },
        to: api_url, method: .post , headers: nil)
        .responseJSON(completionHandler: { (data) in
            switch data.result {
            case .success(_):
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data.data!, options: .fragmentsAllowed) as! NSDictionary
                    print("Success!")
                    print(dictionary)
                    guard let imgURL = dictionary["url"] as? String else {
                        print("no url!")
                        return
                    }
                    let userLog = Users(name: user.name, imageURL: imgURL, time: user.time)
                    postLogs(user: userLog) { (error) in
                        if error != nil {
                            completionHandler(error)
                        } else {
                            completionHandler(nil)
                            
                        }
                    }
                    //completionHandler(nil)
                }
                catch {
                    print("error")
                }
                break
                
            case .failure(_):
                print("failure")
                
                
                break
                
            }
        })
}


func getMethod() {
    AF.request("", parameters: nil, headers: nil).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: AFdata.data!) as? [String: Any] else {
                print("Error: Cannot convert data to JSON object")
                return
            }
            guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                print("Error: Cannot convert JSON object to Pretty JSON data")
                return
            }
            guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                print("Error: Could print JSON in String")
                return
            }
            
            print(prettyPrintedJson)
        } catch {
            print("Error: Trying to convert JSON data to string")
            return
        }
    }
}
