//
//  UIViewController+ShowDialog.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 23/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation

extension UIViewController {
    func showDialog(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showDiaglog3s(name: String,_ success: Bool) {
        let title = success == false ?  "Can't join!" : "Joining..."
        let alert = UIAlertController(title: title, message: "\(name)", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

