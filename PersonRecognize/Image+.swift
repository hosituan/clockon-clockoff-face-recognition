//
//  UIImage+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/24/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Foundation

extension UIImage {
    func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: floor(newWidth),
                                           height: floor(newHeight)))
        self.draw(in: CGRect(x: 0,
                             y: 0,
                             width: newWidth,
                             height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension CIImage {
    func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        return UIImage(ciImage: self).resizeImage(newWidth: newWidth,
                                                  newHeight: newHeight)
    }
}
