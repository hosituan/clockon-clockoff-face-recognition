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
    
    var fps = 5
    private var generator:AVAssetImageGenerator!
    
    var modelUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMLModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        userDict = loadLabel()
        if let dictionary = NSMutableDictionary(contentsOf: labelUrl){
            userDict = dictionary as! Dictionary<String,String>
        }
        print(faceList.count)
        print(faceList)
        print(userDict)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    @IBAction func tapGenerateData(_ sender: UIButton) {
        
//        //let getFrame = GetFrames()
//        for i in 11...19 {
//            let label = "user\(i)"
//            //let name = userDict[label]!
//            let videoURL = documentDirectory.appendingPathComponent("\(label).mov")
//            print(videoURL)
//            getAllFrames(videoURL, for: label)
//        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        showDialog(message: "This feature is not available!")
        //        imageLabelDictionary = [:]
        //
        //        for label in userDict.keys {
        //            for item in trainingDataset.getImage(label: label) {
        //                imageLabelDictionary[item!] = label
        //            }
        //        }
        //        if imageLabelDictionary != [:] {
        //            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        //            loadingNotification.mode = MBProgressHUDMode.indeterminate
        //            loadingNotification.label.text = "Training"
        //            model.startTraining(view: self.view)
        //        }
        //        else {
        //
        //            showDialog(message: "No data!")
        //        }
    }
}

extension HomeViewController {
    func loadMLModel() {
        do{
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileURL = documentDirectory.appendingPathComponent("HumanTraineds.mlmodelc")
            if let model = model.loadModel(url: fileURL){
                updatableModel = model
                modelUrl = fileURL
            }
            else{
                if let modelURL = Bundle.main.url(forResource: "HumanImageClassifier", withExtension: "mlmodelc"){
                    if let model = model.loadModel(url: modelURL){
                        print("Loaded from: \(modelURL)")
                        updatableModel = model
                        modelUrl = modelURL
                    }
                }
            }
            
            if let updatableModel = updatableModel {
                imageConstraint = model.getImageConstraint(model: updatableModel)
            }
            
        } catch(let error){
            print("initial error is \(error.localizedDescription)")
        }
    }
}

extension HomeViewController {
    
    func getAllFrames(_ videoUrl: URL, for label: String) {
        let asset:AVAsset = AVAsset(url: videoUrl)
        let duration:Double = CMTimeGetSeconds(asset.duration)
        self.generator = AVAssetImageGenerator(asset:asset)
        self.generator.appliesPreferredTrackTransform = true
        
        //let queue = OperationQueue()
        //queue.maxConcurrentOperationCount = 10
        
        var i: Double = 0
        repeat {
            //let frameOperation = FrameOperation(time: i, label: label, gen: self.generator)
            //queue.addOperation(frameOperation)
            getFrame(fromTime: i, for: label)
            i = i + (1 / Double(fps))
        } while (i < duration)
        self.generator = nil
        //queue.addBarrierBlock {
        print("Complete")
            //            DispatchQueue.main.async {
            //                //UIApplication.shared.windows.first?.rootViewController?.showDialog(message: "Added User")
            //            }
            //
            
        //}
    }
    func getFrame(fromTime:Double, for label: String) {
        
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 60)
        let image:UIImage
        do {
            try image = UIImage(cgImage: self.generator.copyCGImage(at:time, actualTime:nil))
        } catch {
            return
        }
        image.face.crop { result in
            switch result {
            case .success(let faces):
                for face in faces {
                    for item in face.createImageList() {
                        if let img = item {
                            trainingDataset.saveImage(img, for: label)
                        }
                    }
                }
            case .notFound:
                print("Not found face")
            case .failure(let error):
                print("Error crop face: \(error)")
            }
        }
        image.rotate(radians: .pi / 12)?.face.crop({ (result) in
            switch result {
            case .success(let faces):
                for face in faces {
                    for item in face.createImageList() {
                        if let img = item {
                            trainingDataset.saveImage(img, for: label)
                        }
                    }
                }
            case .notFound:
                print("Not found face")
            case .failure(let error):
                print("Error crop face: \(error)")
            }
        })
        
        image.rotate(radians: -.pi / 12)?.face.crop({ (result) in
            switch result {
            case .success(let faces):
                for face in faces {
                    for item in face.createImageList() {
                        if let img = item {
                            trainingDataset.saveImage(img, for: label)
                        }
                    }
                }
            case .notFound:
                print("Not found face")
            case .failure(let error):
                print("Error crop face: \(error)")
            }
        })
        
        image.flipHorizontally()?.face.crop({ (result) in
            switch result {
            case .success(let faces):
                for face in faces {
                    for item in face.createImageList() {
                        if let img = item {
                            trainingDataset.saveImage(img, for: label)
                        }
                    }
                }
            case .notFound:
                print("Not found face")
            case .failure(let error):
                print("Error crop face: \(error)")
            }
        })
        
    }
    
}
