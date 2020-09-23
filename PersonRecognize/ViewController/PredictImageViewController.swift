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
    
    var corner:CGFloat = 35
    override func viewDidLoad() {
        super.viewDidLoad()
        clearData()
        print(vectors.count)
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
            let result = vectorHelper.getResult(image: image)
            
            nameFace1.text = result
            print(result)
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
