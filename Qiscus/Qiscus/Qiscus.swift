//
//  Qiscus.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public class Qiscus: NSObject {
    public static let sharedInstance = Qiscus()
    
    public var config = QiscusConfig.sharedInstance
    public var commentService = QiscusCommentClient.sharedInstance
    
    public class var commentService:QiscusCommentClient{
        get{
            return QiscusCommentClient.sharedInstance
        }
    }
    
    private override init() {}
    
    
    public class func setConfiguration(baseURL:String, uploadURL: String, userEmail:String, userToken:String, commentPerLoad:Int! = 10, headers: [String:String]? = nil){
        let config = QiscusConfig.sharedInstance
        
        config.BASE_URL = baseURL
        config.UPLOAD_URL = uploadURL
        config.USER_EMAIL = userEmail
        config.USER_TOKEN = userToken
        config.commentPerLoad = commentPerLoad
        config.requestHeader = headers
    }
    /*
    var baseColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
    var gradientColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
    var readOnly = false
    var emptyMessage = ""
    var emptyTitle = ""
    var chatTitle = ""
    var chatSubtitle = ""
    */
    public class func chat(withTopicId topicId:Int, target:UIViewController, readOnly:Bool = false, title:String = "Chat", subtitle:String = ""){
        let bundles = NSBundle.init(forClass: QiscusChatVC.classForCoder())
        
        QiscusUIConfiguration.sharedInstance.topicId = topicId
        QiscusUIConfiguration.sharedInstance.readOnly = readOnly
        QiscusUIConfiguration.sharedInstance.chatSubtitle = subtitle
        QiscusUIConfiguration.sharedInstance.chatTitle = title

        let chatVC = QiscusChatVC(nibName: "QiscusChatVC", bundle: bundles)
        target.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
