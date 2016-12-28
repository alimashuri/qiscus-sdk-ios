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
    @IBOutlet weak var avatarImageBase: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var balloonWidth: NSLayoutConstraint!
    @IBOutlet weak var dateLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak var userNameLeading: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    
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
        fileContainer.layer.cornerRadius = 10
        statusImage.contentMode = .scaleAspectFit
        fileIcon.image = Qiscus.image(named: "ic_file")?.withRenderingMode(.alwaysTemplate)
        fileIcon.contentMode = .scaleAspectFit
        avatarImage.layer.cornerRadius = 19
        avatarImage.clipsToBounds = true
        avatarImage.isHidden = true
        avatarImage.contentMode = .scaleAspectFill
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    open func setupCell(_ comment:QiscusComment, last:Bool, position:CellPosition, cellVPos:CellTypePosition? = nil){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        
        let user = comment.sender
        let avatar = Qiscus.image(named: "in_chat_avatar")
        avatarImage.image = avatar
        avatarImage.isHidden = true
        avatarImageBase.isHidden = true
        userNameLabel.text = ""
        userNameLabel.isHidden = true
        balloonTopMargin.constant = 0
        cellHeight.constant = 0
        if cellVPos != nil {
            if cellVPos == .first || cellVPos == .single{
                userNameLabel.text = user?.userFullName
                userNameLabel.isHidden = false
                balloonTopMargin.constant = 20
                cellHeight.constant = 20
            }
        }
        if self.tapRecognizer != nil{
            self.fileContainer.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        dateLabelTrailing.constant = -6
        
        if last{
            balloonView.image = ChatCellText.balloonImage(withPosition: position, cellVPos: cellVPos)
            balloonWidth.constant = 215
            avatarImageBase.isHidden = false
            avatarImage.isHidden = false
            if user != nil{
                avatarImage.loadAsync(user!.userAvatarURL, placeholderImage: avatar)
            }
        }else{
            balloonView.image = ChatCellText.balloonImage(cellVPos: cellVPos)
            balloonWidth.constant = 200
        }

        fileNameLabel.text = file?.fileName
        fileTypeLabel.text = "\(file!.fileExtension.uppercased()) File"
        dateLabel.text = comment.commentTime.lowercased()
        containerLeading.constant = 4
        containerTrailing.constant = -4
        if position == .left {
            avatarLeading.constant = 0
            if last {
                leftMargin.constant = 34
                containerLeading.constant = 19
            }else{
                leftMargin.constant = 49
            }
            userNameLabel.textAlignment = .left
            userNameLeading.constant = 53
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.leftBaloonTextColor
            fileIcon.tintColor = QiscusColorConfiguration.sharedInstance.leftBaloonColor
            statusImage.isHidden = true
        }else{
            if last{
                containerTrailing.constant = -19
            }
            userNameLabel.textAlignment = .right
            userNameLeading.constant = screenWidth - 275
            leftMargin.constant = screenWidth - 268
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
            fileIcon.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
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
