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
    @IBOutlet weak var downloadButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var videoPlay: UIImageView!
    
    @IBOutlet weak var statusImageTrailing: NSLayoutConstraint!
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    
    @IBOutlet weak var videoFrame: UIImageView!
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    let maxProgressHeight:CGFloat = 36.0
    var maskImage: UIImage?
    var indexPath:IndexPath?
    var isVideo = false
    
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
    
    open func setupCell(_ comment:QiscusComment, last:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        let user = comment.sender
        avatarImage.image = Qiscus.image(named: "in_chat_avatar")
        avatarImage.isHidden = true
        avatarImageBase.isHidden = true
        
        progressContainer.isHidden = true
        progressView.isHidden = true
        
        if self.tapRecognizer != nil{
            self.imageDisplay.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        
        self.imageDisplay.image = nil
        if file?.fileType == .video{
            self.videoPlay.isHidden = false
            self.videoFrame.isHidden = false
        }else{
            self.videoPlay.isHidden = true
            self.videoFrame.isHidden = true
        }
        maskImage = UIImage()
        var imagePlaceholder = Qiscus.image(named: "media_balloon")
        statusImageTrailing.constant = -5
        if last {
            avatarImage.image = Qiscus.image(named: "in_chat_avatar")
            avatarImageBase.isHidden = false
            avatarImage.isHidden = false
            displayWidth.constant = 147
            videoFrameWidth.constant = 147
            if user != nil{
                avatarImage.loadAsync(user!.userAvatarURL)
            }
            if position == .left{
                avatarLeading.constant = 0
                maskImage = Qiscus.image(named: "balloon_mask_left")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_left")
                displayLeftMargin.constant = 34
                downloadButtonTrailing.constant = -46
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                avatarLeading.constant = screenWidth - 64
                maskImage = Qiscus.image(named: "balloon_mask_right")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_right")
                displayLeftMargin.constant = screenWidth - 200
                downloadButtonTrailing.constant = -61
                dateLabelRightMargin.constant = -41
                statusImageTrailing.constant = -20
            }
        }else{
            videoFrameWidth.constant = 132
            displayWidth.constant = 132
            maskImage = Qiscus.image(named: "balloon_mask")
            downloadButtonTrailing.constant = -46
            if position == .left{
                displayLeftMargin.constant = 49
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                displayLeftMargin.constant = screenWidth - 200
                dateLabelRightMargin.constant = -25
            }
        }
        self.displayFrame.image = maskImage
        self.imageDisplay.image = imagePlaceholder
        
        dateLabel.text = comment.commentTime.lowercased()
        progressLabel.isHidden = true
        if position == .left {
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
                self.imageDisplay.loadAsync("file://\(file!.fileThumbPath)")
                
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
