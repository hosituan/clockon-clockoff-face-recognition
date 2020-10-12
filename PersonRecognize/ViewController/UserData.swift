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
import SkyFloatingLabelTextField
import RxCocoa
import RxSwift

class UserData: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var findName: SkyFloatingLabelTextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    //    var searchInput = BehaviorRelay<String?>(value: "")
    var searchResult = BehaviorRelay<[[String: Int]]>(value: [])
    let dispose = DisposeBag()
    
    
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
                self.userList = self.userList.sorted(by: { $0.values.first! < $1.values.first!})
                self.tableView.delegate = self
                self.bindUI()
                //savedUserList = result //for local user lists, use without internet.
                //defaults.set(savedUserList, forKey: SAVED_USERS)
                ProgressHUD.dismiss()
            })
        }
        else {
            //userList = savedUserList
            self.tableView.delegate = self
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

extension UserData: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let valueSelected = self.userList[indexPath.row].keys.first! as String
        let alert = UIAlertController(title: "Select Action", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Generate Vector", style: .default, handler: { action in
            
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 10
            
            ProgressHUD.show("Generating...")
            queue.addBarrierBlock {
                //add vector to All vectors list, and get Kmean Vectors
                self.generate(valueSelected: valueSelected)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "View Face", style: .default, handler: { action in
            self.value = valueSelected
            self.performSegue(withIdentifier: "viewFaceData", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func generate(valueSelected: String) {
        vectorHelper.addVector(name: valueSelected) { result in
            print("All vectors for \(valueSelected): \(result.count)")
            if result.count > 0 {
                fb.loadAllVector(name: valueSelected) { oldVectors in
                    print("Old vector: \(oldVectors.count)")
                    let allVector = oldVectors + result
                    let a = allVector.uniq()
                    print("New vector:\(a.count)")
                    getKMeanVectorSameName(vectors: a) { (vectors) in
                        print("K-mean vector for \(valueSelected): \(vectors.count)")
                        fb.uploadKMeanVectors(vectors: vectors, child: KMEAN_VECTOR) {
                            ProgressHUD.dismiss()
                            self.showDialog(message: "Upload data for \(valueSelected) by \(a.count) vectors.")
                            fb.uploadAllVectors(vectors: a, child: ALL_VECTOR) {
                            }
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

extension UserData {
    
    func bindUI()  {
        findName.rx.text
            .orEmpty
            .subscribe(onNext: { query in
                self.searchResult.accept(self.userList.filter { $0.keys.first!.lowercased().hasPrefix(query.lowercased()) })
            })
        
        searchResult
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cellID",
                                         cellType: UITableViewCell.self)) { row, data, cell in
                cell.textLabel?.text = "\(data.values.first!). \(data.keys.first!)"
            }
            .disposed(by: dispose)
    }
}


