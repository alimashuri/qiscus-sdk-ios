//
//  QiscusUIConfiguration.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QiscusUIConfiguration: NSObject {
    static var sharedInstance = QiscusUIConfiguration()
    
    open var color = QiscusColorConfiguration.sharedInstance
    open var copyright = QiscusTextConfiguration.sharedInstance
    
    
    /// To set read only or not, Default value : false
    open var readOnly = false
    
    
    open var topicId:Int = 0
    open var chatUsers:[String] = [String]()
    open var baseColor:UIColor{
        get{
            return QiscusChatVC.sharedInstance.topColor
        }
    }
    fileprivate override init() {}
    
    /// Class function to set default style
    open func defaultStyle(){
        let defaultUIStyle = QiscusUIConfiguration()
        QiscusUIConfiguration.sharedInstance = defaultUIStyle
    }
}
