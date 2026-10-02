//
//  HomeViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 09/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import ProgressHUD


class HomeViewController: UIViewController {

    @IBOutlet weak var vectorsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if !NetworkChecker.isConnectedToInternet {
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        updateUserCount()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
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
        loadData()
        if !NetworkChecker.isConnectedToInternet {
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }

    /// Online: replace local face templates with the server copy. Offline: keep the local store.
    func loadData() {
        guard NetworkChecker.isConnectedToInternet else {
            updateUserCount()
            return
        }
        ProgressHUD.show("Loading users...")
        Task { @MainActor in
            do {
                let count = try await FaceService.shared.syncFromServer()
                print("Number of enrolled faces: \(count)")
            } catch {
                print("Sync failed, using local data: \(error)")
            }
            updateUserCount()
            ProgressHUD.dismiss()
        }
        fb.loadUsers(completionHandler: { (result) in
            userDict = result
            print("Number of users: \(userDict.count)")
        })
    }

    private func updateUserCount() {
        Task { @MainActor in
            let count = await FaceService.shared.identityCount()
            vectorsLabel.text = "You have \(count) users."
        }
    }

}
