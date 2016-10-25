//
//  NavigationBar.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

extension UINavigationItem {

    public func setTitleWithSubtitle(title:String, subtitle : String){
        
        let titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame:CGRect(x: 0, y: 18, width: 0, height: 0))
        subTitleLabel.backgroundColor = UIColor.clear
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.font = UIFont.systemFont(ofSize: 11)
        subTitleLabel.text = subtitle
        subTitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(subTitleLabel.frame.size.width,titleLabel.frame.size.width), height: 30))
        
        
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
