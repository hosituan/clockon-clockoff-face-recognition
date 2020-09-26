//
//  HomeViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 09/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import ProgressHUD

class HomeViewController: UIViewController {
    
    var fps = 2
    private var generator:AVAssetImageGenerator!
    
    @IBOutlet weak var vectorsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        if NetworkChecker.isConnectedToInternet {
            ProgressHUD.show("Loading users...")
            fb.loadVector { [self] (result) in
                ProgressHUD.dismiss()
                kMeanVectors = result
                print("Numver of k-Mean vectors: \(kMeanVectors.count)")
                vectorsLabel.text = "You have \(kMeanVectors.count / 3) users."
                ProgressHUD.dismiss()
                
            }
            fb.loadLogTimes { (result) in
                attendList = result
                for user in attendList {
                    let u = User(name: user.name, image: UIImage(named: "LaunchImage")!, time: user.time)
                    localUserList.append(u)
                }
                
            }
        }
        else {
            //code for local data
//            print(savedUserList)
//            //kMeanVectors = splitVectorByName(vector: vectors)
//            vectorsLabel.text = "You have \(kMeanVectors.count / 3) users."
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        fnet.clean()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
        //vectors = []
        fnet.load()
    }
    
    @IBAction func tapStart(_ sender: UIButton) {
        self.performSegue(withIdentifier: "startPredict", sender: nil)
    }
    @IBAction func tapPredictImage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openPredictImage", sender: nil)
    }
    @IBAction func tapAddUser(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openAddUser", sender: nil)
    }
    @IBAction func tapViewData(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewFace", sender: nil)
    }
    @IBAction func tapViewLog(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewLog", sender: nil)
    }
    @IBAction func tapSyncData(_ sender: UIButton) {
        //        fb.loadVector { (result) in
        //            avgVectors = result
        //        }
        //print("uploading")
        //fb.uploadVector(vectors: avgVectors)
    }
    
}

