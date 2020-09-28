//
//  FaceCutViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 03/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import ProgressHUD

class ViewFaceViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    var name = ""
    var imgList:[UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgList = trainingDataset.getImage(label: name)
        print(name)
        self.title = "\(name): \(imgList.count)"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func generateVector(_ sender: UIBarButtonItem) {
        let valueSelected = self.name
        vectorHelper.addVector(name: valueSelected) { result in
            print("All vectors for \(valueSelected): \(result.count)")
            if result.count > 0 {
                getKMeanVectorSameName(vectors: result) { (vectors) in
                    print("K-mean vector for \(valueSelected): \(vectors.count)")
                    fb.uploadKMeanVectors(vectors: vectors, child: KMEAN_VECTOR) {
                        ProgressHUD.dismiss()
                        self.showDialog(message: "Upload data for \(valueSelected) by \(result.count) vectors.")
                        fb.uploadAllVectors(vectors: result, child: ALL_VECTOR) {
                        }
                    }
                }
            }
            else {
                ProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.showDialog(message: "This user is not in your local data.")
                }
                
            }
        }

    }
    
    
}

extension ViewFaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? CustomTableViewCell
        cell?.imageView?.image = imgList[indexPath.row]
        return cell!
    }
}

