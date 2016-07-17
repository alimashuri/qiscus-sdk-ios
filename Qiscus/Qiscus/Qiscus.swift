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
    public var url = QUrl.sharedInstance
    public var service = QClient.sharedInstance
    //private var configuration =
    
    
    
    private override init() {}
    
    
    public class func setConfiguration(baseURL:String, uploadURL: String, userEmail:String, userToken:String, commentPerLoad:Int! = 10){
        let config = QiscusConfig.sharedInstance
        
        config.BASE_URL = baseURL
        config.UPLOAD_URL = uploadURL
        config.USER_EMAIL = userEmail
        config.USER_TOKEN = userToken
        config.commentPerLoad = commentPerLoad
    }
}
