//
//  NetworkChecker.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 25/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkChecker {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
