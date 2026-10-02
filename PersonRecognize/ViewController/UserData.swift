//
//  AddUserViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import FaceKit
import UIKit
import MobileCoreServices
import AVFoundation
import ProgressHUD
import SkyFloatingLabelTextField
import RxCocoa
import RxSwift

class UserData: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var findName: SkyFloatingLabelTextField!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        // Rows show the filtered search result, not the full list.
        let valueSelected = self.searchResult.value[indexPath.row].keys.first! as String
        let alert = UIAlertController(title: "Select Action", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Generate Vector", style: .default, handler: { action in
            self.generate(valueSelected: valueSelected)
        }))
        alert.addAction(UIAlertAction(title: "View Face", style: .default, handler: { action in
            self.value = valueSelected
            self.performSegue(withIdentifier: "viewFaceData", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// Re-enrolls the user from the photos saved on this device and uploads the templates.
    func generate(valueSelected: String) {
        ProgressHUD.show("Generating...")
        Task { @MainActor in
            do {
                let identity = try await FaceService.shared.enrollFromLocalImages(name: valueSelected)
                ProgressHUD.dismiss()
                self.showDialog(message: "Uploaded \(identity.templates.count) templates for \(valueSelected).")
            } catch FaceKitError.noUsableFaces {
                ProgressHUD.dismiss()
                self.showDialog(message: "No face photos of this user in your local data.")
            } catch {
                ProgressHUD.dismiss()
                self.showDialog(message: "Could not generate data for \(valueSelected): \(error.localizedDescription)")
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
            .disposed(by: dispose)

        searchResult
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cellID",
                                         cellType: UITableViewCell.self)) { row, data, cell in
                cell.textLabel?.text = "\(data.values.first!). \(data.keys.first!)"
            }
            .disposed(by: dispose)
    }
}


