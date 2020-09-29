//
//  PredictImageViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 11/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import AVFoundation
import FaceCropper
import MBProgressHUD

class PredictImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var face1: UIImageView!
    @IBOutlet weak var face2: UIImageView!
    @IBOutlet weak var nameFace2: UILabel!
    @IBOutlet weak var nameFace1: UILabel!
    
    let knn: KNNDTW = KNNDTW()
    var corner:CGFloat = 35
    override func viewDidLoad() {
        super.viewDidLoad()
        fnet.load()
        clearData()
//        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
//
//        for vector in kMeanVectors {
//            training_samples.append(knn_curve_label_pair(curve: vector.vector, label: vector.name))
//        }
//
//
//
//
//
//        knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
//
//        knn.train(data_sets: training_samples)
    
    }
    
    
    @IBAction func tapTakePhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        clearData()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func clearData() {
        face2.image = nil
        face2.image = nil
        nameFace1.text = ""
        nameFace2.text = ""
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            print("this is image")
            self.mainImg.image = image
            let start = DispatchTime.now()
//
//            let frame = CIImage(image: image)!
//            let img = fDetector.extractFaces(frame: frame)
//            guard let i = img.first else {
//                return
//            }
//            let targetVector = fnet.run(image: i)
//            let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: targetVector)
//            print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
            
            let result = vectorHelper.getResult(image: image)
            
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            //nameFace1.text = "\(timeInterval)"
            nameFace1.text = "\(result.name): \(result.distance)%:\(timeInterval)seconds."
            
            image.face.crop { [self] res in
                switch res {
                case .success(let faces):
                    self.face1.image = faces[0]
                    self.face1.layer.cornerRadius = self.corner
                    
                case .notFound:
                    self.showDialog(message: "Not found any face!")
                case .failure(let error):
                    print("Error crop face: \(error)")
                }
            }
        }
    }
}
