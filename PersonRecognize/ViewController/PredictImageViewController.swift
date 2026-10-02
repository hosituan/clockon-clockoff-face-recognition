//
//  PredictImageViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 11/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import FaceKit
import UIKit
import ProgressHUD

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
        face1.image = nil
        face2.image = nil
        nameFace1.text = ""
        nameFace2.text = ""
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage, let cgImage = image.uprightCGImage() else { return }
        mainImg.image = image
        ProgressHUD.show("Recognizing...")

        Task { @MainActor in
            let start = DispatchTime.now()
            let results: [Recognition]
            do {
                results = try await FaceService.shared.recognizer().identify(in: cgImage)
            } catch {
                ProgressHUD.dismiss()
                showDialog(message: "Recognition failed: \(error.localizedDescription)")
                return
            }
            let seconds = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
            ProgressHUD.dismiss()

            guard !results.isEmpty else {
                showDialog(message: "Not found any face!")
                return
            }
            // Largest faces first; the screen has room for two.
            let faces = results.sorted { $0.face.boundingBox.width > $1.face.boundingBox.width }
            for (view, label, result) in zip(zip([face1!, face2!], [nameFace1!, nameFace2!]), faces).map({ ($0.0, $0.1, $1) }) {
                view.image = crop(cgImage, to: result.face)
                view.layer.cornerRadius = corner
                label.text = Self.describe(result.match)
            }
            if faces.count == 1 {
                nameFace2.text = "Time taken: \(String(format: "%.2f", seconds)) seconds."
            }
        }
    }

    private func crop(_ image: CGImage, to face: DetectedFace) -> UIImage? {
        let box = face.boundingBoxTopLeft
        let rect = CGRect(x: box.minX * CGFloat(image.width), y: box.minY * CGFloat(image.height),
                          width: box.width * CGFloat(image.width), height: box.height * CGFloat(image.height))
        return image.cropping(to: rect.integral).map { UIImage(cgImage: $0) }
    }

    static func describe(_ match: MatchResult) -> String {
        guard let id = match.identityID else { return UNKNOWN }
        let distance = String(format: "%.2f", match.distance)
        return match.decision == .confident ? "\(id) (\(distance))" : "\(id)? (\(distance))"
    }
}

extension UIImage {
    /// Pixels redrawn so that orientation is `.up`, as FaceKit expects for `CGImage` input.
    func uprightCGImage() -> CGImage? {
        if imageOrientation == .up, let cgImage { return cgImage }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }.cgImage
    }
}
