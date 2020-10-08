//
//  PreviewView.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

import UIKit
import Vision
import AVFoundation

class PreviewView: UIView {
    
    let api = API()
    private var maskLayer = [CAShapeLayer]()
    private var textLayer = [CATextLayer]()
    
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    weak var session: AVCaptureSession? {
        get {
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            return videoPreviewLayer?.session
        }
        
        set {
            videoPreviewLayer = layer as? AVCaptureVideoPreviewLayer
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect, prediction: String) -> CAShapeLayer{
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 1
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0
        
        let label = CATextLayer()
        label.frame = rect
        label.string = prediction
        label.fontSize = 20
        layer.addSublayer(label)
        
        textLayer.append(label)
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
        
        return mask
    }
    
    
    func drawFaceboundingBox(face : VNFaceObservation, currentFrame: UIImage?) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        var lb = UNKNOWN
        if let frame = currentFrame {
            let res = vectorHelper.getResult(image: frame)
            lb = "\(res.name): \(res.distance)%"
            let result = res.name
            if result != UNKNOWN {
                let  label = result
                let today = Date()
                formatter.dateFormat = DATE_FORMAT
                let timestamp = formatter.string(from: today)
                if label != currentLabel {
                    currentLabel = label
                    numberOfFramesDeteced = 1
                } else {
                    numberOfFramesDeteced += 1
                }
                let detectedUser = User(name: label, image: frame, time: timestamp)
                if numberOfFramesDeteced > validFrames  {
                    //print("Detected")
                    if localUserList.count == 0 {
                        print("append 1")
                        speak(name: label)
                        //attendList.append(detectedUser)
                        localUserList.append(detectedUser)
                        api.uploadLogs(user: detectedUser) { error in
                            if error != nil {
                                self.showDiaglog3s(name: label, false)
                            }
                        }
                        //fb.uploadLogTimes(user: detectedUser) //upload to firebase db
                        showDiaglog3s(name: label, true)
                    }
                    else  {
                        var count = 0
                        for item in localUserList {
                            if item.name == label {
                                if let time = formatter.date(from: item.time) {
                                    let diff = abs(time.timeOfDayInterval(toDate: today))
                                    print("Diffrent: \(diff) seconds")
                                    if diff > 60 {
                                        print("append 2")
                                        localUserList.append(detectedUser)
                                        localUserList = localUserList.sorted(by: { $0.time > $1.time })
                                        speak(name: label)
                                        api.uploadLogs(user: detectedUser) { error in
                                                if error != nil {
                                                    self.showDiaglog3s(name: label, false)
                                                }
                                        }
                                        //fb.uploadLogTimes(user: detectedUser) //upload to firebase db
                                        showDiaglog3s(name: label, true)
                                    }
                                }
                                break
                            }
                            else {
                                count += 1
                            }
                        }
                        
                        if count == localUserList.count {
                            print("append 3")
                            speak(name: label)
                            api.uploadLogs(user: detectedUser) { error in
                                if error != nil {
                                    self.showDiaglog3s(name: label, false)
                                }
                            }
                            //fb.uploadLogTimes(user: detectedUser) //upload to firebase db
                            localUserList.append(detectedUser)
                            localUserList = localUserList.sorted(by: { $0.time > $1.time })
                            showDiaglog3s(name: label, true)
                        }
                    }
                }
            }
        }
        
        _ = createLayer(in: facebounds, prediction: lb)
    }
    func ImageInRect(_ rect: CGRect) -> UIImage? {
        return nil
    }
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        for text in textLayer {
            text.removeFromSuperlayer()
        }
        textLayer.removeAll()
        maskLayer.removeAll()
    }
    
    func speak(name: String) {
        let utterance = AVSpeechUtterance(string: "Hello \(name)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    
    func showDiaglog3s(name: String,_ success: Bool) {
        let title = success == false ?  "Can't join!" : "Joining..."
        let alert = UIAlertController(title: title, message: "\(name)", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    

}





