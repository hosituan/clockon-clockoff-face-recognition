//
//  ViewLogViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 15/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

class ViewLogViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    

}
extension ViewLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! LogTableViewCell
        cell.imgView.image = attendList[indexPath.row].image
        cell.nameLabel.text = attendList[indexPath.row].name
        cell.timeLabel.text = attendList[indexPath.row].time
        cell.confidenceLabel.text = "" //attendList[indexPath.row].confidence
        return cell
    }
    
    
}
