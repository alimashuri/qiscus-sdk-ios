//
//  Qiscus.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import ReachabilitySwift

public class Qiscus: NSObject {
    public static let sharedInstance = Qiscus()
    
    public var config = QiscusConfig.sharedInstance
    public var commentService = QiscusCommentClient.sharedInstance
    public var styleConfiguration = QiscusUIConfiguration.sharedInstance
    
    public var isPushed:Bool = false
    public var iCloudUpload:Bool = false
    
    public var httpRealTime:Bool = false
    public var inAppNotif:Bool = true
    
    public var reachability:Reachability?
    public var connected:Bool = false
    
    public class var style:QiscusUIConfiguration{
        get{
            return Qiscus.sharedInstance.styleConfiguration
        }
    }
    
    public class var commentService:QiscusCommentClient{
        get{
            return QiscusCommentClient.sharedInstance
        }
    }
    
    private override init() {}
    
    public class var bundle:NSBundle{
        get{
            let podBundle = NSBundle(forClass: Qiscus.self)
            
            if let bundleURL = podBundle.URLForResource("Qiscus", withExtension: "bundle") {
                return NSBundle(URL: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    public class func disableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = false
    }
    public class func enableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = true
    }
    public class func setConfiguration(baseURL:String, uploadURL: String = "", userEmail:String, userToken:String, rtKey:String, commentPerLoad:Int! = 10, headers: [String:String]? = nil){
        let config = QiscusConfig.sharedInstance
        
        config.BASE_URL = baseURL
        if uploadURL == "" {
            config.UPLOAD_URL = "\(baseURL)/upload"
        }else{
            config.UPLOAD_URL = uploadURL
        }
        config.USER_EMAIL = userEmail
        config.USER_TOKEN = userToken
        config.commentPerLoad = commentPerLoad
        config.requestHeader = headers
        config.PUSHER_KEY = rtKey
        
        Qiscus.setupReachability()
    }

    public class func chatView(withTopicId topicId:Int, readOnly:Bool = false, title:String = "Chat", subtitle:String = "")->QiscusChatVC{
        Qiscus.sharedInstance.isPushed = true
        QiscusUIConfiguration.sharedInstance.chatUsers = [String]()
        QiscusUIConfiguration.sharedInstance.topicId = topicId
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.chatTitle = title
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        return QiscusChatVC.sharedInstance
    }
    public class func chat(withTopicId topicId:Int, target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = [String]()
        QiscusUIConfiguration.sharedInstance.topicId = topicId
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.chatTitle = title

        let chatVC = QiscusChatVC.sharedInstance
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        target.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    public class func chat(withUsers users:[String], target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = users
        QiscusUIConfiguration.sharedInstance.topicId = 0
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.chatTitle = title
        
        let chatVC = QiscusChatVC.sharedInstance
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        target.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    public class func image(named name:String)->UIImage?{
        return UIImage(named: name, inBundle: Qiscus.bundle, compatibleWithTraitCollection: nil)
    }
    public class func unlockAction(action:(()->Void)){
        QiscusChatVC.sharedInstance.unlockAction = action
    }
    public class func showChatAlert(alertController alert:UIAlertController){
        QiscusChatVC.sharedInstance.showAlert(alert: alert)
    }
    public class func unlockChat(){
        QiscusChatVC.sharedInstance.unlockChat()
    }
    public class func lockChat(){
        QiscusChatVC.sharedInstance.lockChat()
    }
    public class func showLoading(text: String = "Loading ..."){
        QiscusChatVC.sharedInstance.showLoading(text)
    }
    public class func dismissLoading(){
        QiscusChatVC.sharedInstance.dismissLoading()
    }
    public class func setGradientChatNavigation(topColor:UIColor, bottomColor:UIColor, tintColor:UIColor){
        QiscusChatVC.sharedInstance.setGradientChatNavigation(withTopColor: topColor, bottomColor: bottomColor, tintColor: tintColor)
    }
    public class func setNavigationColor(color:UIColor, tintColor: UIColor){
        QiscusChatVC.sharedInstance.setNavigationColor(color, tintColor: tintColor)
    }
    public class func iCloudUploadActive(active:Bool){
        Qiscus.sharedInstance.iCloudUpload = active
        //QiscusChatVC.sharedInstance.documentButton.hidden = !active
    }
    public class func setHttpRealTime(rt:Bool = true){
        Qiscus.sharedInstance.httpRealTime = rt
    }
    
    public class func setupReachability(){
        do {
            Qiscus.sharedInstance.reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create reach Qiscus")
            return
        }
        
        if let reachable = Qiscus.sharedInstance.reachability {
            if reachable.isReachable() {
                Qiscus.sharedInstance.connected = true
                QiscusPusherClient.sharedInstance.PusherSubscribe()
                print("Qiscus is reachable")
            }
        }
        
        Qiscus.sharedInstance.reachability?.whenReachable = { reachability in
            
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Qiscus connected via wifi")
                } else {
                    print("Qiscus connected via cellular data")
                }
                Qiscus.sharedInstance.connected = true
                QiscusPusherClient.sharedInstance.pusher.connect()
                if QiscusChatVC.sharedInstance.isPresence {
                    print("try to sync after connected")
                    QiscusChatVC.sharedInstance.syncData()
                }
            }
        }
        Qiscus.sharedInstance.reachability?.whenUnreachable = { reachability in
            
            dispatch_async(dispatch_get_main_queue()) {
                print("Qiscus disconnected")
                Qiscus.sharedInstance.connected = false
            }
        }
        do {
            try  Qiscus.sharedInstance.reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
