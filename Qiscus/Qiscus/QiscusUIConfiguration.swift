//
//  QiscusUIConfiguration.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public class QiscusUIConfiguration: NSObject {
    static var sharedInstance = QiscusUIConfiguration()
    
    public var color = QiscusColorConfiguration.sharedInstance
    public var copyright = QiscusTextConfiguration.sharedInstance
    
    
    /// To set read only or not, Default value : false
    public var readOnly = false
    
    
    public var topicId:Int = 0
    public var chatUsers:[String] = [String]()
    public var baseColor:UIColor{
        get{
            return QiscusChatVC.sharedInstance.topColor
        }
    }
    private override init() {}
    
    /// Class function to set default style
    public func defaultStyle(){
        let defaultUIStyle = QiscusUIConfiguration()
        QiscusUIConfiguration.sharedInstance = defaultUIStyle
    }
}
