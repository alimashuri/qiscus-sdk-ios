//
//  ChatCellDocs.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/26/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

open class ChatCellDocs: UITableViewCell {

    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var containerLeading: NSLayoutConstraint!
    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
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
    var indexPath:IndexPath?
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        bubleView.layer.cornerRadius = 14
        fileContainer.layer.cornerRadius = 10
        statusImage.contentMode = .scaleAspectFit
        fileIcon.image = Qiscus.image(named: "ic_file")?.withRenderingMode(.alwaysTemplate)
        fileIcon.tintColor = UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha:1.0)
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    open func setupCell(_ comment:QiscusComment, last:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        
        if self.tapRecognizer != nil{
            self.fileContainer.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        dateLabelTrailing.constant = -6
        
        if last{
            balloonView.image = ChatCellText.balloonImage(withPosition: position)
            balloonWidth.constant = 215
        }else{
            balloonView.image = ChatCellText.balloonImage()
            balloonWidth.constant = 200
        }

        fileNameLabel.text = file?.fileName
        fileTypeLabel.text = "\(file!.fileExtension.uppercased()) File"
        dateLabel.text = comment.commentTime.lowercased()
        containerLeading.constant = 4
        containerTrailing.constant = -4
        if position == .left {
            if last {
                leftMargin.constant = 4
                containerLeading.constant = 19
            }else{
                leftMargin.constant = 19
            }
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            bubleView.backgroundColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
            statusImage.isHidden = true
        }else{
            if last{
                containerTrailing.constant = -19
            }
            leftMargin.constant = screenWidth - 230
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            bubleView.backgroundColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            statusImage.isHidden = false
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            dateLabelTrailing.constant = -22
            statusImage.isHidden = false
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
            
            if comment.commentStatus == QiscusCommentStatus.sending {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
                statusImage.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .sent {
                statusImage.image = Qiscus.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .delivered{
                statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .read{
                statusImage.tintColor = UIColor.green
                statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .failed {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
                statusImage.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            }
        }
        
        if file!.isUploading {
            let uploadProgres = Int(file!.uploadProgress * 100)
            let uploading = QiscusTextConfiguration.sharedInstance.uploadingText
            
            dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
        }
        bubleView.isHidden = true
    }
    
    open class func getFormattedStringFromInt(_ number: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter.string(from: NSNumber(integerLiteral:number))!
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
