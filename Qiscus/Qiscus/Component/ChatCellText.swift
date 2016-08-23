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
    let minWidth:CGFloat = 110
    let defaultDateLeftMargin:CGFloat = -10
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    var linkTextAttributesLeft:[String: AnyObject]{
        get{
            return [
                NSForegroundColorAttributeName: QiscusUIConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineColorAttributeName: QiscusUIConfiguration.sharedInstance.leftBaloonLinkColor,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
    }
    var linkTextAttributesRight:[String: AnyObject]{
        get{
            return [
            NSForegroundColorAttributeName: QiscusUIConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineColorAttributeName: QiscusUIConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
    }
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    
    override public func awakeFromNib() {
        super.awakeFromNib()
        textView.contentInset = UIEdgeInsetsZero
        bubleView.layer.cornerRadius = 14
        statusImage.contentMode = .ScaleAspectFit
    }
    
    public func setupCell(comment: QiscusComment, first:Bool, position:CellPosition){
        
        leftArrow.hidden = true
        rightArrow.hidden = true
        leftArrow.image = Qiscus.image(named: "ic_arrow_bubble_primary")?.imageWithRenderingMode(.AlwaysTemplate)
        rightArrow.image = Qiscus.image(named: "ic_arrow_buble_primary_light")?.imageWithRenderingMode(.AlwaysTemplate)
        leftArrow.tintColor = QiscusUIConfiguration.sharedInstance.leftBaloonColor
        rightArrow.tintColor = QiscusUIConfiguration.sharedInstance.rightBaloonColor
        
        if first {
            if position == .Left {
                leftArrow.hidden = false
                
            }else{
                rightArrow.hidden = false
            }
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
        if position == .Left {
            leftMargin.constant = 15
            bubleView.backgroundColor = QiscusUIConfiguration.sharedInstance.leftBaloonColor
            textView.textColor = QiscusUIConfiguration.sharedInstance.leftBaloonTextColor
            textView.linkTextAttributes = linkTextAttributesLeft
            dateLabel.textColor = QiscusUIConfiguration.sharedInstance.leftBaloonTextColor
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            leftMargin.constant = screenWidth - textWidth - 46
            bubleView.backgroundColor = QiscusUIConfiguration.sharedInstance.rightBaloonColor
            textView.textColor = QiscusUIConfiguration.sharedInstance.rightBaloonTextColor
            textView.linkTextAttributes = linkTextAttributesRight
            dateLabel.textColor = QiscusUIConfiguration.sharedInstance.rightBaloonTextColor
            dateLabelRightMargin.constant = -28
            statusImage.hidden = false
            statusImage.tintColor = QiscusUIConfiguration.sharedInstance.rightBaloonTextColor
            if comment.commentStatus == QiscusCommentStatus.Sending {
                dateLabel.text = QiscusUIConfiguration.sharedInstance.sendingText
                statusImage.image = Qiscus.image(named: "ic_info_time")?.imageWithRenderingMode(.AlwaysTemplate)
            }else if comment.commentStatus == .Sent || comment.commentStatus == .Delivered {
                statusImage.image = Qiscus.image(named: "ic_read")?.imageWithRenderingMode(.AlwaysTemplate)
            }else if comment.commentStatus == .Failed {
                dateLabel.text = QiscusUIConfiguration.sharedInstance.failedText
                dateLabel.textColor = QiscusUIConfiguration.sharedInstance.failToSendColor
                statusImage.image = Qiscus.image(named: "ic_warning")?.imageWithRenderingMode(.AlwaysTemplate)
                statusImage.tintColor = QiscusUIConfiguration.sharedInstance.failToSendColor
            }
            
        }
        leftArrow.layer.zPosition = 20
        rightArrow.layer.zPosition = 20
        bubleView.layer.zPosition = 21
        dateLabel.layer.zPosition = 22
        textView.layer.zPosition = 23
        statusImage.layer.zPosition = 24
        bubleView.layoutIfNeeded()
        textView.layoutIfNeeded()
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
            NSForegroundColorAttributeName: QiscusUIConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineColorAttributeName: QiscusUIConfiguration.sharedInstance.rightBaloonLinkColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        
        let maxWidth:CGFloat = 190
        var estimatedHeight:CGFloat = 110
        
        textView.text = comment.commentText
        let textSize = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
        
        estimatedHeight = textSize.height + 18
        
        return estimatedHeight
    }
    
}
