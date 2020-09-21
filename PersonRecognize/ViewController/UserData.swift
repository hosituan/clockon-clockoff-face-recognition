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

class UserData: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var generator:AVAssetImageGenerator!
    var valueSelected = ""
    var userNameAdd = ""
    var userList:[String: String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        userDict = loadLabel()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFaceData" {
            let vc = segue.destination as! ViewFaceViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
            vc.title = "\(valueSelected) - \(currentCell.textLabel?.text ?? "Blank User")"
            vc.indexPath = indexPath!.row
        }
    }
    
    func loadData() {
        for i in 0..<30 {
            let label = "user\(i)"
            if userDict[label] != "" {
                userList[label] = userDict[label]
            }
        }
        
    }
    

}

extension UserData: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        cell.textLabel?.text = "\(indexPath.row). " + userList["user\(indexPath.row)"]!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueSelected = "user\(indexPath.row)"
        self.performSegue(withIdentifier: "viewFaceData", sender: nil)
    }
    
}


