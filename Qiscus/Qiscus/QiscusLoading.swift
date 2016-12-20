//
//  QiscusLoading.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/20/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public extension UIViewController{
    public func showQiscusLoading(withText text:String? = nil, andProgress progress:Float? = nil, isBlocking:Bool = false){
        let loadingView = QLoadingViewController.sharedInstance
        if loadingView.isPresence{
            loadingView.dismiss(animated: false, completion: nil)
        }
        loadingView.modalTransitionStyle = .crossDissolve
        loadingView.modalPresentationStyle = .overCurrentContext
        loadingView.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        if text == nil {
            loadingView.loadingLabel.isHidden = true
            loadingView.loadingLabel.text = ""
        }else{
            loadingView.loadingLabel.isHidden = false
            loadingView.loadingLabel.text = text
        }
        loadingView.isBlocking = isBlocking
        if progress == nil{
            loadingView.percentageLabel.text = ""
            loadingView.percentageLabel.isHidden = true
        }else{
            let percentage:Int = Int(progress! * 100)
            loadingView.percentageLabel.text = "\(percentage)%"
            loadingView.percentageLabel.isHidden = false
        }
        loadingView.isPresence = true
        self.present(loadingView, animated: false)
    }
    public func dismissQiscusLoading(){
        let loadingView = QLoadingViewController.sharedInstance
        if loadingView.isPresence{
            loadingView.dismiss(animated: false, completion: nil)
        }
    }
}
