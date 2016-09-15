//
//  QiscusMe.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/8/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import SwiftyJSON

public class QiscusMe: NSObject {
    static let sharedInstance = QiscusMe()
    
    let userData = NSUserDefaults.standardUserDefaults()
    
    public class var isLoggedIn:Bool {
        get{
            return (QiscusMe.sharedInstance.token != "")
        }
    }
    public class var canReconnect:Bool{
        get{
            return (QiscusMe.sharedInstance.userKey != "" && QiscusMe.sharedInstance.email != "")
        }
    }
    public var id = 0
    public var email = ""
    public var userName = ""
    public var avatarUrl = ""
    public var rtKey = ""
    public var token = ""
    public var userKey = ""
    
    private override init(){
        let userData = NSUserDefaults.standardUserDefaults()
        if let userId = userData.valueForKey("qiscus_id") as? Int {
            self.id = userId
        }
        if let userEmail = userData.valueForKey("qiscus_email") as? String {
            self.email = userEmail
        }
        if let name = userData.valueForKey("qiscus_username") as? String {
            self.userName = name
        }
        if let avatar = userData.valueForKey("qiscus_avatar_url") as? String {
            self.avatarUrl = avatar
        }
        if let key = userData.valueForKey("qiscus_rt_key") as? String {
            self.rtKey = key
        }
        if let userToken = userData.valueForKey("qiscus_token") as? String {
            self.token = userToken
        }
        if let key = userData.valueForKey("qiscus_user_key") as? String{
            self.userKey = key
        }
    }


    public class func saveData(fromJson json:JSON)->QiscusMe{
        print("jsonFron saveData: \(json)")
        QiscusMe.sharedInstance.id = json["id"].intValue
        QiscusMe.sharedInstance.email = json["email"].stringValue
        QiscusMe.sharedInstance.userName = json["username"].stringValue
        QiscusMe.sharedInstance.avatarUrl = json["avatar"].stringValue
        QiscusMe.sharedInstance.rtKey = json["rtKey"].stringValue
        QiscusMe.sharedInstance.token = json["token"].stringValue
        
        QiscusMe.sharedInstance.userData.setInteger(json["id"].intValue, forKey: "qiscus_id")
        QiscusMe.sharedInstance.userData.setObject(json["email"].stringValue, forKey: "qiscus_email")
        QiscusMe.sharedInstance.userData.setObject(json["username"].stringValue, forKey: "qiscus_username")
        QiscusMe.sharedInstance.userData.setObject(json["avatar"].stringValue, forKey: "qiscus_avatar_url")
        QiscusMe.sharedInstance.userData.setObject(json["rtKey"].stringValue, forKey: "qiscus_rt_key")
        QiscusMe.sharedInstance.userData.setObject(json["token"].stringValue, forKey: "qiscus_token")
        
        return QiscusMe.sharedInstance
    }
    
    public class func clear(){
        QiscusMe.sharedInstance.id = 0
        QiscusMe.sharedInstance.email = ""
        QiscusMe.sharedInstance.userName = ""
        QiscusMe.sharedInstance.avatarUrl = ""
        QiscusMe.sharedInstance.rtKey = ""
        QiscusMe.sharedInstance.token = ""
        
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_id")
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_email")
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_username")
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_avatar_url")
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_rt_key")
        QiscusMe.sharedInstance.userData.removeObjectForKey("qiscus_token")
    }
    
}
