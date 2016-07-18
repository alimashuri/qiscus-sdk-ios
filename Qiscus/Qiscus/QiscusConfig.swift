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
    public var UPLOAD_URL = "https://qvc-engine-staging.herokuapp.com/files/upload"
    public var USER_EMAIL = "ahmad.athaullah@gmail.com"
    public var USER_TOKEN = ""
    
    public class var requestHeader:[String:String]{
        let config = QiscusConfig.sharedInstance
        return ["Authorization": "Token token=\(config.USER_TOKEN)"]
    }
    
    private override init() {}
    
    public class var postCommentURL:String{
        get{
            let config = QiscusConfig.sharedInstance
            return "\(config.BASE_URL)postcomment"
        }
    }
    // MARK: -URL With parameter
    public class func SYNC_URL(topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)?after=true"
    }
    public class func LOAD_URL(topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
    }
}
