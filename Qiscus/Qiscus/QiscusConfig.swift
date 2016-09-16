//
//  QiscusConfig.swift
//  LinkDokter
//
//  Created by Qiscus on 3/2/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public class QiscusConfig: NSObject {
    
    static let sharedInstance = QiscusConfig()
    
    public var commentPerLoad:Int = 10
    
    public var UPLOAD_URL = ""
    
    public var BASE_URL:String{
        get{
            return QiscusMe.sharedInstance.baseUrl
        }
    }
    public var USER_EMAIL:String{
        get{
            return QiscusMe.sharedInstance.email
        }
    }
    public var USER_TOKEN:String{
        get{
            return QiscusMe.sharedInstance.token
        }
    }
    public var PUSHER_KEY:String{
        get{
            return QiscusMe.sharedInstance.rtKey
        }
    }
    
    public var requestHeader:[String:String]? = nil
    
    private override init() {}
    
    public class var postCommentURL:String{
        get{
            let config = QiscusConfig.sharedInstance
            return "\(config.BASE_URL)/post_comment"
        }
    }
    
    // MARK: -URL
    public class var UPLOAD_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/upload"
    }
    public class var LOGIN_REGISTER:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/login_or_register"
    }
    public class var ROOM_REQUEST_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/get_or_create_room_with_target"
    }
    public class var LOAD_URL:String{
        let config = QiscusConfig.sharedInstance
        //return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        return "\(config.BASE_URL)/load_comments/"
    }
    public class func LOAD_URL_(withTopicId topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        //return "\(config.BASE_URL)/topic_comments/"
    }
    
    public func setUserConfig(withEmail email:String, userKey:String, rtKey:String){
        QiscusMe.sharedInstance.email = email
        QiscusMe.sharedInstance.userData.setObject(email, forKey: "qiscus_email")
        
        QiscusMe.sharedInstance.token = userKey
        QiscusMe.sharedInstance.userData.setObject(userKey, forKey: "qiscus_token")
        
        QiscusMe.sharedInstance.rtKey = rtKey
        QiscusMe.sharedInstance.userData.setObject(rtKey, forKey: "qiscus_rt_key")
    }
}
