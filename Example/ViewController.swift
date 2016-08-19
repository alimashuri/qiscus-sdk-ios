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
        print("go to chat")
        
        Qiscus.chat(withTopicId: 147, target: self,readOnly: false, title: "Coba", subtitle: "coba-coba")
    }
}

