//
//  Qiscus.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
//import ReachabilitySwift
import RealmSwift

open class Qiscus: NSObject {

    open static let sharedInstance = Qiscus()
    
    open var config = QiscusConfig.sharedInstance
    open var commentService = QiscusCommentClient.sharedInstance
    open var styleConfiguration = QiscusUIConfiguration.sharedInstance
    
    open var isPushed:Bool = false
    open var iCloudUpload:Bool = false
    
    open var httpRealTime:Bool = false
    open var inAppNotif:Bool = true
    
    open var reachability:QReachability?
    open var connected:Bool = false
    
    open class var isLoggedIn:Bool{
        get{
            if !Qiscus.sharedInstance.connected {
                Qiscus.setupReachability()
            }
            return QiscusMe.isLoggedIn
        }
    }
    
    open class var style:QiscusUIConfiguration{
        get{
            return Qiscus.sharedInstance.styleConfiguration
        }
    }
    
    open class var commentService:QiscusCommentClient{
        get{
            return QiscusCommentClient.sharedInstance
        }
    }
    
    fileprivate override init(){}
    
    open class var bundle:Bundle{
        get{
            let podBundle = Bundle(for: Qiscus.self)
            
            if let bundleURL = podBundle.url(forResource: "Qiscus", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    
    /**
     Class function to disable notification when **In App**
     */
    open class func disableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = false
    }
    /**
     Class function to enable notification when **In App**
     */
    open class func enableInAppNotif(){
        Qiscus.sharedInstance.inAppNotif = true
    }
    
    open class func clear(){
        QiscusMe.clear()
        QiscusComment.deleteAll()
    }
    
    // need Documentation
    open class func setup(withAppId appId:String, userEmail:String, userKey:String, username:String? = nil, avatarURL:String? = nil, delegate:QiscusConfigDelegate? = nil, secureURl:Bool = true){
        var requestProtocol = "https"
        if !secureURl {
            requestProtocol = "http"
        }
        let email = userEmail.lowercased()
        //QiscusConfig.sharedInstance.BASE_URL = "\(requestProtocol)://\(appId).qiscus.com/api/v2/mobile"
        let baseUrl = "\(requestProtocol)://\(appId).qiscus.com/api/v2/mobile"
        
        QiscusMe.sharedInstance.baseUrl = baseUrl
        QiscusMe.sharedInstance.userData.set(baseUrl, forKey: "qiscus_base_url")
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
     Class function to configure view chat
     - parameter topicId: **Int** ID of topic chat.
     - parameter readOnly: **Bool** to set read only or not (Optional), Default value : false.
     - parameter title: **String** text to show as chat title (Optional), Default value : "Chat".
     - parameter subtitle: **String** text to show as chat subtitle (Optional), Default value : "" (empty string).
     - returns: **QiscusChatVC**
     */
    open class func chatView(withTopicId topicId:Int, readOnly:Bool = false, title:String = "Chat", subtitle:String = "")->QiscusChatVC{
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
    open class func chat(withTopicId topicId:Int, target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        if !Qiscus.sharedInstance.connected {
            Qiscus.setupReachability()
        }
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
        
        target.navigationController?.present(navController, animated: true, completion: nil)
    }
    /**
     Class function to configure chat with user
     - parameter users: **String** users.
     - parameter target: The **UIViewController** where chat will appear.
     - parameter readOnly: **Bool** to set read only or not (Optional), Default value : false.
     - parameter title: **String** text to show as chat title (Optional), Default value : "Chat".
     - parameter subtitle: **String** text to show as chat subtitle (Optional), Default value : "" (empty string).
     */
    open class func chat(withUsers users:[String], target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = "", distinctId:String? = nil, optionalData:String?=nil,optionalDataCompletion: @escaping (String) -> Void){
        
        if !Qiscus.sharedInstance.connected {
            Qiscus.setupReachability()
        }
        
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = users
        QiscusUIConfiguration.sharedInstance.topicId = 0
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        
        
        let chatVC = QiscusChatVC.sharedInstance
        if distinctId != nil{
            chatVC.distincId = distinctId!
        }else{
            chatVC.distincId = ""
        }
        chatVC.optionalData = optionalData
        chatVC.optionalDataCompletion = optionalDataCompletion
        
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        target.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    // Need Documentation
    open class func chatView(withUsers users:[String], target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = "")->QiscusChatVC{
        if !Qiscus.sharedInstance.connected {
            Qiscus.setupReachability()
        }
        Qiscus.sharedInstance.isPushed = false
        QiscusUIConfiguration.sharedInstance.chatUsers = users
        QiscusUIConfiguration.sharedInstance.topicId = 0
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        
        let chatVC = QiscusChatVC.sharedInstance
        let navController = UINavigationController()
        navController.viewControllers = [chatVC]
        
        if QiscusChatVC.sharedInstance.isPresence {
            QiscusChatVC.sharedInstance.goBack()
        }
        
        return QiscusChatVC.sharedInstance
    }
    open class func image(named name:String)->UIImage?{
        return UIImage(named: name, in: Qiscus.bundle, compatibleWith: nil)
    }
    /**
     Class function to unlock action chat
     - parameter action: **()->Void** as unlock action for your chat
     */
    open class func unlockAction(_ action:@escaping (()->Void)){
        QiscusChatVC.sharedInstance.unlockAction = action
    }
    /**
     Class function to show alert in chat with UIAlertController
     - parameter alert: The **UIAlertController** to show alert message in chat
     */
    open class func showChatAlert(alertController alert:UIAlertController){
        QiscusChatVC.sharedInstance.showAlert(alert: alert)
    }
    /**
     Class function to unlock chat
     */
    open class func unlockChat(){
        QiscusChatVC.sharedInstance.unlockChat()
    }
    /**
     Class function to lock chat
     */
    open class func lockChat(){
        QiscusChatVC.sharedInstance.lockChat()
    }
    /**
     Class function to show loading message
     - parameter text: **String** text to show as loading text (Optional), Default value : "Loading ...".
     */
    open class func showLoading(_ text: String = "Loading ..."){
        QiscusChatVC.sharedInstance.showLoading(text)
    }
    /**
     Class function to hide loading 
     */
    open class func dismissLoading(){
        QiscusChatVC.sharedInstance.dismissLoading()
    }
    /**
     Class function to set color chat navigation with gradient
     - parameter topColor: The **UIColor** as your top gradient navigation color.
     - parameter bottomColor: The **UIColor** as your bottom gradient navigation color.
     - parameter tintColor: The **UIColor** as your tint gradient navigation color.
     */
    open class func setGradientChatNavigation(_ topColor:UIColor, bottomColor:UIColor, tintColor:UIColor){
        QiscusChatVC.sharedInstance.setGradientChatNavigation(withTopColor: topColor, bottomColor: bottomColor, tintColor: tintColor)
        QPopUpView.sharedInstance.topColor = topColor
        QPopUpView.sharedInstance.bottomColor = bottomColor
    }
    /**
     Class function to set color chat navigation without gradient
     - parameter color: The **UIColor** as your navigation color.
     - parameter tintColor: The **UIColor** as your tint navigation color.
     */
    open class func setNavigationColor(_ color:UIColor, tintColor: UIColor){
        QiscusChatVC.sharedInstance.setNavigationColor(color, tintColor: tintColor)
    }
    /**
     Class function to set upload from iCloud active or not
     - parameter active: **Bool** to set active or not.
     */
    open class func iCloudUploadActive(_ active:Bool){
        Qiscus.sharedInstance.iCloudUpload = active
        //QiscusChatVC.sharedInstance.documentButton.hidden = !active
    }
    open class func setHttpRealTime(_ rt:Bool = true){
        Qiscus.sharedInstance.httpRealTime = rt
    }
    
    open class func setupReachability(){
//        do {
            Qiscus.sharedInstance.reachability = QReachability()
//        } catch {
//            print("Unable to create reach Qiscus")
//            return
//        }
        
        if let reachable = Qiscus.sharedInstance.reachability {
            if reachable.isReachable {
                Qiscus.sharedInstance.connected = true
                QiscusPusherClient.sharedInstance.PusherSubscribe()
                print("Qiscus is reachable")
            }
        }
        
        Qiscus.sharedInstance.reachability?.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
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
            
            DispatchQueue.main.async {
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
