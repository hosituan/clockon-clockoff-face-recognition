//
//  ViewLogViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 15/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import ProgressHUD

class ViewLogViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if NetworkChecker.isConnectedToInternet {
            ProgressHUD.show("Loading log times...")
            fb.loadLogTimes { (result) in
                attendList = result
                self.tableView.delegate = self
                self.tableView.dataSource = self
                ProgressHUD.dismiss()
            }
        }
        else {
            //code for local data
            showDialog(message: "You have not connected to internet. Using local data.")
        }

    }
    

}
extension ViewLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! LogTableViewCell
        if let url = URL(string: attendList[indexPath.row].imageURL) {
            cell.imgView.sd_setImage(with: url, completed: nil)
        }
        cell.nameLabel.text = attendList[indexPath.row].name
        cell.timeLabel.text = attendList[indexPath.row].time
        cell.confidenceLabel.text = "" //attendList[indexPath.row].confidence
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
}
