//
//  QChatCellLeft.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/29/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QChatCellLeft: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageBase: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textLeading: NSLayoutConstraint!
    
    var comment = QiscusComment()
    var cellPos = CellTypePosition.single
    let maxWidth:CGFloat = 190
    let minWidth:CGFloat = 80
    var indexPath:IndexPath?
    
    var linkTextAttributesLeft:[String: Any]{
        get{
            return [
                NSForegroundColorAttributeName: QiscusColorConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineColorAttributeName: QiscusColorConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
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
        
        switch cellPos {
        case .first:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_first")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .middle:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_mid")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .last:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 28, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_last_l")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        case .single:
            let balloonEdgeInset = UIEdgeInsetsMake(13, 28, 13, 13)
            balloonView.image = Qiscus.image(named:"text_balloon_left")?.resizableImage(withCapInsets: balloonEdgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
            break
        }
        
        textView.isUserInteractionEnabled = false
        textView.text = comment.commentText as String
        textView.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
        textView.linkTextAttributes = linkTextAttributesLeft
        
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        
        var textWidth = comment.commentTextWidth
        if textSize.width > minWidth {
            textWidth = textSize.width
        }else{
            textWidth = minWidth
        }
        
        textViewWidth.constant = textWidth
        textViewHeight.constant = textSize.height
        userNameLabel.textAlignment = .left
        
        dateLabel.text = comment.commentTime.lowercased()
        balloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
        
        dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
        
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
            leftMargin.constant = 34
            textLeading.constant = 23
        }else{
            avatarImage.isHidden = true
            avatarImageBase.isHidden = true
            textLeading.constant = 8
            leftMargin.constant = 49
        }
        
        textView.layoutIfNeeded()
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
