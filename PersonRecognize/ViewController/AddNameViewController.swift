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

class AddNameViewController: UIViewController {
    
    private var generator:AVAssetImageGenerator!
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var textField: SkyFloatingLabelTextField!
    var videoURL: URL?
    var numberOflabel = 50

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tapDoneButoon(_ sender: UIButton) {
        if textField.text != "" && videoURL != nil {
            if let label = getEmptyLabel() {
                //let getFrames = GetFrames()
                print("Empty label is: \(label)")
                saveLabel(at: label, value: textField.text!)
                //getFrames.getAllFrames(videoURL!, for: label)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Warning", message: "You can't add more than 30 users!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getEmptyLabel() -> String? {
        userDict = loadLabel()
        for i in 0..<numberOflabel {
            let label = "user\(i)"
            if userDict[label] == "" {
                return label
            }
        }
        return nil
    }
    
}



