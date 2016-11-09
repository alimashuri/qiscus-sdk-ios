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
        let button = UIButton(frame: CGRect(x: 50,y: 100,width: 200,height: 60))
        button.setTitle("Test Qiscus Chat", for: UIControlState())
        button.backgroundColor = UIColor.black
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(ViewController.goToChat), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goToChat(){
        let greyColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        Qiscus.style.color.leftBaloonColor = greyColor
        Qiscus.style.color.welcomeIconColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        Qiscus.style.color.leftBaloonTextColor = UIColor.white
        Qiscus.style.color.rightBaloonColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        Qiscus.style.color.rightBaloonTextColor = UIColor.white
        //Qiscus.setGradientChatNavigation(UIColor.black, bottomColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), tintColor: UIColor.white)
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
        Qiscus.chat(withUsers: ["e3@qiscus.com"] , target: self, distinctId: "penjual", optionalDataCompletion: { optionalData in
            print("optionalData from Example view: \(optionalData)")
        })
        //Qiscus.lockChat()
        
        //self.navigationController?.pushViewController(	chatView, animated: true)
    }
}

