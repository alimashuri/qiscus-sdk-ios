//
//  ChatCellText.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/21/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public enum CellPosition {
    case Left, Right
}

public class ChatCellText: UITableViewCell {
    
    //var comment = QiscusComment()
    var firstComment:Bool = true
    let maxWidth:CGFloat = 190
    let minWidth:CGFloat = 80
    let defaultDateLeftMargin:CGFloat = -5
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    var linkTextAttributesLeft:[String: AnyObject]{
        get{
            return [
                NSForegroundColorAttributeName: QiscusColorConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineColorAttributeName: QiscusColorConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
    }
    var linkTextAttributesRight:[String: AnyObject]{
        get{
            return [
            NSForegroundColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
    }
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var baloonView: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textLeading: NSLayoutConstraint!
    @IBOutlet weak var statusTrailing: NSLayoutConstraint!

    
    override public func awakeFromNib() {
        super.awakeFromNib()
        textView.contentInset = UIEdgeInsetsZero
        statusImage.contentMode = .ScaleAspectFit
    }
    
    public func setupCell(comment: QiscusComment, last:Bool, position:CellPosition){
        
        leftArrow.hidden = true
        rightArrow.hidden = true
        leftArrow.image = Qiscus.image(named: "ic_arrow_bubble_primary")?.imageWithRenderingMode(.AlwaysTemplate)
        rightArrow.image = Qiscus.image(named: "ic_arrow_buble_primary_light")?.imageWithRenderingMode(.AlwaysTemplate)
        leftArrow.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
        rightArrow.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
        
        baloonView.image = ChatCellText.balloonImage()
        
        if last {
            baloonView.image = ChatCellText.balloonImage(withPosition: position)
        }
        textView.text = comment.commentText as String
        dateLabel.text = comment.commentTime.lowercaseString
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
        
        textViewHeight.constant = textSize.height
        
        var textWidth = textSize.width
        if textSize.width > minWidth {
            textWidth = textSize.width
        }else{
            textWidth = minWidth
        }
        
        textViewWidth.constant = textWidth
        textLeading.constant = 8
        
        if position == .Left {
            if last {
                leftMargin.constant = 0
                textLeading.constant = 23
            }else{
                leftMargin.constant = 15
            }
            baloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            textView.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
            textView.linkTextAttributes = linkTextAttributesLeft
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            if last {
                leftMargin.constant = screenWidth - textWidth - 50
                dateLabelRightMargin.constant = -35
                statusTrailing.constant = -20
            }else{
                leftMargin.constant = screenWidth - textWidth - 65
                dateLabelRightMargin.constant = -20
                statusTrailing.constant = -5
            }
            baloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            textView.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            textView.linkTextAttributes = linkTextAttributesRight
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.hidden = false
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            if comment.commentStatus == QiscusCommentStatus.Sending {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
                statusImage.image = Qiscus.image(named: "ic_info_time")?.imageWithRenderingMode(.AlwaysTemplate)
            }else if comment.commentStatus == .Sent || comment.commentStatus == .Delivered {
                statusImage.image = Qiscus.image(named: "ic_read")?.imageWithRenderingMode(.AlwaysTemplate)
            }else if comment.commentStatus == .Failed {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
                statusImage.image = Qiscus.image(named: "ic_warning")?.imageWithRenderingMode(.AlwaysTemplate)
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            }
            
        }
        leftArrow.layer.zPosition = 20
        rightArrow.layer.zPosition = 20
        dateLabel.layer.zPosition = 22
        textView.layer.zPosition = 23
        statusImage.layer.zPosition = 24
        textView.layoutIfNeeded()
        rightArrow.hidden = true
        leftArrow.hidden = true
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public class func calculateRowHeightForComment(comment comment: QiscusComment) -> CGFloat {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(14)
        textView.dataDetectorTypes = .All
        textView.linkTextAttributes = [
            NSForegroundColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineColorAttributeName: QiscusColorConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        
        let maxWidth:CGFloat = 190
        var estimatedHeight:CGFloat = 110
        
        textView.text = comment.commentText
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
        
        estimatedHeight = textSize.height + 18
        
        return estimatedHeight
    }
    public class func balloonImage(withPosition position:CellPosition? = nil)->UIImage?{
        var balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 13)
        var balloonImage = Qiscus.image(named:"text_balloon_left")?.resizableImageWithCapInsets(balloonEdgeInset, resizingMode: .Stretch).imageWithRenderingMode(.AlwaysTemplate)
        if position != nil {
            if position == .Left {
                balloonEdgeInset = UIEdgeInsetsMake(13, 28, 13, 13)
                balloonImage = Qiscus.image(named:"text_balloon_left")?.resizableImageWithCapInsets(balloonEdgeInset, resizingMode: .Stretch).imageWithRenderingMode(.AlwaysTemplate)
            }else{
                balloonEdgeInset = UIEdgeInsetsMake(13, 13, 13, 28)
                balloonImage = Qiscus.image(named:"text_balloon_right")?.resizableImageWithCapInsets(balloonEdgeInset, resizingMode: .Stretch).imageWithRenderingMode(.AlwaysTemplate)
            }
        }else{
            balloonImage = Qiscus.image(named:"text_balloon")?.resizableImageWithCapInsets(balloonEdgeInset, resizingMode: .Stretch).imageWithRenderingMode(.AlwaysTemplate)
        }
        return balloonImage
    }
}
