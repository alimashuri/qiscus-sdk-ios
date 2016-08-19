//
//  ChatCellText.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/21/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

enum CellPosition {
    case Left, Right
}

class ChatCellText: UITableViewCell {
    
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
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSUnderlineColorAttributeName: UIColor.whiteColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
    }
    var linkTextAttributesRight:[String: AnyObject]{
        get{
            return [
            NSForegroundColorAttributeName: UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1),
            NSUnderlineColorAttributeName: UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1),
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

    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.contentInset = UIEdgeInsetsZero
        bubleView.layer.cornerRadius = 14
        statusImage.contentMode = .ScaleAspectFit
    }
    
    func setupCell(comment: QiscusComment, first:Bool, position:CellPosition){
        
        leftArrow.hidden = true
        rightArrow.hidden = true
        
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
            bubleView.backgroundColor = UIColor(red: 2/255.0, green: 173/255.0, blue: 242/255.0, alpha: 1)
            textView.textColor = UIColor.whiteColor()
            textView.linkTextAttributes = linkTextAttributesLeft
            dateLabel.textColor = UIColor.whiteColor()
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            leftMargin.constant = screenWidth - textWidth - 46
            bubleView.backgroundColor = UIColor(red: 191/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1)
            textView.textColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
            textView.linkTextAttributes = linkTextAttributesRight
            dateLabel.textColor = UIColor(red: 114/255.0, green: 114/255.0, blue: 114/255.0, alpha: 1)
            dateLabelRightMargin.constant = -28
            statusImage.hidden = false
            if comment.commentStatus == QiscusCommentStatus.Sending {
                dateLabel.text = NSLocalizedString("CHAT_STATUS_SENDING", comment: "Sending")
                statusImage.image = UIImage(named: "ic_info_time")
            }else if comment.commentStatus == .Sent || comment.commentStatus == .Delivered {
                statusImage.image = UIImage(named: "ic_read")
            }else if comment.commentStatus == .Failed {
                dateLabel.text = NSLocalizedString("CHAT_STATUS_FAILED", comment: "Sending Failed")
                dateLabel.textColor = UIColor(red: 1, green: 19/255.0, blue: 0, alpha: 1)
                statusImage.image = UIImage(named: "ic_warning")
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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func calculateRowHeightForComment(comment comment: QiscusComment) -> CGFloat {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(14)
        textView.dataDetectorTypes = .All
        textView.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1),
            NSUnderlineColorAttributeName: UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1),
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
