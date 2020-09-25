//
//  AddUserViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Vision
import MobileCoreServices
import AVFoundation
import FaceCropper
import MBProgressHUD

class UserData: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var generator:AVAssetImageGenerator!
    var valueSelected = ""
    //var userList:[String: String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFaceData" {
            let vc = segue.destination as! ViewFaceViewController
            vc.name = valueSelected
        }
    }
    
    
    
}

extension UserData: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savedUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        cell.textLabel?.text = savedUserList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueSelected = savedUserList[indexPath.row]
        vectorHelper.addVector(name: valueSelected)
        avgVectors = vectorHelper.loadVector()
        fb.uploadVector(vectors: avgVectors, child: "Vectors")
        fb.uploadVector(vectors: vectors, child: "All vectors")
//        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
//        loadingNotification.mode = MBProgressHUDMode.indeterminate
//        loadingNotification.label.text = "Generating..."
        
        //vectorHelper.addVector(name: valueSelected)
        
        //MBProgressHUD.hide(for: self.view, animated: true)
        //self.performSegue(withIdentifier: "viewFaceData", sender: nil)
    }
    
}


