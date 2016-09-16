//
//  Qiscus.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import ReachabilitySwift
import RealmSwift

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
    
    public class var isLoggedIn:Bool{
        get{
            return QiscusMe.isLoggedIn
        }
    }
    
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
    
    private override init(){}
    
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
    
    /**
     Class function to disable notification when **In App**
     */
    public class func disableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = false
    }
    /**
     Class function to enable notification when **In App**
     */
    public class func enableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = true
    }
    
    public class func clear(){
        QiscusMe.clear()
        QiscusComment.deleteAll()
    }
    
    // need Documentation
    public class func setup(withAppId appId:String, userEmail:String, userKey:String, username:String? = nil, avatarURL:String? = nil, delegate:QiscusConfigDelegate? = nil, secureURl:Bool = true){
        var requestProtocol = "https"
        if !secureURl {
            requestProtocol = "http"
        }
        let email = userEmail.lowercaseString
        QiscusConfig.sharedInstance.BASE_URL = "\(requestProtocol)://\(appId).qiscus.com/api/v2/mobile"
        if delegate != nil {
            QiscusCommentClient.sharedInstance.configDelegate = delegate
        }
        var needLogin = false
        print("QiscusMe.isLoggedIn: \(QiscusMe.isLoggedIn)")
        print("QiscusMe.sharedInstance.email: \(QiscusMe.sharedInstance.email)")
        print("userEmail: \(userEmail)")
        if QiscusMe.isLoggedIn {
            if email != QiscusMe.sharedInstance.email{
                needLogin = true
            }
        }else{
            needLogin = true
        }
        
        if needLogin {
            Qiscus.clear()
            QiscusCommentClient.sharedInstance.loginOrRegister(userEmail, password: userKey, username: username, avatarURL: avatarURL)
        }else{
            if QiscusCommentClient.sharedInstance.configDelegate != nil {
                Qiscus.setupReachability()
                QiscusCommentClient.sharedInstance.configDelegate!.qiscusConnected()
            }
        }
    }
    
    /**
     Class function to configure base URL, upload URL, user email, user token, comment per load, request header, and pusher key
     - parameter baseURL: **String** URL of your base server.
     - parameter uploadURL: **String** URL of your upload file (Optional), Default value : "" (empty string).
     - parameter userEmail: **String** email of user.
     - parameter userToken: **String** token of user.
     - parameter rtKey: **String** key of pusher.
     - parameter commentPerLoad: **Int** to show any comment per load (Optional), Default value : 10.
     - parameter headers: **String** headers (Optional), Default value : nil.
     */
    public class func setConfiguration(baseURL:String, uploadURL: String = "", userEmail:String, userToken:String, rtKey:String, commentPerLoad:Int! = 10, headers: [String:String]? = nil){
        let config = QiscusConfig.sharedInstance
        config.BASE_URL = baseURL
        if uploadURL == "" {
            config.UPLOAD_URL = "\(baseURL)/upload"
        }else{
            config.UPLOAD_URL = uploadURL
        }
        config.commentPerLoad = commentPerLoad
        config.requestHeader = headers
        config.setUserConfig(withEmail: userEmail, userKey: userToken, rtKey: rtKey)
        Qiscus.setupReachability()
    }

    /**
     Class function to configure view chat
     - parameter topicId: **Int** ID of topic chat.
     - parameter readOnly: **Bool** to set read only or not (Optional), Default value : false.
     - parameter title: **String** text to show as chat title (Optional), Default value : "Chat".
     - parameter subtitle: **String** text to show as chat subtitle (Optional), Default value : "" (empty string).
     - returns: **QiscusChatVC**
     */
    public class func chatView(withTopicId topicId:Int, readOnly:Bool = false, title:String = "Chat", subtitle:String = "")->QiscusChatVC{
        Qiscus.sharedInstance.isPushed = true
        QiscusUIConfiguration.sharedInstance.chatUsers = [String]()
        QiscusUIConfiguration.sharedInstance.topicId = topicId
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        return QiscusChatVC.sharedInstance
    }
    
    /**
     Class function to configure chat with topic ID
     - parameter topicId: **Int** ID of topic chat.
     - parameter target: The **UIViewController** where chat will appear.
     - parameter readOnly: **Bool** to set read only or not (Optional), Default value : false.
     - parameter title: **String** text to show as chat title (Optional), Default value : "Chat".
     - parameter subtitle: **String** text to show as chat subtitle (Optional), Default value : "" (empty string).
     */
    public class func chat(withTopicId topicId:Int, target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = [String]()
        QiscusUIConfiguration.sharedInstance.topicId = topicId
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title

        let chatVC = QiscusChatVC.sharedInstance
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        target.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    /**
     Class function to configure chat with user
     - parameter users: **String** users.
     - parameter target: The **UIViewController** where chat will appear.
     - parameter readOnly: **Bool** to set read only or not (Optional), Default value : false.
     - parameter title: **String** text to show as chat title (Optional), Default value : "Chat".
     - parameter subtitle: **String** text to show as chat subtitle (Optional), Default value : "" (empty string).
     */
    public class func chat(withUsers users:[String], target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = users
        QiscusUIConfiguration.sharedInstance.topicId = 0
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        
        
        let chatVC = QiscusChatVC.sharedInstance
        chatVC.comment = [[QiscusComment]]()
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        target.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    // Need Documentation
    public class func chatView(withUsers users:[String], target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = "")->QiscusChatVC{
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = users
        QiscusUIConfiguration.sharedInstance.topicId = 0
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        
        let chatVC = QiscusChatVC.sharedInstance
        chatVC.comment = [[QiscusComment]]()
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        return QiscusChatVC.sharedInstance
    }
    public class func image(named name:String)->UIImage?{
        return UIImage(named: name, inBundle: Qiscus.bundle, compatibleWithTraitCollection: nil)
    }
    /**
     Class function to unlock action chat
     - parameter action: **()->Void** as unlock action for your chat
     */
    public class func unlockAction(action:(()->Void)){
        QiscusChatVC.sharedInstance.unlockAction = action
    }
    /**
     Class function to show alert in chat with UIAlertController
     - parameter alert: The **UIAlertController** to show alert message in chat
     */
    public class func showChatAlert(alertController alert:UIAlertController){
        QiscusChatVC.sharedInstance.showAlert(alert: alert)
    }
    /**
     Class function to unlock chat
     */
    public class func unlockChat(){
        QiscusChatVC.sharedInstance.unlockChat()
    }
    /**
     Class function to lock chat
     */
    public class func lockChat(){
        QiscusChatVC.sharedInstance.lockChat()
    }
    /**
     Class function to show loading message
     - parameter text: **String** text to show as loading text (Optional), Default value : "Loading ...".
     */
    public class func showLoading(text: String = "Loading ..."){
        QiscusChatVC.sharedInstance.showLoading(text)
    }
    /**
     Class function to hide loading 
     */
    public class func dismissLoading(){
        QiscusChatVC.sharedInstance.dismissLoading()
    }
    /**
     Class function to set color chat navigation with gradient
     - parameter topColor: The **UIColor** as your top gradient navigation color.
     - parameter bottomColor: The **UIColor** as your bottom gradient navigation color.
     - parameter tintColor: The **UIColor** as your tint gradient navigation color.
     */
    public class func setGradientChatNavigation(topColor:UIColor, bottomColor:UIColor, tintColor:UIColor){
        QiscusChatVC.sharedInstance.setGradientChatNavigation(withTopColor: topColor, bottomColor: bottomColor, tintColor: tintColor)
    }
    /**
     Class function to set color chat navigation without gradient
     - parameter color: The **UIColor** as your navigation color.
     - parameter tintColor: The **UIColor** as your tint navigation color.
     */
    public class func setNavigationColor(color:UIColor, tintColor: UIColor){
        QiscusChatVC.sharedInstance.setNavigationColor(color, tintColor: tintColor)
    }
    /**
     Class function to set upload from iCloud active or not
     - parameter active: **Bool** to set active or not.
     */
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
