//
//  QiscusConfig.swift
//  LinkDokter
//
//  Created by Qiscus on 3/2/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

open class QiscusConfig: NSObject {
    
    static let sharedInstance = QiscusConfig()
    
    open var commentPerLoad:Int = 10
    
    open var UPLOAD_URL = ""
    
    open var showToasterMessage:Bool = true
    open var showToasterMessageInsideChat:Bool = true
    
    open var BASE_URL:String{
        get{
            return QiscusMe.sharedInstance.baseUrl
        }
    }
    open var USER_EMAIL:String{
        get{
            return QiscusMe.sharedInstance.email
        }
    }
    open var USER_TOKEN:String{
        get{
            return QiscusMe.sharedInstance.token
        }
    }
    open var PUSHER_KEY:String{
        get{
            return QiscusMe.sharedInstance.rtKey
        }
    }
    
    open var requestHeader:[String:String]? = nil
    
    fileprivate override init() {}
    
    open class var postCommentURL:String{
        get{
            let config = QiscusConfig.sharedInstance
            return "\(config.BASE_URL)/post_comment"
        }
    }
    
    // MARK: -URL
    open class var UPLOAD_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/upload"
    }
    open class var LOGIN_REGISTER:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/login_or_register"
    }
    open class var ROOM_REQUEST_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/get_or_create_room_with_target"
    }
    open class var LOAD_URL:String{
        let config = QiscusConfig.sharedInstance
        //return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        return "\(config.BASE_URL)/load_comments/"
    }
    open class func LOAD_URL_(withTopicId topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        //return "\(config.BASE_URL)/topic_comments/"
    }
    open class var ROOM_REQUEST_ID_URL:String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/get_room_by_id"
    }
    open func setUserConfig(withEmail email:String, userKey:String, rtKey:String){
        QiscusMe.sharedInstance.email = email
        QiscusMe.sharedInstance.userData.set(email, forKey: "qiscus_email")
        
        QiscusMe.sharedInstance.token = userKey
        QiscusMe.sharedInstance.userData.set(userKey, forKey: "qiscus_token")
        
        QiscusMe.sharedInstance.rtKey = rtKey
        QiscusMe.sharedInstance.userData.set(rtKey, forKey: "qiscus_rt_key")
    }
}
