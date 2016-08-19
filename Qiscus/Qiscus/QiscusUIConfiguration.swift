//
//  QiscusUIConfiguration.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public class QiscusUIConfiguration: NSObject {
    static let sharedInstance = QiscusUIConfiguration()
    
    public var baseColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
    public var gradientColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
    public var cancelButtonColor = UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha:1.0)
    public var alertTextColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    
    public var readOnly = false
    public var emptyMessage = "Let's write message to start conversation"
    public var emptyTitle = "Welcome"
    public var chatTitle = "Title"
    public var chatSubtitle = "Sub Title"
    public var readOnlyText = "Archieved message: This message was locked. Click the key to open the conversation."
    public var textPlaceholder = "Text a message here ..."
    
//    let title = NSLocalizedString("CHAT_CONFIRMATION_TITLE", comment: "Confirmation")
//    let text = NSLocalizedString("CHAT_CONFIRMATION_IMAGE_UPLOAD_TEXT", comment: "....")
//    let okText = NSLocalizedString("OK_ALERT_BUTTON", comment: "OK")
    
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
    
    public var topicId:Int = 0
    
    private override init() {}
}
