//
//  ChatCellMedia.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

open class ChatCellMedia: UITableViewCell {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var displayFrame: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: ChatFileButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    @IBOutlet weak var displayLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var displayWidth: NSLayoutConstraint!
    @IBOutlet weak var videoFrameWidth: NSLayoutConstraint!
    @IBOutlet weak var displayOverlay: UIView!
    @IBOutlet weak var avatarImageBase: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var downloadButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var videoPlay: UIImageView!
    
    @IBOutlet weak var statusImageTrailing: NSLayoutConstraint!
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var userNameLeading: NSLayoutConstraint!
    
    @IBOutlet weak var videoFrame: UIImageView!
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    let maxProgressHeight:CGFloat = 36.0
    var indexPath:IndexPath?
    var maskImage = UIImage()
    var isVideo = false
    var cellPos = CellTypePosition.single
    var comment = QiscusComment()
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        statusImage.contentMode = .scaleAspectFit
        progressContainer.layer.cornerRadius = 20
        progressContainer.clipsToBounds = true
        progressContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65).cgColor
        progressContainer.layer.borderWidth = 2
        downloadButton.setImage(Qiscus.image(named: "ic_download_chat")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        downloadButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        self.videoPlay.image = Qiscus.image(named: "play_button")
        self.videoFrame.image = Qiscus.image(named: "movie_frame")?.withRenderingMode(.alwaysTemplate)
        self.videoFrame.tintColor = UIColor.black
        self.videoFrame.contentMode = .scaleAspectFill
        self.videoFrame.clipsToBounds = true
        self.videoPlay.contentMode = .scaleAspectFit
        self.imageDisplay.contentMode = .scaleAspectFill
        self.imageDisplay.clipsToBounds = true
        self.imageDisplay.backgroundColor = UIColor.black
        self.imageDisplay.isUserInteractionEnabled = true
        self.displayFrame.contentMode = .scaleAspectFill
        self.displayOverlay.verticalGradientColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), bottomColor: UIColor.black)
        avatarImage.layer.cornerRadius = 19
        avatarImage.clipsToBounds = true
        avatarImage.isHidden = true
        avatarImage.contentMode = .scaleAspectFill
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    open func updateStatus(toStatus status:QiscusCommentStatus){
        dateLabel.textColor = UIColor.white
        statusImage.isHidden = false
        statusImage.tintColor = UIColor.white
        statusImage.isHidden = false
        statusImage.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonTextColor
        
        if status == QiscusCommentStatus.sending {
            dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
            statusImage.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
        }else if status == .sent {
            statusImage.image = Qiscus.image(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
        }else if status == .delivered{
            statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
        }else if status == .read{
            statusImage.tintColor = UIColor.green
            statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
        }else if status == .failed {
            dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
            dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            statusImage.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
        }
    }
    open func setupCell(){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        let user = comment.sender
        
        let avatar = Qiscus.image(named: "in_chat_avatar")
        avatarImage.image = avatar
        avatarImage.isHidden = true
        avatarImageBase.isHidden = true
        progressContainer.isHidden = true
        progressView.isHidden = true
        imageDisplay.image = nil
        statusImageTrailing.constant = -5
        
        // cleartap recognizer
        if self.tapRecognizer != nil{
            imageDisplay.removeGestureRecognizer(self.tapRecognizer!)
            tapRecognizer = nil
        }
        
        // if this is first cell
        if cellPos == .first || cellPos == .single{
            userNameLabel.text = user?.userFullName
            userNameLabel.isHidden = false
            balloonTopMargin.constant = 20
            cellHeight.constant = 20
        }else{
            userNameLabel.text = ""
            userNameLabel.isHidden = true
            balloonTopMargin.constant = 0
            cellHeight.constant = 0
        }
        
        // if this is last cell
        var imagePlaceholder = Qiscus.image(named: "media_balloon")
        
        if cellPos == .last || cellPos == .single{
            avatarImageBase.isHidden = false
            avatarImage.isHidden = false
            displayWidth.constant = 147
            videoFrameWidth.constant = 147
            if user != nil{
                if QiscusHelper.isFileExist(inLocalPath: user!.userAvatarLocalPath){
                    avatarImage.image = UIImage.init(contentsOfFile: user!.userAvatarLocalPath)
                }else{
                    avatarImage.loadAsync(user!.userAvatarURL, placeholderImage: avatar)
                }
            }
            if !comment.isOwnMessage {
                avatarLeading.constant = 0
                maskImage = Qiscus.image(named: "balloon_mask_left")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_left")
                displayLeftMargin.constant = 34
                downloadButtonTrailing.constant = -46
                dateLabelRightMargin.constant = defaultDateLeftMargin
                userNameLabel.textAlignment = .left
                userNameLeading.constant = 53
            }else{
                avatarLeading.constant = screenWidth - 64
                maskImage = Qiscus.image(named: "balloon_mask_right")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_right")
                displayLeftMargin.constant = screenWidth - 200
                downloadButtonTrailing.constant = -61
                dateLabelRightMargin.constant = -41
                statusImageTrailing.constant = -20
                userNameLabel.textAlignment = .right
                userNameLeading.constant = screenWidth - 275
            }
        }else{
            videoFrameWidth.constant = 132
            displayWidth.constant = 132
            maskImage = Qiscus.image(named: "balloon_mask")!
            downloadButtonTrailing.constant = -46
            
            if !comment.isOwnMessage{
                displayLeftMargin.constant = 49
                dateLabelRightMargin.constant = defaultDateLeftMargin
                userNameLabel.textAlignment = .left
                userNameLeading.constant = 53
            }else{
                displayLeftMargin.constant = screenWidth - 200
                dateLabelRightMargin.constant = -25
                userNameLabel.textAlignment = .right
                userNameLeading.constant = screenWidth - 275
            }
        }
        
        
        if file?.fileType == .video{
            self.videoPlay.isHidden = false
            self.videoFrame.isHidden = false
        }else{
            self.videoPlay.isHidden = true
            self.videoFrame.isHidden = true
        }
        
        self.displayFrame.image = maskImage
        self.imageDisplay.image = imagePlaceholder
        
        dateLabel.text = comment.commentTime.lowercased()
        progressLabel.isHidden = true
        if !comment.isOwnMessage{
            dateLabel.textColor = UIColor.white
            statusImage.isHidden = true
        }else{
            dateLabel.textColor = UIColor.white
            statusImage.isHidden = false
            statusImage.tintColor = UIColor.white
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
        self.downloadButton.removeTarget(nil, action: nil, for: .allEvents)
        
        if file != nil {
            if !file!.isLocalFileExist() {
                if QiscusHelper.isFileExist(inLocalPath: file!.fileMiniThumbPath){
                    self.imageDisplay.image = UIImage.init(contentsOfFile: file!.fileMiniThumbPath)
                }else{
                    var thumbLocalPath = file?.fileURL.replacingOccurrences(of: "/upload/", with: "/upload/w_30,c_scale/")
                    if file?.fileType == .video{
                        if let thumbUrlArr = thumbLocalPath?.characters.split(separator: "."){
                            var newThumbURL = ""
                            var i = 0
                            for thumbComponent in thumbUrlArr{
                                if i == 0{
                                    newThumbURL += String(thumbComponent)
                                }else if i < (thumbUrlArr.count - 1){
                                    newThumbURL += ".\(String(thumbComponent))"
                                }else{
                                    newThumbURL += ".png"
                                }
                                i += 1
                            }
                            thumbLocalPath = newThumbURL
                        }
                    }
                    self.imageDisplay.loadAsync(thumbLocalPath!)
                }
                
                self.videoPlay.isHidden = true
                if file!.isDownloading {
                    self.downloadButton.isHidden = true
                    self.progressLabel.text = "\(Int(file!.downloadProgress * 100)) %"
                    self.progressLabel.isHidden = false
                    self.progressContainer.isHidden = false
                    self.progressView.isHidden = false
                    let newHeight = file!.downloadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                    
                }else{
                    self.downloadButton.comment = comment
                    //self.fileNameLabel.hidden = false
                    //self.fileIcon.hidden = false
                    self.downloadButton.addTarget(self, action: #selector(ChatCellMedia.downloadMedia(_:)), for: .touchUpInside)
                    self.downloadButton.isHidden = false
                }
            }else{
                self.downloadButton.isHidden = true
                self.imageDisplay.image = UIImage.init(contentsOfFile: file!.fileThumbPath)
                
                if file!.isUploading{
                    self.progressContainer.isHidden = false
                    self.progressView.isHidden = false
                    let newHeight = file!.uploadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                    if file?.fileType == .video {
                        self.videoPlay.isHidden = true
                    }
                }
            }
        }
        self.videoFrame.layoutIfNeeded()
    }
    
    open func downloadMedia(_ sender: ChatFileButton){
        sender.isHidden = true
        let service = QiscusCommentClient.sharedInstance
        service.downloadMedia(sender.comment!)
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
