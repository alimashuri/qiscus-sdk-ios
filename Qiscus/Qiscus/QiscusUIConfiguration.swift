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
    
    /// Your cancel button color, using UIColor class, Default value : UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha:1.0)
    public var cancelButtonColor = UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha:1.0)
    /// Your alert text color, using UIColor class, Default value : UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    public var alertTextColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    /// Your left baloon color, using UIColor class, Default value : UIColor(red: 0/255.0, green: 187/255.0, blue: 150/255.0, alpha: 1.0)
    public var leftBaloonColor = UIColor(red: 0/255.0, green: 187/255.0, blue: 150/255.0, alpha: 1)
    /// Your right baloon color, using UIColor class, Default value : UIColor(red: 165/255.0, green: 226/255.0, blue: 221/255.0, alpha: 1.0)
    public var rightBaloonColor = UIColor(red: 165/255.0, green: 226/255.0, blue: 221/255.0, alpha: 1)
    /// Your left baloon text color, using UIColor class, Default value : UIColor.whiteColor()
    public var leftBaloonTextColor = UIColor.whiteColor()
    /// Your right baloon text color, using UIColor class, Default value : UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    public var rightBaloonTextColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    /// Your text color of time label, using UIColor class, Default value : UIColor(red: 114/255.0, green: 114/255.0, blue: 114/255.0, alpha: 1)
    public var timeLabelTextColor = UIColor(red: 114/255.0, green: 114/255.0, blue: 114/255.0, alpha: 1)
    /// Your failed text color if the message fail to send, using UIColor class, Default value : UIColor(red: 1, green: 19/255.0, blue: 0, alpha: 1)
    public var failToSendColor = UIColor(red: 1, green: 19/255.0, blue: 0, alpha: 1)
    /// Your link color of left baloon chat, using UIColor class, Default value : UIColor.whiteColor()
    public var leftBaloonLinkColor = UIColor.whiteColor()
    /// Your link color of right baloon chat, using UIColor class, Default value : UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    public var rightBaloonLinkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    /// Your background color of lock view, using UIColor class, Default value : UIColor(red: 255.0/255.0, green: 87/255.0, blue: 34/255.0, alpha: 1)
    public var lockViewBgColor = UIColor(red: 255.0/255.0, green: 87/255.0, blue: 34/255.0, alpha: 1)
    /// Your tint color of lock view, using UIColor class, Default value : UIColor.blackColor()
    public var lockViewTintColor = UIColor.blackColor()
    
    /// To set read only or not, Default value : false
    public var readOnly = false
    /// Your text to show as subtitle if there isn't any message, Default value : "Let's write message to start conversation"
    public var emptyMessage = "Let's write message to start conversation"
    /// Your text to show as title if there isn't any message, Default value : "Welcome"
    public var emptyTitle = "Welcome"
    /// Your text to show as title chat, Default value : "Title"
    public var chatTitle = "Title"
    /// Your text to show as subtitle chat, Default value : "Sub Title"
    public var chatSubtitle = "Sub Title"
    /// Your text if you set chat read only, Default value : "Archieved message: This message was locked. Click the key to open the conversation."
    public var readOnlyText = "Archieved message: This message was locked. Click the key to open the conversation."
    /// Your text placeholder if you want to send any message, Default value : "Text a message here ..."
    public var textPlaceholder = "Text a message here ..."
    /// Your text to show as title alert when you access gallery but you not allow gallery access, Default value : "Important"
    public var galeryAccessAlertTitle = "Important"
    /// Your text to show as content alert when you access gallery but you not allow gallery access, Default value : "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    public var galeryAccessAlertText = "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    /// Your text to show as title confirmation when you want to upload image/file, Default value : "CONFIRMATION"
    public var confirmationTitle = "CONFIRMATION"
    /// Your text to show as content confirmation when you want to upload image, Default value : "Are you sure to send this image?"
    public var confirmationImageUploadText = "Are you sure to send this image?"
    /// Your text to show as content confirmation when you want to upload file, Default value : "Are you sure to send"
    public var confirmationFileUploadText = "Are you sure to send"
    
    /// Your text in back action, Default value : "Back"
    public var backText = "Back"
    /// Your question mark, Default value : "?"
    public var questionMark = "?"
    /// Your text in alert OK button, Default value : "OK"
    public var alertOkText = "OK"
    /// Your text in alert Cancel button, Default value : "CANCEL"
    public var alertCancelText = "CANCEL"
    /// Your text in alert Setting button, Default value : "SETTING"
    public var alertSettingText = "SETTING"
    
    /// Your text if the day is "today", Default value : "Today"
    public var todayText = "Today"
    /// Your text if it is the process of uploading file, Default value : "Uploading"
    public var uploadingText = "Uploading"
    /// Your text if it is the process of uploading image, Default value : "Sending"
    public var sendingText = "Sending"
    /// Your text if the process of uploading fail, Default value : "Sending Failed"
    public var failedText = "Sending Failed"
    /// Your text if there isn't connection internet, Default value :  "can't connect to internet, please check your connection"
    public var noConnectionText = "can't connect to internet, please check your connection"
    
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
