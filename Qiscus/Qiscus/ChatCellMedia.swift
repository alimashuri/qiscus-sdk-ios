//
//  ChatCellMedia.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import QAsyncImageView

public class ChatCellMedia: UITableViewCell {

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
    @IBOutlet weak var displayOverlay: UIView!
    @IBOutlet weak var downloadButtonTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var statusImageTrailing: NSLayoutConstraint!
    
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    let maxProgressHeight:CGFloat = 36.0
    var maskImage: UIImage?
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        statusImage.contentMode = .ScaleAspectFit
        progressContainer.layer.cornerRadius = 20
        progressContainer.clipsToBounds = true
        progressContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65).CGColor
        progressContainer.layer.borderWidth = 2
        downloadButton.setImage(Qiscus.image(named: "ic_download_chat")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        downloadButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        self.imageDisplay.contentMode = .ScaleAspectFill
        self.imageDisplay.clipsToBounds = true
        self.imageDisplay.backgroundColor = UIColor.blackColor()
        self.imageDisplay.userInteractionEnabled = true
        self.displayFrame.contentMode = .ScaleAspectFill
        //let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.displayOverlay.verticalGradientColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), bottomColor: UIColor.blackColor())
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func setupCell(comment:QiscusComment, last:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        progressContainer.hidden = true
        progressView.hidden = true
        
        if self.tapRecognizer != nil{
            self.imageDisplay.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        
        let thumbLocalPath = file?.fileURL.stringByReplacingOccurrencesOfString("/upload/", withString: "/upload/w_30,c_scale/")
        
        self.imageDisplay.image = nil

        maskImage = UIImage()
        var imagePlaceholder = Qiscus.image(named: "media_balloon")
        statusImageTrailing.constant = -5
        if last {
            displayWidth.constant = 147
            if position == .Left{
                maskImage = Qiscus.image(named: "balloon_mask_left")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_left")
                displayLeftMargin.constant = 4
                downloadButtonTrailing.constant = -46
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                maskImage = Qiscus.image(named: "balloon_mask_right")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_right")
                displayLeftMargin.constant = screenWidth - 166
                downloadButtonTrailing.constant = -61
                dateLabelRightMargin.constant = -41
                statusImageTrailing.constant = -20
            }
        }else{
            
            displayWidth.constant = 132
            maskImage = Qiscus.image(named: "balloon_mask")
            downloadButtonTrailing.constant = -46
            if position == .Left{
                displayLeftMargin.constant = 19
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                displayLeftMargin.constant = screenWidth - 166
                dateLabelRightMargin.constant = -25
            }
        }
        self.displayFrame.image = maskImage
        self.imageDisplay.image = imagePlaceholder
        
        dateLabel.text = comment.commentTime.lowercaseString
        progressLabel.hidden = true
        if position == .Left {
            dateLabel.textColor = UIColor.whiteColor()
            statusImage.hidden = true
        }else{
            dateLabel.textColor = UIColor.whiteColor()
            statusImage.hidden = false
            statusImage.tintColor = UIColor.whiteColor()
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
        self.downloadButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        
        if file != nil {
            if !file!.isLocalFileExist() {
                
                print("thumbLocalPath: \(thumbLocalPath)")
                self.imageDisplay.loadAsync(thumbLocalPath!)
                //self.imageDispay.image = UIImageView.maskImage(Qiscus.image(named: "testImage")!, mask: Qiscus.image(named: "balloon_mask_left")!)
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
                    //self.fileNameLabel.hidden = false
                    //self.fileIcon.hidden = false
                    self.downloadButton.addTarget(self, action: #selector(ChatCellMedia.downloadMedia(_:)), forControlEvents: .TouchUpInside)
                    self.downloadButton.hidden = false
                }
            }else{
                self.downloadButton.hidden = true
                //self.mediaDisplay.loadAsync("file://\(file!.fileThumbPath)")
                self.imageDisplay.loadAsync("file://\(file!.fileThumbPath)")
                if file!.isUploading{
                    self.progressContainer.hidden = false
                    self.progressView.hidden = false
                    let newHeight = file!.uploadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                }
            }
        }
        //self.imageDispay.backgroundColor = UIColor.yellowColor()
    }
    
    public func downloadMedia(sender: ChatFileButton){
        sender.hidden = true
        let service = QiscusCommentClient.sharedInstance
        service.downloadMedia(sender.comment!)
    }
    
    
}
