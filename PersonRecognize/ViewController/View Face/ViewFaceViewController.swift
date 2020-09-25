//
//  FaceCutViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 03/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

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
        
//        vectorHelper.addVector(name: name)
//        avgVectors = vectorHelper.loadVector()
//        fb.uploadVector(vectors: avgVectors)
//        let url = documentDirectory.appendingPathComponent("train").appendingPathComponent("user\(indexPath)")
//        removeIfExists(at: url)
//        saveLabel(at: "user\(indexPath)", value: "")
//        showDialog(message: "Cleared!")
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

