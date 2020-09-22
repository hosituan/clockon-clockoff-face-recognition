//
//  HomeViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 09/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation


class HomeViewController: UIViewController {
    
    var fps = 2
    private var generator:AVAssetImageGenerator!
    var modelUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fnet.load()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        userDict = loadLabel()
        if let dictionary = NSMutableDictionary(contentsOf: labelUrl){
            userDict = dictionary as! Dictionary<String,String>
        }
        print(userDict)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    @IBAction func tapGenerateData(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Number", message: "Fill id", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self, weak alert] (_) in
            let textField = (alert!.textFields![0]) as UITextField
            let i = textField.text!
            let label = "user\(i)"
            print(label)
            let videoURL = documentDirectory.appendingPathComponent("\(label).mov")
            print(videoURL)
            getAllFrames(videoURL, for: label)
        }))

        self.present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func tapStart(_ sender: UIButton) {
        self.performSegue(withIdentifier: "startPredict", sender: nil)
    }
    @IBAction func tapPredictImage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openPredictImage", sender: nil)
    }
    @IBAction func tapAddUser(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openAddUser", sender: nil)
    }
    @IBAction func tapViewData(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewFace", sender: nil)
    }
    @IBAction func tapViewLog(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewLog", sender: nil)
    }
    @IBAction func tapTraining(_ sender: UIButton) {
        
        
        for user in userDict {
            if user.value != "" {
                print("\(user.key):\(user.value)")
                vectorHelper.addVector(name: user.key)
            }
        }
    }
}

extension HomeViewController {
    
    func getAllFrames(_ videoUrl: URL, for label: String) {
        let asset:AVAsset = AVAsset(url: videoUrl)
        let duration:Double = CMTimeGetSeconds(asset.duration)
        self.generator = AVAssetImageGenerator(asset:asset)
        self.generator.appliesPreferredTrackTransform = true
        
        var i: Double = 0
        repeat {
            getFrame(fromTime: i, for: label)
            i = i + (1 / Double(fps))
        } while (i < duration)
        self.generator = nil
        print("Complete")
    }
    func getFrame(fromTime:Double, for label: String) {
        
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 60)
        let image:UIImage
        do {
            try image = UIImage(cgImage: self.generator.copyCGImage(at:time, actualTime:nil))
        } catch {
            return
        }

            
        trainingDataset.saveImage(image, for: label)
        if let img = image.rotate(radians: .pi / 20) {
            trainingDataset.saveImage(img, for: label)
        }
        if let img = image.rotate(radians: -.pi / 20) {
            trainingDataset.saveImage(img, for: label)
        }
        if let img = image.flipHorizontally() {
            trainingDataset.saveImage(img, for: label)
        }
    }
}
