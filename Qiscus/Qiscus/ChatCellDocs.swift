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
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var containerLeading: NSLayoutConstraint!
    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var fileTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var balloonWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabelTrailing: NSLayoutConstraint!
    
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
    public func setupCell(comment:QiscusComment, last:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        
        if self.tapRecognizer != nil{
            self.fileContainer.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        dateLabelTrailing.constant = -6
        leftArrow.hidden = true
        rightArrow.hidden = true
        leftArrow.image = Qiscus.image(named: "ic_arrow_bubble_primary")?.imageWithRenderingMode(.AlwaysTemplate)
        rightArrow.image = Qiscus.image(named: "ic_arrow_buble_primary_light")?.imageWithRenderingMode(.AlwaysTemplate)
        leftArrow.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
        rightArrow.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
        
        if last{
            balloonView.image = ChatCellText.balloonImage(withPosition: position)
            balloonWidth.constant = 215
        }else{
            balloonView.image = ChatCellText.balloonImage()
            balloonWidth.constant = 200
        }
//        if first {
//            if position == .Left{
//                leftArrow.hidden = false
//            }else{
//                rightArrow.hidden = false
//            }
//        }
        fileNameLabel.text = file?.fileName
        fileTypeLabel.text = "\(file!.fileExtension.uppercaseString) File"
        dateLabel.text = comment.commentTime.lowercaseString
        containerLeading.constant = 4
        containerTrailing.constant = -4
        if position == .Left {
            if last {
                leftMargin.constant = 4
                containerLeading.constant = 19
            }else{
                leftMargin.constant = 19
            }
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            bubleView.backgroundColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
//            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            if last{
                containerTrailing.constant = -19
            }
            leftMargin.constant = screenWidth - 230
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            bubleView.backgroundColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.hidden = false
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            dateLabelTrailing.constant = -22
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
        
        if file!.isUploading {
            let uploadProgres = Int(file!.uploadProgress * 100)
            let uploading = QiscusTextConfiguration.sharedInstance.uploadingText
            
            dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
        }
        bubleView.hidden = true
        leftArrow.hidden = true
        rightArrow.hidden = true
    }
    
    public class func getFormattedStringFromInt(number: Int) -> String{
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .NoStyle
        return numberFormatter.stringFromNumber(number)!
    }
    
}
