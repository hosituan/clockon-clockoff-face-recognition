//
//  AddNameViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 10/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import AVFoundation
import SkyFloatingLabelTextField
import MBProgressHUD
import ProgressHUD

class AddNameViewController: UIViewController {
    
    private var generator:AVAssetImageGenerator!
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var textField: SkyFloatingLabelTextField!
    var videoURL: URL?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = videoURL {
            self.getThumbnailImageFromVideoUrl(url: url) { (thumbImage) in
                self.faceImageView.image = thumbImage
                self.faceImageView.layer.cornerRadius = self.faceImageView.frame.height / 2
            }
        }
        hideKeyboardWhenTappedAround()

    }
    
    @IBAction func tapDoneButoon(_ sender: UIButton) {
        if textField.text != "" && videoURL != nil {
            
            ProgressHUD.show("Adding...")
            let getFrames = GetFrames()
            print("Your Name is: \(textField.text!)")
            fb.uploadUser(name: textField.text!) {
                ProgressHUD.dismiss()
            }
            //savedUserList.append(textField.text!)
            //defaults.set(savedUserList, forKey: "SavedUserList")
            getFrames.getAllFrames(videoURL!, for: textField.text!)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
}



