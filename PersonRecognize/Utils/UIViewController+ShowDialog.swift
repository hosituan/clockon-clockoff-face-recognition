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
}

