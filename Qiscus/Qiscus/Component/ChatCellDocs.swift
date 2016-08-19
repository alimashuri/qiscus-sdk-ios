//
//  ChatCellDocs.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/26/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

class ChatCellDocs: UITableViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubleView.layer.cornerRadius = 14
        fileContainer.layer.cornerRadius = 10
        statusImage.contentMode = .ScaleAspectFit
        fileIcon.image = UIImage(named: "ic_file")?.imageWithRenderingMode(.AlwaysTemplate)
        fileIcon.tintColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setupCell(comment:QiscusComment, first:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        
        if self.tapRecognizer != nil{
            self.fileContainer.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        
        leftArrow.hidden = true
        rightArrow.hidden = true
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
            bubleView.backgroundColor = UIColor(red: 2/255.0, green: 173/255.0, blue: 242/255.0, alpha: 1)
            dateLabel.textColor = UIColor.whiteColor()
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            leftMargin.constant = screenWidth - 230
            bubleView.backgroundColor = UIColor(red: 191/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1)
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
        
        if file!.isUploading {
            let uploadProgres = Int(file!.uploadProgress * 100)
            let uploading = NSLocalizedString("CHAT_UPLOADING", comment: "Uploading")
            
            dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
        }
    }
    
    class func getFormattedStringFromInt(number: Int) -> String{
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .NoStyle
        return numberFormatter.stringFromNumber(number)!
    }
    
}
