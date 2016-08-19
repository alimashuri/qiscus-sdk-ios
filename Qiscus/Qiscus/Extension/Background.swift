//
//  Background.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/13/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

class Background: NSObject {

}

extension CAGradientLayer {
    class func gradientLayerForBounds(bounds: CGRect, topColor:UIColor, bottomColor:UIColor) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [topColor.CGColor, bottomColor.CGColor]
        return layer
    }
}

extension UINavigationBar {
    override public func verticalGradientColor(topColor:UIColor, bottomColor:UIColor){
        var updatedFrame = self.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame, topColor: topColor, bottomColor: bottomColor)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.barTintColor = UIColor.clearColor()
        self.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
    }
}