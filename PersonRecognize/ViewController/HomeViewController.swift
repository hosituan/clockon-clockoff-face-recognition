//
//  HomeViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 09/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation
import RealmSwift

class HomeViewController: UIViewController {

    var fps = 2
    private var generator:AVAssetImageGenerator!
    
    @IBOutlet weak var vectorsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(savedUserList)
        vectors = vectorHelper.loadVector()
        print("Number of vectors: \(vectors.count)")
        //avgVectors = splitVectorByName(vector: vectors)
        numberOfVectors = vectors.count
        //vectors = []
        fb.loadVector { [self] (result) in
            avgVectors = result
            self.showDialog(message: "Loaded 27 users.")
            print("Numver of average vectors: \(avgVectors.count)")
            vectorsLabel.text = "You have \(avgVectors.count) users and \(numberOfVectors) vectors."
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        
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

