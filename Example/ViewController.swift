//
//  ViewController.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import Qiscus
import SJProgressHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Qiscus Test"
        let button = UIButton(frame: CGRectMake(50,100,200,60))
        button.setTitle("Test Qiscus Chat", forState: .Normal)
        button.backgroundColor = UIColor.blackColor()
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(ViewController.goToChat), forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goToChat(){
        let greyColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        Qiscus.style.color.leftBaloonColor = greyColor
        Qiscus.style.color.welcomeIconColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        Qiscus.style.color.leftBaloonTextColor = UIColor.whiteColor()
        Qiscus.style.color.rightBaloonColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        Qiscus.style.color.rightBaloonTextColor = UIColor.whiteColor()
        Qiscus.setGradientChatNavigation(UIColor.blackColor(), bottomColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), tintColor: UIColor.whiteColor())
//        Qiscus.iCloudUploadActive(true)
//        Qiscus.style.rightBaloonTextColor = UIColor.whiteColor()
//        Qiscus.style.rightBaloonLinkColor = UIColor.whiteColor()
//        Qiscus.style.lockViewTintColor = UIColor.whiteColor()
        
       // let chatView = Qiscus.chatView(withTopicId: 133, readOnly: true, subtitle:"Welcome to haloo")
        
//        Qiscus.unlockAction({
//            print("unlocking")
//            let title = "Coba Alert"
//            let message = "Cuma buat coba-coba"
//            
//            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//
//            // Create the actions
//            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) {
//                alertAction in
//                //Qiscus.showLoading()
//                print("Nah lo di cancel")
//            }
//            let topUpAction = UIAlertAction(title: "Ngapain", style: .Default, handler: {
//                alertAction in
//                print("Ngapain hayoooooo .....")
//                Qiscus.unlockChat()
//            })
//            // Add the actions
//            alertController.addAction(okAction)
//            alertController.addAction(topUpAction)
//            Qiscus.showChatAlert(alertController: alertController)
//        })
        //Qiscus.setGradientChatNavigation(UIColor.greenColor(), bottomColor: UIColor.blueColor(), tintColor: UIColor.whiteColor())
        //Qiscus.iCloudUploadActive(true)

        //Qiscus.chat(withTopicId: 133, target: self, readOnly: true)
        
        let alert = UIAlertController(title: "Select Target", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "Dragonfly 1", style: .Default) { (action) in
            let options: [String: AnyObject] = [
                "name": "dragonfly1",
                "id": 1
            ]
            
            SJProgressHUD.showWaiting("Loading chat...", autoRemove: false)
            
            Qiscus.chat(withUsers: ["e3@qiscus.com"], target: self, distinctID: "dragonfly1", options: options, prepareHandler: { chatVC in
                SJProgressHUD.dismiss()
            })
        }
        
        let secondAction = UIAlertAction(title: "Dragonfly 2", style: .Default) { (action) in
            let options: [String: AnyObject] = [
                "name": "dragonfly2",
                "id": 2
            ]
            
            SJProgressHUD.showWaiting("Loading chat...", autoRemove: false)
            
            Qiscus.chat(withUsers: ["e3@qiscus.com"], target: self, distinctID: "dragonfly2", options: options, prepareHandler: { chatVC in
                SJProgressHUD.dismiss()
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        //Qiscus.lockChat()
        
        //self.navigationController?.pushViewController(	chatView, animated: true)
    }
}

