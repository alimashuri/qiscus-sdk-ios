//
//  QChatCellRight.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/29/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QChatCellRight: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageBase: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var textTrailing: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var statusTrailing: NSLayoutConstraint!
    @IBOutlet weak var balloonWidht: NSLayoutConstraint!
    
    var comment = QiscusComment()
    var cellPos = CellTypePosition.single
    let maxWidth:CGFloat = 190
    let minWidth:CGFloat = 80
    var indexPath:IndexPath?
    
    var linkTextAttributesRight:[String: AnyObject]{
        get{
            return [
                NSForegroundColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
                NSUnderlineColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
            ]
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        textView.contentInset = UIEdgeInsets.zero
        avatarImage.layer.cornerRadius = 19
        avatarImage.clipsToBounds = true
        avatarImage.contentMode = .scaleAspectFill
    }

    open func setupCell(){
        
        let user = self.comment.sender
        
        
        switch self.cellPos {
        case .first:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_first")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .middle:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_mid")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .last:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 28)
            balloonView.image = Qiscus.image(named:"text_balloon_last_r")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .single:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 28)
            balloonView.image = Qiscus.image(named:"text_balloon_right")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        }
        textView.isUserInteractionEnabled = false
        textView.text = comment.commentText as String
        textView.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
        textView.linkTextAttributes = linkTextAttributesRight
        
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        
        textViewHeight.constant = textSize.height
        userNameLabel.textAlignment = .left
        
        var textWidth = textSize.width
        
        if textSize.width > minWidth {
            textWidth = textSize.width
        }else{
            textWidth = minWidth
        }
        
        textViewWidth.constant = textWidth
        
        balloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
        
        // first cell
        if user != nil && (cellPos == .first || cellPos == .single){
            userNameLabel.text = user!.userFullName
            userNameLabel.isHidden = false
            balloonTopMargin.constant = 20
            cellHeight.constant = 20
        }else{
            userNameLabel.text = ""
            userNameLabel.isHidden = true
            balloonTopMargin.constant = 0
            cellHeight.constant = 0
        }
        
        // last cell
        if cellPos == .last || cellPos == .single{
            if user != nil{
                if QiscusHelper.isFileExist(inLocalPath: user!.userAvatarLocalPath){
                    avatarImage.image = UIImage.init(contentsOfFile: user!.userAvatarLocalPath)
                }else{
                    avatarImage.loadAsync(user!.userAvatarURL, placeholderImage: Qiscus.image(named: "in_chat_avatar"))
                }
                avatarImage.isHidden = false
                avatarImageBase.isHidden = false
            }
            rightMargin.constant = -34
            textTrailing.constant = -23
            statusTrailing.constant = -20
            balloonWidht.constant = 31
        }else{
            avatarImage.isHidden = true
            avatarImageBase.isHidden = true
            textTrailing.constant = -8
            rightMargin.constant = -49
            statusTrailing.constant = -5
            balloonWidht.constant = 16
        }
        
        // comment status render
        
        switch comment.commentStatus {
        case .sending:
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
            statusImage.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            dateLabel.text = comment.commentTime.lowercased()
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.image = Qiscus.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            dateLabel.text = comment.commentTime.lowercased()
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            dateLabel.text = comment.commentTime.lowercased()
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.tintColor = UIColor.green
            statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
            statusImage.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            break
        }
        
        textView.layoutIfNeeded()
    }
    open func updateStatus(toStatus status:QiscusCommentStatus){
        switch status {
            case .sending:
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
                statusImage.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
                break
            case .sent:
                dateLabel.text = comment.commentTime.lowercased()
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.image = Qiscus.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
                break
            case .delivered:
                dateLabel.text = comment.commentTime.lowercased()
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
                break
            case .read:
                dateLabel.text = comment.commentTime.lowercased()
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
                statusImage.tintColor = UIColor.green
                statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
                break
            case . failed:
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
                dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
                statusImage.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
                break
        }
    }
    open override func becomeFirstResponder() -> Bool {
        return true
    }
    open func resend(){
        if QiscusCommentClient.sharedInstance.commentDelegate != nil{
            QiscusCommentClient.sharedInstance.commentDelegate?.performResendMessage(onIndexPath: self.indexPath!)
        }
    }
    open func deleteComment(){
        if QiscusCommentClient.sharedInstance.commentDelegate != nil{
            QiscusCommentClient.sharedInstance.commentDelegate?.performDeleteMessage(onIndexPath: self.indexPath!)
        }
    }
}
