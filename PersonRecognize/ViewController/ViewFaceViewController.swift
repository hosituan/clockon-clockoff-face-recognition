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
    var indexPath = 0
    var imgList:[UIImage?] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        imgList = trainingDataset.getImage(label: "user\(indexPath)")
        self.title = "\(imgList.count)"
        print("user\(indexPath)")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        let url = documentDirectory.appendingPathComponent("train").appendingPathComponent("user\(indexPath)")
        removeIfExists(at: url)
        saveLabel(at: "user\(indexPath)", value: "")
        showDialog(message: "Cleared!")
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

