//
//  ViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 8/28/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML
import Vision
import MobileCoreServices
import AVFoundation
import FaceCropper
import MBProgressHUD


class TrainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgU1: UIImageView!
    @IBOutlet weak var u1Label: UILabel!
    @IBOutlet weak var imgU2: UIImageView!
    @IBOutlet weak var u2Label: UILabel!
    //private var generator:AVAssetImageGenerator!
    
    
    var modelUrl: URL?
    //var startTime = 0
    //var count = 0
    
    
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMLModel()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let dictionary = NSMutableDictionary(contentsOf: labelUrl){
            userDict = dictionary as! Dictionary<String,String>
            print(userDict)
            //imgView.image = currentFrame
        }
    }
    
    func loadMLModel() {
        do{
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileURL = documentDirectory.appendingPathComponent("HumanTrained.mlmodelc")
            if let model = model.loadModel(url: fileURL){
                updatableModel = model
                modelUrl = fileURL
            }
            else{
                if let modelURL = Bundle.main.url(forResource: "HumanFinal", withExtension: "mlmodelc"){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    @IBAction func trainButtonTapped(_ sender: UIButton) {
        
        imageLabelDictionary = [:]
        
        for label in userDict.keys {
            for item in trainingDataset.getImage(label: label) {
                imageLabelDictionary[item!] = label
            }
        }
        if imageLabelDictionary != [:] {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Training"
            model.startTraining(view: self.view)
        }
        else {
            
            showDialog(message: "No data!")
        }
        
    }
    
    @IBAction func viewFaceTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewFace", sender: nil)
    }
    
    @IBAction func AddNewUser(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addUser", sender: nil)
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imgU1.image = nil
        imgU2.image = nil
        u1Label.text =  ""
        u2Label.text = ""
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            print("this is image")
            self.imgView.image = image
            image.face.crop { [self] res in
                switch res {
                case .success(let faces):
                    self.imgU1.image = faces[0]
                    self.imgU1.layer.cornerRadius = 25
                    let result = model.predict(image: faces[0].resized(smallestSide: 227)!)
                    let confidence = result.1! * 100
                    print(result)
                    if confidence >= 80 {
                        self.u1Label.text = "\(userDict[result.0!]!): \(confidence.rounded() )%"
                    }
                    else {
                        self.u1Label.text = "Unknown"
                    }
                    
                    if faces.count >= 2 {
                        self.imgU2.image = faces[1]
                        self.imgU2.layer.cornerRadius = 25
                        let result = model.predict(image: faces[1])
                        let confidence = result.1! * 100
                        if confidence >= 90 {
                            self.u2Label.text = "\(userDict[result.0!]!): \(confidence)%"
                        }
                        else {
                            self.u2Label.text = "Unknown"
                        }
                    }
                case .notFound:
                    self.showDialog(message: "Not found any face!")
                case .failure(let error):
                    print("Error crop face: \(error)")
                }
            }
        }
    }
}

