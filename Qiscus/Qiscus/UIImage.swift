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
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            return self
        }else{
            if let cgimage = self.cgImage {
                return UIImage(cgImage: cgimage, scale: 1, orientation:.upMirrored )
            }else{
                return self
            }
        }
    }
}
