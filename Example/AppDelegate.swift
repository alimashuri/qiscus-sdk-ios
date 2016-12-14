//
//  AppDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import CoreData
import Qiscus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, QiscusConfigDelegate {
    
    var window: UIWindow?
    var navController = UINavigationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .black
        
        self.navController.navigationBar.tintColor = UIColor.white
        self.navController.navigationBar.backgroundColor = UIColor.green
        
        let viewController = ViewController()
        
        let topColor = UIColor(red: 8/255.0, green: 153/255.0, blue: 140/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 23/255.0, green: 177/255.0, blue: 149/255.0, alpha: 1)
        self.navController.navigationBar.verticalGradientColor(topColor, bottomColor: bottomColor)
        self.navController.pushViewController(viewController, animated: true)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.navController
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        

        Qiscus.setup(withAppId: "dragonfly", userEmail: "081212962117@qiscuswa.com", userKey: "26407cd298d88c131ff98d48201312c6", username: "Athaullah", avatarURL: "https://qiscuss3.s3.amazonaws.com/uploads/db5cbfe427dbeca6026d57c047074866/qiscus-dp.png", delegate: self, secureURl: false)
        Qiscus.sharedInstance.toastMessageAct = { roomId, comment in
            print("roomId: \(roomId)")
            print("commentText: \(comment.commentText)")
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - QiscusConfigDelegate
    func qiscusFailToConnect(_ withMessage:String){
        print(withMessage)
    }
    func qiscusConnected(){
        print("Chat server connected")
    }
}

