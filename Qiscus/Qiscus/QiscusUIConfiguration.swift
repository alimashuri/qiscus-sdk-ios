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
    
    public var cancelButtonColor = UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha:1.0)
    public var alertTextColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    public var leftBaloonColor = UIColor(red: 0/255.0, green: 187/255.0, blue: 150/255.0, alpha: 1)
    public var rightBaloonColor = UIColor(red: 165/255.0, green: 226/255.0, blue: 221/255.0, alpha: 1)
    public var leftBaloonTextColor = UIColor.whiteColor()
    public var rightBaloonTextColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    public var timeLabelTextColor = UIColor(red: 114/255.0, green: 114/255.0, blue: 114/255.0, alpha: 1)
    public var failToSendColor = UIColor(red: 1, green: 19/255.0, blue: 0, alpha: 1)
    public var leftBaloonLinkColor = UIColor.whiteColor()
    public var rightBaloonLinkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    public var lockViewBgColor = UIColor(red: 255.0/255.0, green: 87/255.0, blue: 34/255.0, alpha: 1)
    public var lockViewTintColor = UIColor.blackColor()
    
    public var readOnly = false
    public var emptyMessage = "Let's write message to start conversation"
    public var emptyTitle = "Welcome"
    public var chatTitle = "Title"
    public var chatSubtitle = "Sub Title"
    public var readOnlyText = "Archieved message: This message was locked. Click the key to open the conversation."
    public var textPlaceholder = "Text a message here ..."
    public var galeryAccessAlertTitle = "Important"
    public var galeryAccessAlertText = "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    public var confirmationTitle = "CONFIRMATION"
    public var confirmationImageUploadText = "Are you sure to send this image?"
    public var confirmationFileUploadText = "Are you sure to send"
    public var backText = "Back"
    public var questionMark = "?"
    public var alertOkText = "OK"
    public var alertCancelText = "CANCEL"
    public var alertSettingText = "SETTING"
    
    public var todayText = "Today"
    public var uploadingText = "Uploading"
    public var sendingText = "Sending"
    public var failedText = "Sending Failed"
    public var noConnectionText = "can't connect to internet, please check your connection"
    
    public var topicId:Int = 0
    public var chatUsers:[String] = [String]()
    public var baseColor:UIColor{
        get{
            return QiscusChatVC.sharedInstance.topColor
        }
    }
    private override init() {}
    
    public func defaultStyle(){
        let defaultUIStyle = QiscusUIConfiguration()
        QiscusUIConfiguration.sharedInstance = defaultUIStyle
    }
}
