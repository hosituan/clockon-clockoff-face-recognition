//
//  PreviewView.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import AVFoundation
import UIKit

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
    
    
    /// - Parameter boundingBox: normalised, origin bottom-left (Vision/FaceKit convention).
    func drawFaceboundingBox(boundingBox: CGRect, label: String) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        let facebounds = boundingBox.applying(translate).applying(transform)
        _ = createLayer(in: facebounds, prediction: label)
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

}





