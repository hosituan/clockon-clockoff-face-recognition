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
        
        vectors = vectorHelper.loadVector()
        print("Number of vectors in your device: \(vectors.count)")
        numberOfVectors = vectors.count
        
        if NetworkChecker.isConnectedToInternet {
            ProgressHUD.show("Loading users...")
            fb.loadVector { [self] (result) in
                avgVectors = result
                print("Numver of average vectors: \(avgVectors.count)")
                vectorsLabel.text = "You have \(avgVectors.count) users."
                ProgressHUD.dismiss()
            }
            fb.loadLogTimes { (result) in
                attendList = result
            }
        }
        else {
            //code for local data
            print(savedUserList)
            avgVectors = splitVectorByName(vector: vectors)
            vectorsLabel.text = "You have \(avgVectors.count) users."
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        fnet.clean()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
        vectors = []
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

