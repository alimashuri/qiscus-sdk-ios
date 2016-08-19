//
//  UIImage.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

extension UIImage {
    func localizedImage()->UIImage{
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .LeftToRight {
            return self
        }else{
            if let cgimage = self.CGImage {
                return UIImage(CGImage: cgimage, scale: 1, orientation:.UpMirrored )
            }else{
                return self
            }
        }
    }
}
