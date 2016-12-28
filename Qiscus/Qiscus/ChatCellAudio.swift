//
//  ChatCellAudio.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/21/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatCellAudioDelegate {
    func didTapPlayButton(_ button: UIButton, onCell cell: ChatCellAudio)
    func didTapPauseButton(_ button: UIButton, onCell cell: ChatCellAudio)
    func didTapDownloadButton(_ button: UIButton, onCell cell: ChatCellAudio)
    func didStartSeekTimeSlider(_ slider: UISlider, onCell cell: ChatCellAudio)
    func didEndSeekTimeSlider(_ slider: UISlider, onCell cell: ChatCellAudio)
    
}

class ChatCellAudio: UITableViewCell {

    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var seekTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressImageView: UIImageView!
    @IBOutlet weak var avatarImageBase: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    @IBOutlet weak var containerLeading: NSLayoutConstraint!
    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
    @IBOutlet weak var dateLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var balloonWidth: NSLayoutConstraint!
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var balloonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var userNameLeading: NSLayoutConstraint!
    
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    var indexPath:IndexPath?
    
    var isDownloading = false{
        didSet {
            self.playButton.removeTarget(nil, action: nil, for: .allEvents)
            if isDownloading {
                self.progressImageView.image = Qiscus.image(named: "audio_download")
                self.progressContainer.isHidden = false
            }
        }
    }
    var filePath = "" {
        didSet {
            self.playButton.removeTarget(nil, action: nil, for: .allEvents)
            if filePath == "" {
                self.progressContainer.isHidden = true
                self.playButton.setImage(Qiscus.image(named: "audio_download"), for: UIControlState())
                self.playButton.addTarget(self, action: #selector(downloadButtonTapped(_:)), for: .touchUpInside)
            }else{
                self.progressContainer.isHidden = true
                self.playButton.setImage(Qiscus.image(named: "play_audio"), for: UIControlState())
                self.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    var isPlaying = false {
        didSet {
            self.playButton.removeTarget(nil, action: nil, for: .allEvents)
            if isPlaying {
                self.playButton.setImage(Qiscus.image(named: "audio_pause"), for: UIControlState())
                self.playButton.addTarget(self, action: #selector(pauseButtonTapped(_:)), for: .touchUpInside)
            } else {
                self.playButton.setImage(Qiscus.image(named: "play_audio"), for: UIControlState())
                self.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    var delegate: ChatCellAudioDelegate?
    var _timeFormatter: DateComponentsFormatter?
    var timeFormatter: DateComponentsFormatter? {
        get {
            if _timeFormatter == nil {
                _timeFormatter = DateComponentsFormatter()
                _timeFormatter?.zeroFormattingBehavior = .pad;
                _timeFormatter?.allowedUnits = [.minute, .second]
                _timeFormatter?.unitsStyle = .positional;
            }
            
            return _timeFormatter
        }
        
        set {
            _timeFormatter = newValue
        }
    }
    var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressContainer.layer.cornerRadius = 15
        progressContainer.clipsToBounds = true
        fileContainer.layer.cornerRadius = 10
        statusImage.contentMode = .scaleAspectFit
        avatarImage.layer.cornerRadius = 19
        avatarImage.clipsToBounds = true
        avatarImage.isHidden = true
        avatarImage.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    open func setupCell(_ comment:QiscusComment, last:Bool, position:CellPosition, cellVPos: CellTypePosition? = nil){
        self.selectionStyle = .none
        self.progressHeight.constant = 0
        self.progressContainer.isHidden = true
        self.currentTimeSlider.value = 0
        self.durationLabel.text = ""
        
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
        
        var path = ""
        var file = QiscusFile()
        if let audioFile = QiscusFile.getCommentFileWithComment(comment){
            file = audioFile
            if file.isOnlyLocalFileExist{
                path = file.fileLocalPath
            }
        }
        filePath = path
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
            statusImage.isHidden = true
        }else{
            avatarLeading.constant = screenWidth - 64
            if last{
                containerTrailing.constant = -19
            }
            userNameLabel.textAlignment = .right
            userNameLeading.constant = screenWidth - 275
            leftMargin.constant = screenWidth - 268
            balloonView.tintColor = QiscusColorConfiguration.sharedInstance.rightBaloonColor
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
        
        if file.isOnlyLocalFileExist{
            let audioURL = URL(fileURLWithPath: file.fileLocalPath)
            let audioAsset = AVURLAsset(url: audioURL)
            audioAsset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: {
                var error: NSError? = nil
                let status = audioAsset.statusOfValue(forKey: "duration", error: &error)
                switch status {
                case .loaded:
                    let duration = Double(CMTimeGetSeconds(audioAsset.duration))
                    self.currentTimeSlider.maximumValue = Float(duration)
                    self.durationLabel.text = self.timeFormatter?.string(from: duration)
                    break
                default:
                    break
                }
            })
        }
        if file.isUploading {
            let uploadProgres = Int(file.uploadProgress * 100)
            let uploading = QiscusTextConfiguration.sharedInstance.uploadingText
            
            self.progressImageView.image = Qiscus.image(named: "audio_upload")
            self.progressContainer.isHidden = false
            self.progressHeight.constant = file.uploadProgress * 30
            dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.isPlaying = true
        self.delegate?.didTapPlayButton(sender, onCell: self)
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        self.isPlaying = false
        self.delegate?.didTapPauseButton(sender, onCell: self)
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapDownloadButton(sender, onCell: self)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.seekTimeLabel.text = timeFormatter?.string(from: Double(sender.value))
        self.delegate?.didStartSeekTimeSlider(sender, onCell: self)
    }
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
        self.delegate?.didEndSeekTimeSlider(sender, onCell: self)
    }
    open func deleteComment(){
        if QiscusCommentClient.sharedInstance.commentDelegate != nil{
            QiscusCommentClient.sharedInstance.commentDelegate?.performDeleteMessage(onIndexPath: self.indexPath!)
        }
    }
    open func resend(){
        if QiscusCommentClient.sharedInstance.commentDelegate != nil{
            QiscusCommentClient.sharedInstance.commentDelegate?.performResendMessage(onIndexPath: self.indexPath!)
        }
    }
}
