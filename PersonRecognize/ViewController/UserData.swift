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
import ProgressHUD

class UserData: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!

    var value = ""
    var userList = [[String: Int]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if NetworkChecker.isConnectedToInternet {
            ProgressHUD.show("Loading users...")
            fb.loadUsers(completionHandler: { (result) in
                userDict = result
                for (key, value) in userDict {
                    let user = [key:value]
                    self.userList.append(user)
                }
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
//                savedUserList = result //for local user lists, use without internet.
//                defaults.set(savedUserList, forKey: SAVED_USERS)
                ProgressHUD.dismiss()
            })
        }
        else {
            //userList = savedUserList
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            ProgressHUD.dismiss()
            showDialog(message: "You have not connected to internet. Using local data.")
            
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFaceData" {
            let vc = segue.destination as! ViewFaceViewController
            vc.name = value
        }
    }
    @IBAction func tapGenerateAll(_ sender: UIBarButtonItem) {
        //Memory issue
//
//        for user in self.userList {
//            let queue = OperationQueue()
//            queue.maxConcurrentOperationCount = 10
//            ProgressHUD.show("Generating \(user)...")
//            queue.addBarrierBlock {
//                self.generate(valueSelected: user)
//            }
//        }
    }
    
}

extension UserData: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        cell.textLabel?.text = "\(userList[indexPath.row].values.first!). \(userList[indexPath.row].keys.first!)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        //let valueSelected = userList[indexPath.row]
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10

        ProgressHUD.show("Generating...")
        queue.addBarrierBlock {
            //add vector to All vectors list, and get Kmean Vectors
            //self.generate(valueSelected: valueSelected)
        }
        //value = valueSelected
        //self.performSegue(withIdentifier: "viewFaceData", sender: nil)
    }
    
    func generate(valueSelected: String) {
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


