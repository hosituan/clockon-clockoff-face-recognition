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
    
    
    func drawFaceboundingBox(face : VNFaceObservation) {
        
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
                //let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .medium)
                let today = Date()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let timestamp = formatter.string(from: today)
                //print(timeDetected)
                if label != currentLabel {
                    currentLabel = label
                    numberOfFramesDeteced = 1
                } else {
                    numberOfFramesDeteced += 1
                }
                let detectedUser = User(name: label, image: frame, time: timestamp)
                if numberOfFramesDeteced > validFrames  {
                    print("Detected")
                    if localUserList.count == 0 {
                        speak(name: label)
                        //attendList.append(detectedUser)
                        localUserList.append(detectedUser)
                        fb.uploadLogTimes(user: detectedUser)
                        print("append 1")
                        showDiaglog3s(name: label)
                    }
                    else  {
                        var count = 0
                        for item in localUserList {
                            if item.name == label {
                                if let time = formatter.date(from: item.time) {
                                    let diff = time.timeOfDayInterval(toDate: today)
                                    if diff > 60 {
                                        localUserList.append(detectedUser)
                                        localUserList = localUserList.sorted(by: { $0.time > $1.time })
                                        speak(name: label)
                                        //postLogs(user: detectedUser)
                                        fb.uploadLogTimes(user: detectedUser)
                                        print("append 2")
                                        showDiaglog3s(name: label)
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
                            //fb.uploadLogTimes(user: detectedUser)
                            localUserList.append(detectedUser)
                            localUserList = localUserList.sorted(by: { $0.time > $1.time })
                            showDiaglog3s(name: label)
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
    
    func showDiaglog3s(name: String) {
        let alert = UIAlertController(title: "Joined!", message: "\(name)", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}





