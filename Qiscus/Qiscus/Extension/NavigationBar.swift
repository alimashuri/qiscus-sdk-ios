//
//  NavigationBar.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

extension UINavigationItem {

    public func setTitleWithSubtitle(title title:String, subtitle : String){
        
        let titleLabel = UILabel(frame:CGRectMake(0, 0, 0, 0))
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame:CGRectMake(0, 18, 0, 0))
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(11)
        subTitleLabel.text = subtitle
        subTitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width,titleLabel.frame.size.width), 30))
        
        
        if titleLabel.frame.width >= subTitleLabel.frame.width {
            var adjustment = subTitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subTitleLabel.frame.width/2)
            subTitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subTitleLabel)
        
        self.titleView = titleView
    }

}
