//
//  ChatCellDocs.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/26/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public class ChatCellDocs: UITableViewCell {

    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var fileTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        bubleView.layer.cornerRadius = 14
        fileContainer.layer.cornerRadius = 10
        statusImage.contentMode = .ScaleAspectFit
        fileIcon.image = Qiscus.image(named: "ic_file")?.imageWithRenderingMode(.AlwaysTemplate)
        fileIcon.tintColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    public func setupCell(comment:QiscusComment, first:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        
        if self.tapRecognizer != nil{
            self.fileContainer.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        
        leftArrow.hidden = true
        rightArrow.hidden = true
        leftArrow.image = Qiscus.image(named: "ic_arrow_bubble_primary")?.imageWithRenderingMode(.AlwaysTemplate)
        rightArrow.image = Qiscus.image(named: "ic_arrow_buble_primary_light")?.imageWithRenderingMode(.AlwaysTemplate)
        leftArrow.tintColor = QiscusUIConfiguration.sharedInstance.leftBaloonColor
        rightArrow.tintColor = QiscusUIConfiguration.sharedInstance.rightBaloonColor
        
        if first {
            if position == .Left{
                leftArrow.hidden = false
            }else{
                rightArrow.hidden = false
            }
        }
        fileNameLabel.text = file?.fileName
        fileTypeLabel.text = "\(file!.fileExtension.uppercaseString) File"
        dateLabel.text = comment.commentTime.lowercaseString
        
        if position == .Left {
            leftMargin.constant = 15
            bubleView.backgroundColor = QiscusUIConfiguration.sharedInstance.leftBaloonColor
            dateLabel.textColor = QiscusUIConfiguration.sharedInstance.leftBaloonTextColor
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            leftMargin.constant = screenWidth - 230
            bubleView.backgroundColor = QiscusUIConfiguration.sharedInstance.rightBaloonColor
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
        
        if file!.isUploading {
            let uploadProgres = Int(file!.uploadProgress * 100)
            let uploading = QiscusUIConfiguration.sharedInstance.uploadingText
            
            dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
        }
    }
    
    public class func getFormattedStringFromInt(number: Int) -> String{
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .NoStyle
        return numberFormatter.stringFromNumber(number)!
    }
    
}
