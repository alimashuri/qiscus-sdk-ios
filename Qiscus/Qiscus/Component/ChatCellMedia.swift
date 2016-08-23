//
//  ChatCellMedia.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import QAsyncImageView

class ChatCellMedia: UITableViewCell {

    @IBOutlet weak var mediaDisplay: UIImageView!
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: ChatFileButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    let maxProgressHeight:CGFloat = 36.0
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubleView.layer.cornerRadius = 14
        statusImage.contentMode = .ScaleAspectFit
        mediaDisplay.contentMode = .ScaleAspectFill
        mediaDisplay.layer.cornerRadius = 10
        mediaDisplay.userInteractionEnabled = true
        fileIcon.image = UIImage(named: "ic_img")?.imageWithRenderingMode(.AlwaysTemplate)
        fileIcon.tintColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        progressContainer.layer.cornerRadius = 20
        progressContainer.clipsToBounds = true
        progressContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65).CGColor
        progressContainer.layer.borderWidth = 2
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(comment:QiscusComment, first:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        progressContainer.hidden = true
        progressView.hidden = true
        
        if self.tapRecognizer != nil{
            self.mediaDisplay.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        self.mediaDisplay.image = nil
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
        dateLabel.text = comment.commentTime.lowercaseString
        progressLabel.hidden = true
        if position == .Left {
            leftMargin.constant = 15
            bubleView.backgroundColor = QiscusUIConfiguration.sharedInstance.leftBaloonColor
            dateLabel.textColor = QiscusUIConfiguration.sharedInstance.leftBaloonTextColor
            dateLabelRightMargin.constant = defaultDateLeftMargin
            statusImage.hidden = true
        }else{
            leftMargin.constant = screenWidth - 170
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
                statusImage.image = UIImage(named: "ic_warning")?.imageWithRenderingMode(.AlwaysTemplate)
                statusImage.tintColor = QiscusUIConfiguration.sharedInstance.failToSendColor
            }
            
        }
        self.downloadButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        
        if file != nil {
            if !file!.isLocalFileExist() {
                
                if file!.isDownloading {
                    self.downloadButton.hidden = true
                    self.progressLabel.text = "\(Int(file!.downloadProgress * 100)) %"
                    self.progressLabel.hidden = false
                    self.progressContainer.hidden = false
                    self.progressView.hidden = false
                    let newHeight = file!.downloadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                }else{
                    self.downloadButton.comment = comment
                    self.fileNameLabel.hidden = false
                    self.fileIcon.hidden = false
                    self.downloadButton.addTarget(self, action: #selector(ChatCellMedia.downloadMedia(_:)), forControlEvents: .TouchUpInside)
                    self.downloadButton.hidden = false
                }
            }else{
                self.downloadButton.hidden = true
                self.mediaDisplay.loadAsync("file://\(file!.fileThumbPath)")
                self.fileNameLabel.hidden = true
                self.fileIcon.hidden = true
                if file!.isUploading{
                    self.progressContainer.hidden = false
                    self.progressView.hidden = false
                    let newHeight = file!.uploadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                }
            }
        }
    }
    
    func downloadMedia(sender: ChatFileButton){
        sender.hidden = true
        let service = QiscusCommentClient.sharedInstance
        service.downloadMedia(sender.comment!)
    }

    
}
