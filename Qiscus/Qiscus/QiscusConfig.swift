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
    public var BASE_URL = "https://halodoc-messaging-dev.linkdokter.com/"
    public var UPLOAD_URL = "https://upload.qisc.us/upload.php"
    public var USER_EMAIL = "ahmad.athaullah@gmail.com"
    public var USER_TOKEN = ""
    public var PUSHER_KEY = "3f27dc397124364ecc0f"
    
    public var requestHeader:[String:String]? = nil
    
    private override init() {}
    
    public class var postCommentURL:String{
        get{
            let config = QiscusConfig.sharedInstance
            return "\(config.BASE_URL)/postcomment"
        }
    }
    
    // MARK: -URL With parameter
//    public class func SYNC_URL(topicId:Int, commentId:Int)->String{
//        let config = QiscusConfig.sharedInstance
//        return "\(config.BASE_URL)/topic_c/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)?after=true"
//    }
    public class var ROOM_REQUEST_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_URL)/room_create_with_participant"
    }
    public class var LOAD_URL:String{
        let config = QiscusConfig.sharedInstance
        //return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        return "\(config.BASE_URL)/topic_comments/"
    }
    public class func LOAD_URL_(withTopicId topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
        //return "\(config.BASE_URL)/topic_comments/"
    }
    
}
