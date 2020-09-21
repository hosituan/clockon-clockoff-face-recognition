//
//  ImageDataset.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 31/08/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import CoreML

class ImageDataset {
    enum Split {
        case train
        case test
        var folderName: String {
            self == .train ? "train" : "test"
        }
    }
    
    let split: Split
    
    let smallestSide = 224
    
    private let baseURL: URL
    
    init(split: Split) {
        self.split = split
        baseURL = applicationDocumentsDirectory.appendingPathComponent(split.folderName)
        createDatasetFolder()
    }
    //var count: Int { getImage().count }
    private func createDatasetFolder() {
        print("Path for \(split): \(baseURL)")
        createDirectory(at: baseURL)
    }
}

// MARK: - Mutating the dataset

extension ImageDataset {
    func saveImage(_ image: UIImage, for label: String) {
        let fileName = UUID().uuidString + ".jpg"
        createDirectory(at: documentDirectory.appendingPathComponent(split.folderName).appendingPathComponent(label))
        let fileURL = documentDirectory.appendingPathComponent(split.folderName).appendingPathComponent(label).appendingPathComponent(fileName)
        //print(fileName)
        if let image = image.resized(smallestSide: smallestSide), let data = image.jpegData(compressionQuality:  1.0),
           !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("saved at \(fileURL)")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    func getImage(label: String) -> [UIImage?] {
        var imageUrl: [URL] = []
        var imageList:[UIImage] = []
        let url = documentDirectory.appendingPathComponent(split.folderName).appendingPathComponent(label)
        imageUrl.append(contentsOf: contentsOfDirectory(at: url) { url in
            url.pathExtension == "jpg" || url.pathExtension == "png"
        })
        
        for i in 0..<imageUrl.count
        {
            let image = UIImage(contentsOfFile: imageUrl[i].path)
            imageList.append(image!)
        }
        return imageList
        
    }
    private func loadModel(url: URL) -> MLModel? {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            return try MLModel(contentsOf: url, configuration: config)
        } catch {
            print("Error loading model: \(error)")
            return nil
        }
    }
}
