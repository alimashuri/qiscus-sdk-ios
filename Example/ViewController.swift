//
//  ViewController.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import Qiscus

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
        Qiscus.style.rightBaloonColor = UIColor.blueColor()
        Qiscus.style.rightBaloonTextColor = UIColor.whiteColor()
        Qiscus.iCloudUploadActive(true)
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
        Qiscus.chat(withUsers: ["osi@tes.com"], target: self)
        //Qiscus.lockChat()
        
        //self.navigationController?.pushViewController(	chatView, animated: true)
    }
}

