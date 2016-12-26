//
//  QiscusChatVC.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos
import ImageViewer
import IQAudioRecorderController

open class QiscusChatVC: UIViewController, ChatInputTextDelegate, QCommentDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIDocumentPickerDelegate, GalleryItemsDatasource, IQAudioRecorderViewControllerDelegate, AVAudioPlayerDelegate, ChatCellAudioDelegate{
    
    static let sharedInstance = QiscusChatVC()
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var inputBar: UIView!
    @IBOutlet weak var inputText: ChatInputText!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var welcomeSubtitle: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var galeryButton: UIButton!
    @IBOutlet weak var archievedNotifView: UIView!
    @IBOutlet weak var archievedNotifLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var emptyChatImage: UIImageView!
    
    // MARK: - Constrain
    @IBOutlet weak var minInputHeight: NSLayoutConstraint!
    @IBOutlet weak var archievedNotifTop: NSLayoutConstraint!
    @IBOutlet weak var inputBarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstrain: NSLayoutConstraint!
    
    
    // MARK: - View Attributes
    var defaultViewHeight:CGFloat = 0
    var isPresence:Bool = false
    
    // MARK: - Data Properties
    var hasMoreComment = true
    var loadMoreControl = UIRefreshControl()
    var commentClient = QiscusCommentClient.sharedInstance
    var topicId = QiscusUIConfiguration.sharedInstance.topicId
    var users:[String] = QiscusUIConfiguration.sharedInstance.chatUsers
    var consultantId: Int = 0
    var consultantRate:Int = 0
    var comment = [[QiscusComment]]()
    var archived:Bool = QiscusUIConfiguration.sharedInstance.readOnly
    var rowHeight:[IndexPath: CGFloat] = [IndexPath: CGFloat]()
    var firstLoad = true
    
    var topColor = UIColor(red: 8/255.0, green: 153/255.0, blue: 140/255.0, alpha: 1.0)
    var bottomColor = UIColor(red: 23/255.0, green: 177/255.0, blue: 149/255.0, alpha: 1)
    var tintColor = UIColor.white
    var syncTimer:Timer?
    var selectedImage:UIImage = UIImage()
    var imagePreview:GalleryViewController?
    var loadWithUser:Bool = false
    var distincId:String = ""
    var optionalData:String?
    var galleryItems:[QiscusGalleryItem] = [QiscusGalleryItem]()
    var roomId:Int = 0
    
    //MARK: - external action
    open var unlockAction:(()->Void) = {}
    open var cellDelegate:QiscusChatCellDelegate?
    open var optionalDataCompletion:((String)->Void)?
    open var titleAction:(()->Void) = {}
    
    var audioPlayer: AVAudioPlayer?
    var audioTimer: Timer?
    var activeAudioCell: ChatCellAudio?
    
    var loadingView = QLoadingViewController.sharedInstance
    
    var bundle:Bundle {
        get{
            return Qiscus.bundle
        }
    }
    var sendOnImage:UIImage?{
        get{
            return UIImage(named: "ic_send_on", in: self.bundle, compatibleWith: nil)?.localizedImage()
        }
    }
    var sendOffImage:UIImage?{
        get{
            return UIImage(named: "ic_send_off", in: self.bundle, compatibleWith: nil)?.localizedImage()
        }
    }
    var nextIndexPath:IndexPath{
        get{
            let indexPath = QiscusHelper.getNextIndexPathIn(groupComment:self.comment)
            return IndexPath(row: indexPath.row, section: indexPath.section)
        }
    }
    var isLastRowVisible: Bool {
        get{
            if self.comment.count > 0{
                let lastSection = self.comment.count - 1
                let lastRow = self.comment[lastSection].count - 1
                if let indexPaths = self.tableView.indexPathsForVisibleRows {
                    for indexPath in indexPaths {
                        if (indexPath as NSIndexPath).section == lastSection && (indexPath as NSIndexPath).row == lastRow{
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
    
    var lastVisibleRow:IndexPath?{
        get{
            if self.comment.count > 0{
                if let indexPaths = self.tableView.indexPathsForVisibleRows {
                    return indexPaths.last!
                }
            }
            return nil
        }
    }
    var UTIs:[String]{
        get{
            return ["public.jpeg", "public.png"/*,"com.compuserve.gif"*/,"public.text", "public.archive", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.​ppt", "com.adobe.pdf","public.mpeg-4"]
        }
    }
    
    fileprivate init() {
        super.init(nibName: "QiscusChatVC", bundle: Qiscus.bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.emptyChatImage.image = Qiscus.image(named: "empty_messages")?.withRenderingMode(.alwaysTemplate)
        self.emptyChatImage.tintColor = self.bottomColor
        commentClient.commentDelegate = self
        
        let resendMenuItem: UIMenuItem = UIMenuItem(title: "Resend", action: #selector(ChatCellText.resend))
        let deleteMenuItem: UIMenuItem = UIMenuItem(title: "Delete", action: #selector(ChatCellText.deleteComment))
        let menuItems:[UIMenuItem] = [resendMenuItem,deleteMenuItem]
        UIMenuController.shared.menuItems = menuItems
    }
    override open func viewWillDisappear(_ animated: Bool) {
        self.isPresence = false
        super.viewWillDisappear(animated)
        //self.syncTimer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        self.view.endEditing(true)
        if let room = QiscusRoom.getRoom(withLastTopicId: self.topicId){
            self.unsubscribeTypingRealtime(onRoom: room)
        }
        if audioPlayer != nil{
            audioPlayer?.stop()
        }
    }
    override open func viewWillAppear(_ animated: Bool) {
        self.isPresence = true
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false , animated: false)
        self.tableView.reloadData()
        self.isPresence = true
        firstLoad = true
        self.topicId = QiscusUIConfiguration.sharedInstance.topicId
        self.archived = QiscusUIConfiguration.sharedInstance.readOnly
        self.users = QiscusUIConfiguration.sharedInstance.chatUsers
        self.emptyChatImage.image = Qiscus.image(named: "empty_messages")?.withRenderingMode(.alwaysTemplate)
        self.emptyChatImage.tintColor = self.bottomColor
        let sendImage = Qiscus.image(named: "ic_send_on")?.withRenderingMode(.alwaysTemplate)
        let documentImage = Qiscus.image(named: "ic_add_file")?.withRenderingMode(.alwaysTemplate)
        let galeryImage = Qiscus.image(named: "ic_add_image")?.withRenderingMode(.alwaysTemplate)
        let cameraImage = Qiscus.image(named: "ic_pick_picture")?.withRenderingMode(.alwaysTemplate)
        let audioImage = Qiscus.image(named: "ic_add_audio")?.withRenderingMode(.alwaysTemplate)
        self.sendButton.setImage(sendImage, for: .normal)
        self.documentButton.setImage(documentImage, for: .normal)
        self.galeryButton.setImage(galeryImage, for: .normal)
        self.cameraButton.setImage(cameraImage, for: .normal)
        self.audioButton.setImage(audioImage, for: .normal)
        setupPage()
        loadData()
    }
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.comment = [[QiscusComment]]()
        self.tableView.reloadData()
    }
    // MARK: - Memory Warning
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup UI
    func setupPage(){
        archievedNotifView.isHidden = !archived
        self.archievedNotifTop.constant = 0
        if archived {
            self.archievedNotifLabel.text = QiscusTextConfiguration.sharedInstance.readOnlyText
        }else{
            self.archievedNotifTop.constant = 65
        }
        if Qiscus.sharedInstance.iCloudUpload {
            self.documentButton.isHidden = false
        }else{
            self.documentButton.isHidden = true
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.archievedNotifView.backgroundColor = QiscusColorConfiguration.sharedInstance.lockViewBgColor
        self.archievedNotifLabel.textColor = QiscusColorConfiguration.sharedInstance.lockViewTintColor
        let unlockImage = Qiscus.image(named: "ic_open_archived")?.withRenderingMode(.alwaysTemplate)
        self.unlockButton.setBackgroundImage(unlockImage, for: UIControlState())
        self.unlockButton.tintColor = QiscusColorConfiguration.sharedInstance.lockViewTintColor
        
        
        self.tableView.register(UINib(nibName: "ChatCellText",bundle: Qiscus.bundle), forCellReuseIdentifier: "cellText")
        self.tableView.register(UINib(nibName: "ChatCellMedia",bundle: Qiscus.bundle), forCellReuseIdentifier: "cellMedia")
        self.tableView.register(UINib(nibName: "ChatCellDocs",bundle: Qiscus.bundle), forCellReuseIdentifier: "cellDocs")
        self.tableView.register(UINib(nibName: "ChatCellAudio",bundle: Qiscus.bundle), forCellReuseIdentifier: "cellAudio")
        
        let titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = QiscusTextConfiguration.sharedInstance.chatTitle
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame:CGRect(x: 0, y: 18, width: 0, height: 0))
        subTitleLabel.backgroundColor = UIColor.clear
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.font = UIFont.systemFont(ofSize: 11)
        subTitleLabel.text = QiscusTextConfiguration.sharedInstance.chatSubtitle
        subTitleLabel.sizeToFit()
        
        let titleView = UIButton(frame: CGRect(x: 0, y: 0, width: max(subTitleLabel.frame.size.width,titleLabel.frame.size.width), height: 30))
        
        if titleLabel.frame.width >= subTitleLabel.frame.width {
            var adjustment = subTitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subTitleLabel.frame.width/2)
            subTitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subTitleLabel)
        titleView.addTarget(self, action: #selector(QiscusChatVC.goToTitleAction), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.titleView = titleView
        
        
            self.navigationController?.navigationBar.verticalGradientColor(topColor, bottomColor: bottomColor)
            self.navigationController?.navigationBar.tintColor = tintColor
        
        let backButton = QiscusChatVC.backButton(self, action: #selector(QiscusChatVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = backButton
        
        // loadMoreControl
        self.loadMoreControl.addTarget(self, action: #selector(QiscusChatVC.loadMore), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.loadMoreControl)
        
        
        if inputText.value == "" {
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
        sendButton.addTarget(self, action: #selector(QiscusChatVC.sendMessage), for: .touchUpInside)
        
        //welcomeView Setup
        self.unlockButton.addTarget(self, action: #selector(QiscusChatVC.confirmUnlockChat), for: .touchUpInside)
        
        
        self.welcomeText.text = QiscusTextConfiguration.sharedInstance.emptyTitle
        self.welcomeSubtitle.text = QiscusTextConfiguration.sharedInstance.emptyMessage
        
        self.inputText.textContainerInset = UIEdgeInsets.zero
        self.inputText.placeholder = QiscusTextConfiguration.sharedInstance.textPlaceholder
        self.inputText.chatInputDelegate = self
        self.defaultViewHeight = self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! - QiscusHelper.statusBarSize().height
        
        // upload button setup
        self.galeryButton.addTarget(self, action: #selector(self.uploadImage), for: .touchUpInside)
        self.cameraButton.addTarget(self, action: #selector(QiscusChatVC.uploadFromCamera), for: .touchUpInside)
        self.documentButton.addTarget(self, action: #selector(QiscusChatVC.iCloudOpen), for: .touchUpInside)
        self.audioButton.addTarget(self, action: #selector(QiscusChatVC.recordAudio), for: .touchUpInside)
        
        // Keyboard stuff.
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(QiscusChatVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(QiscusChatVC.keyboardChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        center.addObserver(self, selector: #selector(QiscusChatVC.appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        self.hideKeyboardWhenTappedAround()
    }
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = QiscusTextConfiguration.sharedInstance.galeryAccessAlertText
            let cancelTxt = QiscusTextConfiguration.sharedInstance.alertCancelText
            let settingTxt = QiscusTextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                doneAction: {
                    self.goToIPhoneSetting()
                },
                cancelAction: {}
            )
        })
    }
    func showCameraAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = QiscusTextConfiguration.sharedInstance.cameraAccessAlertText
            let cancelTxt = QiscusTextConfiguration.sharedInstance.alertCancelText
            let settingTxt = QiscusTextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                doneAction: {
                    self.goToIPhoneSetting()
                },
                cancelAction: {}
            )
        })
    }
    func showMicrophoneAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = QiscusTextConfiguration.sharedInstance.microphoneAccessAlertText
            let cancelTxt = QiscusTextConfiguration.sharedInstance.alertCancelText
            let settingTxt = QiscusTextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        })
    }
    func goToTitleAction(){
        self.titleAction()
    }
    // MARK: - Keyboard Methode
    func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let goToRow = self.lastVisibleRow
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.inputBarBottomMargin.constant = 0
            self.view.layoutIfNeeded()
            if goToRow != nil {
                self.scrollToIndexPath(goToRow!, position: .bottom, animated: true, delayed:  false)
            }
            }, completion: nil)
    }
    func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        let goToRow = self.lastVisibleRow
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.inputBarBottomMargin.constant = 0 - keyboardHeight
            self.view.layoutIfNeeded()
            if goToRow != nil {
                self.scrollToIndexPath(goToRow!, position: .bottom, animated: true, delayed:  false)
            }
            }, completion: nil)
        
    }
    
    // MARK: - ChatInputTextDelegate Delegate
    open func chatInputTextDidChange(chatInput input: ChatInputText, height: CGFloat) {
        self.minInputHeight.constant = height
        
        if let room = QiscusRoom.getRoom(withLastTopicId: self.topicId){
            let message: String = "1";
            let data: Data = message.data(using: .utf8)!
            let channel = "r/\(room.roomId)/\(self.topicId)/\(QiscusMe.sharedInstance.email)/t"
            print("[Qiscus] Realtime publish to channel: \(channel)")
            Qiscus.sharedInstance.mqtt?.publish(data, in: channel, delivering: .atLeastOnce, retain: false, completion: nil)
        }
        input.layoutIfNeeded()
    }
    open func valueChanged(value:String){
        if value == "" {
            sendButton.isEnabled = false
            //sendButton.setBackgroundImage(self.sendOffImage, for: UIControlState())
        }else{
            sendButton.isEnabled = true
            //sendButton.setBackgroundImage(self.sendOnImage, for: UIControlState())
        }
    }
    open func chatInputDidEndEditing(chatInput input: ChatInputText) {
        if let room = QiscusRoom.getRoom(withLastTopicId: self.topicId){
            let message: String = "0";
            let data: Data = message.data(using: .utf8)!
            let channel = "r/\(room.roomId)/\(self.topicId)/\(QiscusMe.sharedInstance.email)/t"
            print("[Qiscus] Realtime publish to channel: \(channel)")
            Qiscus.sharedInstance.mqtt?.publish(data, in: channel, delivering: .atLeastOnce, retain: false, completion: nil)
        }
    }
    
    // MARK: - Table View DataSource
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.comment[section].count
    }
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let comment = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        var cellPosition: CellPosition = CellPosition.left
        if comment.commentSenderEmail == QiscusConfig.sharedInstance.USER_EMAIL{
            cellPosition = CellPosition.right
        }
        var last = false
        if (indexPath as NSIndexPath).row == (self.comment[(indexPath as NSIndexPath).section].count - 1){
            last = true
        }else{
            let commentAfter = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row + 1]
            if (commentAfter.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                last = true
            }
        }

        if comment.commentType == QiscusCommentType.text {
            let tableCell = cell as! ChatCellText
            
            tableCell.setupCell(comment,last: last, position: cellPosition)
            //return cell
        }else{
            let file = QiscusFile.getCommentFile(comment.commentFileId)
            if file?.fileType == QFileType.media || file?.fileType == QFileType.video{
                let tableCell = cell as! ChatCellMedia
                tableCell.setupCell(comment, last: last, position: cellPosition)
                
                if file!.isLocalFileExist(){
                    tableCell.tapRecognizer = ChatTapRecognizer(target:self, action:#selector(QiscusChatVC.tapMediaDisplay(_:)))
                    tableCell.tapRecognizer?.fileName = (file?.fileName)!
                    tableCell.tapRecognizer?.fileType = .media
                    tableCell.tapRecognizer?.fileURL = (file?.fileURL)!
                    tableCell.tapRecognizer?.fileLocalPath = (file?.fileLocalPath)!
                    tableCell.imageDisplay.addGestureRecognizer(tableCell.tapRecognizer!)
                }
            }
            else if file?.fileType == QFileType.audio{
                let tableCell = cell as! ChatCellAudio
                tableCell.setupCell(comment, last: last, position: cellPosition)
            }
            else{
                let tableCell = cell as! ChatCellDocs
                tableCell.setupCell(comment, last: last, position: cellPosition)
                
                if !file!.isUploading{
                    tableCell.tapRecognizer = ChatTapRecognizer(target:self, action:#selector(QiscusChatVC.tapChatFile(_:)))
                    tableCell.tapRecognizer?.fileURL = file!.fileURL
                    tableCell.tapRecognizer?.fileName = file!.fileName
                    tableCell.fileContainer.addGestureRecognizer(tableCell.tapRecognizer!)
                }
            }
        }
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let comment = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        comment.updateCommmentIndexPath(indexPath: indexPath)
        if comment.commentType == QiscusCommentType.text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellText", for: indexPath) as! ChatCellText
            cell.indexPath = indexPath
            return cell
        }else{
            let file = QiscusFile.getCommentFile(comment.commentFileId)
            if file?.fileType == QFileType.media || file?.fileType ==  QFileType.video{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellMedia", for: indexPath) as! ChatCellMedia
                cell.indexPath = indexPath
                return cell
            }
            else if file?.fileType == QFileType.audio{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAudio", for: indexPath) as! ChatCellAudio
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDocs", for: indexPath) as! ChatCellDocs
                cell.indexPath = indexPath
                return cell
            }
        }
        
    }
    open func numberOfSections(in tableView: UITableView) -> Int{
        return self.comment.count
    }
    
    // MARK: - TableView Delegate
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let comment = self.comment[indexPath.section][indexPath.row]

        if action == #selector(UIResponderStandardEditActions.copy(_:)) && comment.commentType == .text{
            return true
        }else if action == #selector(ChatCellText.resend) && comment.commentStatus == .failed && comment.commentType == .text {
            return true
        }else if action == #selector(ChatCellText.deleteComment) && comment.commentStatus == .failed {
            return true
        }
        return false
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let textComment = self.comment[indexPath.section][indexPath.row]
        
        if action == #selector(UIResponderStandardEditActions.copy(_:)) && textComment.commentType == .text{
            UIPasteboard.general.string = textComment.commentText
        }
    }
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 35
    }
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        var height:CGFloat = 50
        let comment = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        var last = false
        if (indexPath as NSIndexPath).row == (self.comment[(indexPath as NSIndexPath).section].count - 1){
            last = true
        }else{
            let commentAfter = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row + 1]
            if (commentAfter.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                last = true
            }
        }
        if self.comment.count > 0 {
            let comment = self.comment[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            
            if comment.commentType == QiscusCommentType.text {
                height = ChatCellText.calculateRowHeightForComment(comment: comment)
            }else{
                let file = QiscusFile.getCommentFile(comment.commentFileId)
                
                if file?.fileType == QFileType.media || file?.fileType == QFileType.video {
                    height = 140
                }else if file?.fileType == QFileType.audio{
                    height = 87
                }else{
                    height = 70
                }
            }
        }
        if !last{
            height -= 5
        }
        return height
    }
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let comment = self.comment[section][0]
        
        var date:String = ""
        
        if comment.commentDate == QiscusHelper.thisDateString {
            date = QiscusTextConfiguration.sharedInstance.todayText
        }else{
            date = comment.commentDate
        }

        let view = UIView(frame: CGRect(x: 0,y: 10,width: QiscusHelper.screenWidth(),height: 20))
        view.backgroundColor = UIColor.clear
        
        let dateLabel = UILabel()
        dateLabel.textAlignment = .center
        dateLabel.text = date
        dateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        dateLabel.textColor = UIColor(red: 63/255.0, green: 63/255.0, blue: 63/255.0, alpha: 1)
        
        let textSize = dateLabel.sizeThatFits(CGSize(width: QiscusHelper.screenWidth(), height: 20))
        let textWidth = textSize.width + 30
        let textHeight = textSize.height + 6
        let cornerRadius:CGFloat = textHeight / 2
        let xPos = (QiscusHelper.screenWidth() - textWidth) / 2
        let dateFrame = CGRect(x: xPos, y: 10, width: textWidth, height: textHeight)
        dateLabel.frame = dateFrame
        dateLabel.layer.cornerRadius = cornerRadius
        dateLabel.clipsToBounds = true
        dateLabel.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.7)
        dateLabel.textColor = UIColor.white
        view.addSubview(dateLabel)
        
        return view
    }
    
    func scrollToBottom(_ animated:Bool = false){
        if self.comment.count > 0{
            let section = self.comment.count - 1
            let row = self.comment[section].count - 1
            let bottomIndexPath = IndexPath(row: row, section: section)
            scrollToIndexPath(bottomIndexPath, position: .bottom, animated: animated)
        }
    }
    func scrollToIndexPath(_ indexPath:IndexPath, position: UITableViewScrollPosition, animated:Bool, delayed:Bool = true){
        
        if !delayed {
            self.tableView?.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }else{
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if self.comment.count > 0 {
                self.tableView?.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom,
                    animated: false)
                }
            })
        }
    }
    // MARK: - Navigation Action
    func rightLeftButtonAction(_ sender: AnyObject) {
    }
    func righRightButtonAction(_ sender: AnyObject) {
    }
    func goBack() {
        self.isPresence = false
        if Qiscus.sharedInstance.isPushed {
            let _ = self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Load DataSource
    func loadData(){
        
        if(self.topicId > 0){
            self.comment = QiscusComment.groupAllCommentByDate(self.topicId,limit:20,firstLoad: true)
            let room = QiscusRoom.getRoom(withLastTopicId: self.topicId)
            
            if self.optionalDataCompletion != nil && room != nil{
                self.optionalDataCompletion!(room!.optionalData)
            }
            self.subscribeRealtime(onRoom: room)
            if self.comment.count > 0 {
                self.tableView.reloadData()
                scrollToBottom()
                self.welcomeView.isHidden = true
                
                commentClient.syncMessage(self.topicId)
            }else{
                self.welcomeView.isHidden = false
                self.showLoading("Load Data ...")
                commentClient.getListComment(topicId: self.topicId, commentId: 0, triggerDelegate: true)
            }
        }else{
            if self.users.count > 0 {
                loadWithUser = true
                if self.users.count == 1 {
                    if let room = QiscusRoom.getRoom(self.distincId, andUserEmail: self.users.first!){
                        self.topicId = room.roomLastCommentTopicId
                        self.comment = QiscusComment.groupAllCommentByDate(self.topicId,limit:20,firstLoad: true)
                        
                        self.subscribeRealtime(onRoom: room)
                        
                        if self.comment.count > 0 {
                            self.tableView.reloadData()
                            scrollToBottom()
                            self.welcomeView.isHidden = true
                            if self.optionalDataCompletion != nil{
                                self.optionalDataCompletion!(room.optionalData)
                            }
                            commentClient.syncMessage(self.topicId)
                        }else{
                            self.welcomeView.isHidden = false
                            if self.optionalDataCompletion != nil{
                                self.optionalDataCompletion!(room.optionalData)
                            }
                            self.showLoading("Load Data ...")
                            commentClient.getListComment(topicId: self.topicId, commentId: 0, triggerDelegate: true)
                            
                        }
                    }else{
                        self.showLoading("Load Data ...")
                        commentClient.getListComment(withUsers: users, triggerDelegate: true, distincId: self.distincId, optionalData:self.optionalData, optionalDataCompletion: {optionalData
                            in
                            if self.optionalDataCompletion != nil{
                                self.optionalDataCompletion!(optionalData)
                            }
                            print("optional data from getListComment: \(optionalData)")
                        })
                    }
                }else{
                    self.showLoading("Load Data ...")
                    commentClient.getListComment(withUsers: users, triggerDelegate: true, distincId: self.distincId, optionalData:self.optionalData, optionalDataCompletion: {optionalData
                        in
                        if self.optionalDataCompletion != nil{
                            self.optionalDataCompletion!(optionalData)
                        }
                    })
                }
            }else{
                if let room = QiscusRoom.getRoomById(self.roomId){
                    self.comment = QiscusComment.groupAllCommentByDateInRoom(self.roomId, limit: 20, firstLoad: true)
                    if self.comment.count > 0 {
                        self.topicId = room.roomLastCommentTopicId
                        self.tableView.reloadData()
                        scrollToBottom()
                        self.welcomeView.isHidden = true
                        if self.optionalDataCompletion != nil{
                            self.optionalDataCompletion!(room.optionalData)
                        }
                        commentClient.syncMessage(self.topicId)
                    }else{
                        self.welcomeView.isHidden = false
                        if self.optionalDataCompletion != nil{
                            self.optionalDataCompletion!(room.optionalData)
                        }
                        self.showLoading("Load Data ...")
                        commentClient.getRoom(withID: self.roomId, triggerDelegate: true, optionalDataCompletion: {optionalData in
                            if self.optionalDataCompletion != nil{
                                self.optionalDataCompletion!(optionalData)
                            }
                        })
                    }
                }else{
                    self.welcomeView.isHidden = false
                    self.showLoading("Load Data ...")
                    commentClient.getRoom(withID: self.roomId, triggerDelegate: true, optionalDataCompletion: {optionalData in
                        if self.optionalDataCompletion != nil{
                            self.optionalDataCompletion!(optionalData)
                        }
                    })
                }
                
                
            }
        }
    }
    func syncData(){
        if Qiscus.sharedInstance.connected{
        if self.topicId > 0 {
            if self.comment.count > 0 {
                commentClient.syncMessage(self.topicId)
            }else{
                if self.users.count > 0 {
                    //commentClient.getListComment(withUsers:users, triggerDelegate: true)
                }else{
                    commentClient.getListComment(topicId: self.topicId, commentId: 0, triggerDelegate: true)
                }
            }
        }
        }else{
            self.showNoConnectionToast()
        }
    }
    // MARK: - Qiscus Comment Delegate
    open func performDeleteMessage(onIndexPath: IndexPath) {
        let deletedComment = self.comment[onIndexPath.section][onIndexPath.row]
        if self.comment[onIndexPath.section].count == 1{
            let indexSet = IndexSet(integer: onIndexPath.section)
            self.comment.remove(at: onIndexPath.section)
            self.tableView.deleteSections(indexSet, with: .none)
        }else{
            self.comment[onIndexPath.section].remove(at: onIndexPath.row)
            self.tableView.deleteRows(at: [onIndexPath], with: .none)
        }
        deletedComment.deleteComment()
    }
    open func performResendMessage(onIndexPath: IndexPath) {
        let resendComment = self.comment[onIndexPath.section][onIndexPath.row]
        resendComment.updateCommentStatus(.sending)
        self.comment[onIndexPath.section][onIndexPath.row] = resendComment
        self.tableView.reloadRows(at: [onIndexPath], with: .none)
        self.commentClient.postComment(resendComment)
    }
    open func commentDidChangeStatus(Comments comments: [QiscusComment], toStatus: QiscusCommentStatus) {
        var indexPaths = [IndexPath]()
        for comment in comments{
            if comment.commentTopicId == self.topicId{
                let indexPath = comment.commentIndexPath
                
                print("row: \(indexPath.row) ||| section: \(indexPath.section)")
                indexPaths.append(indexPath)
                self.comment[indexPath.section][indexPath.row] = comment
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    open func didSuccesPostComment(_ comment:QiscusComment){
        if comment.commentTopicId == self.topicId {
            let indexPath = comment.commentIndexPath
            DispatchQueue.main.async {
                self.comment[indexPath.section][indexPath.row] = comment
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    open func didFailedPostComment(_ comment:QiscusComment){
        if comment.commentTopicId == self.topicId {
            let indexPathData = QiscusHelper.getIndexPathOfComment(comment: comment, inGroupedComment: self.comment)
            let indexPath = IndexPath(row: indexPathData.row, section: indexPathData.section)
            DispatchQueue.main.async {
                self.comment[indexPathData.section][indexPathData.row] = comment
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
    }
    open func downloadingMedia(_ comment:QiscusComment){
        let file = QiscusFile.getCommentFileWithComment(comment)!
        let indexPath = comment.commentIndexPath
        if file.fileType == .media || file.fileType == .video{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellMedia{
                let downloadProgress:Int = Int(file.downloadProgress * 100)
                if file.downloadProgress > 0 {
                    cell.downloadButton.isHidden = true
                    cell.progressLabel.text = "\(downloadProgress) %"
                    cell.progressLabel.isHidden = false
                    cell.progressContainer.isHidden = false
                    cell.progressView.isHidden = false
                    
                    let newHeight = file.downloadProgress * cell.maxProgressHeight
                    cell.progressHeight.constant = newHeight
                    cell.progressView.layoutIfNeeded()
                }
            }
        }else if file.fileType == .audio{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellAudio{
                let downloadProgress:Int = Int(file.downloadProgress * 100)
                if file.downloadProgress > 0 {
                    cell.progressContainer.isHidden = false
                    cell.progressHeight.constant = file.downloadProgress * 30
                    cell.dateLabel.text = "Downloading \(ChatCellDocs.getFormattedStringFromInt(downloadProgress)) %"
                    cell.progressContainer.layoutIfNeeded()
                }
            }
        }
    }
    open func didDownloadMedia(_ comment: QiscusComment){
        if Qiscus.sharedInstance.connected{
            let file = QiscusFile.getCommentFileWithComment(comment)!
            let indexPath = comment.commentIndexPath
            if file.fileType == .media || file.fileType == .video {
                if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellMedia{
                    cell.downloadButton.isHidden = true
                    cell.progressLabel.isHidden = true
                    cell.imageDisplay.loadAsync("file://\(file.fileThumbPath)")
                    if cell.tapRecognizer != nil {
                        cell.imageDisplay.removeGestureRecognizer(cell.tapRecognizer!)
                    }
                    cell.tapRecognizer = ChatTapRecognizer(target:self, action:#selector(QiscusChatVC.tapMediaDisplay(_:)))
                    cell.tapRecognizer?.fileType = file.fileType
                    cell.tapRecognizer?.fileName = file.fileName
                    cell.tapRecognizer?.fileLocalPath = file.fileLocalPath
                    cell.tapRecognizer?.fileURL = file.fileURL
                    cell.progressContainer.isHidden = true
                    cell.progressView.isHidden = true
                    cell.imageDisplay.addGestureRecognizer(cell.tapRecognizer!)
                    
                    if file.fileType == .video{
                        cell.videoPlay.isHidden = false
                    }
                }
            }else if file.fileType == .audio{
                if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellAudio{
                    cell.progressContainer.isHidden = true
                    cell.filePath = file.fileLocalPath
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }else{
            self.showNoConnectionToast()
        }
    }
    open func didUploadFile(_ comment:QiscusComment){
        let file = QiscusFile.getCommentFileWithComment(comment)!
        let indexPath = comment.commentIndexPath
        if file.fileType == .media || file.fileType == .video{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellMedia {
                cell.downloadButton.isHidden = true
                cell.progressLabel.isHidden = true
                cell.progressContainer.isHidden = true
                cell.progressView.isHidden = true
                if file.fileType == .video{
                    cell.videoPlay.isHidden = false
                }
                if cell.tapRecognizer != nil {
                    cell.imageDisplay.removeGestureRecognizer(cell.tapRecognizer!)
                }
                cell.tapRecognizer = ChatTapRecognizer(target:self, action:#selector(QiscusChatVC.tapMediaDisplay(_:)))
                cell.tapRecognizer?.fileType = file.fileType
                cell.tapRecognizer?.fileName = file.fileName
                cell.tapRecognizer?.fileLocalPath = file.fileLocalPath
                cell.tapRecognizer?.fileURL = file.fileURL
                cell.imageDisplay.addGestureRecognizer(cell.tapRecognizer!)
            }
        }
        else if file.fileType == .audio{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellAudio {
                cell.filePath = file.fileLocalPath
                cell.progressContainer.isHidden = true
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        else{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellDocs {
                if cell.tapRecognizer != nil {
                    cell.fileContainer.removeGestureRecognizer(cell.tapRecognizer!)
                }
                
                cell.tapRecognizer = ChatTapRecognizer(target:self, action:#selector(QiscusChatVC.tapChatFile(_:)))
                cell.tapRecognizer?.fileURL = file.fileURL
                
                cell.fileContainer.addGestureRecognizer(cell.tapRecognizer!)
            }
        }
    }
    open func uploadingFile(_ comment:QiscusComment){
        let file = QiscusFile.getCommentFileWithComment(comment)!
        let indexPath = comment.commentIndexPath
        if file.fileType == .media {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellMedia {
                let downloadProgress:Int = Int(file.uploadProgress * 100)
                if file.uploadProgress > 0 {
                    cell.downloadButton.isHidden = true
                    cell.progressLabel.text = "\(downloadProgress) %"
                    cell.progressLabel.isHidden = false
                    cell.progressContainer.isHidden = false
                    cell.progressView.isHidden = false
                    
                    let newHeight = file.uploadProgress * cell.maxProgressHeight
                    cell.progressHeight.constant = newHeight
                    cell.progressView.layoutIfNeeded()
                }
            }
        }
        else if file.fileType == .audio{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellAudio{
                let uploadProgres:Int = Int(file.uploadProgress * 100)
                let uploading = QiscusTextConfiguration.sharedInstance.uploadingText
                cell.progressContainer.isHidden = false
                cell.progressHeight.constant = file.uploadProgress * 30
                cell.dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
                cell.progressContainer.layoutIfNeeded()
            }
        }
        else{
            if let cell = self.tableView.cellForRow(at: indexPath) as? ChatCellDocs {
                if file.uploadProgress > 0 {
                    let uploadProgres = Int(file.uploadProgress * 100)
                    let uploading = QiscusTextConfiguration.sharedInstance.uploadingText
                    
                    cell.dateLabel.text = "\(uploading) \(ChatCellDocs.getFormattedStringFromInt(uploadProgres)) %"
                }
            }
        }
    }
    open func didFailedUploadFile(_ comment:QiscusComment){
        self.tableView.reloadRows(at: [comment.commentIndexPath], with: .none)
    }
    open func didSuccessPostFile(_ comment:QiscusComment){
        
    }
    open func didFailedPostFile(_ comment:QiscusComment){
        
    }
    open func didFinishLoadMore(){
        self.loadMoreControl.endRefreshing()
    }
    open func finishedLoadFromAPI(_ topicId: Int){
        self.dismissLoading()
        let room = QiscusRoom.getRoom(withLastTopicId: self.topicId)
        self.subscribeRealtime(onRoom: room)
        if self.comment.count == 0 && loadWithUser{
            loadWithUser = false
            self.topicId = topicId
            
            self.loadData()
        }
    }
    open func didFailedLoadDataFromAPI(_ error: String){
        self.dismissLoading()
    }
    open func gotNewComment(_ comments:[QiscusComment]){
        var refresh = false
        if self.comment.count == 0 {
            refresh = true
        }

        var needScroolToBottom = false
        
        if firstLoad{
            needScroolToBottom = true
            firstLoad = false
            refresh = true
        }
        if isLastRowVisible && !needScroolToBottom{
            needScroolToBottom = true
        }
        if comments.count == 1 && !needScroolToBottom{
            let firstComment = comments[0]
            if firstComment.commentSenderEmail == QiscusConfig.sharedInstance.USER_EMAIL{
                needScroolToBottom = true
            }
        }
        self.welcomeView.isHidden = true
        
        for singleComment in comments{
            if singleComment.commentTopicId == self.topicId {
                let indexPathData = QiscusHelper.properIndexPathOf(comment: singleComment, inGroupedComment: self.comment)
                
                let indexPath = IndexPath(row: indexPathData.row, section: indexPathData.section)
                let indexSet = IndexSet(integer: indexPathData.section)
                singleComment.updateCommmentIndexPath(indexPath: indexPath)
                
                if indexPathData.newGroup {
                    var newCommentGroup = [QiscusComment]()
                    newCommentGroup.append(singleComment)
                    self.comment.insert(newCommentGroup, at: indexPathData.section)
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(indexSet, with: .top)
                    self.tableView.insertRows(at: [indexPath], with: .top)
                    self.tableView.endUpdates()
                }else{
                    self.comment[indexPathData.section].insert(singleComment, at: indexPathData.row)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [indexPath], with: .top)
                    self.tableView.endUpdates()
                }
                
                if (indexPath as NSIndexPath).row > 0 {
                    let reloadIndexPath = IndexPath(row: (indexPath as NSIndexPath).row - 1, section: (indexPath as NSIndexPath).section)
                    self.tableView.reloadRows(at: [reloadIndexPath], with: .none)
                }
            }
        }
        
        if refresh {
            self.tableView.reloadData()
        }
        if needScroolToBottom{
            scrollToBottom()
        }
    }
    
    // MARK: - Button Action
    open func showLoading(_ text:String = "Loading"){
        self.showQiscusLoading(withText: text, isBlocking: true)
    }
    open func dismissLoading(){
        self.dismissQiscusLoading()
    }
    func unlockChat(){
        UIView.animate(withDuration: 0.6, animations: {
            self.archievedNotifTop.constant = 65
            self.archievedNotifView.layoutIfNeeded()
            }, completion: { _ in
                self.archievedNotifView.isHidden = true
        })
    }
    func lockChat(){
        self.archievedNotifTop.constant = 65
        self.archievedNotifView.isHidden = false
        UIView.animate(withDuration: 0.6, animations: {
            self.archievedNotifTop.constant = 0
            self.archievedNotifView.layoutIfNeeded()
            }
        )
    }
    func confirmUnlockChat(){
        self.unlockAction()
    }
    func sendMessage(){
        if Qiscus.sharedInstance.connected{
            commentClient.postMessage(message: inputText.value, topicId: self.topicId)
            inputText.clearValue()
            inputText.text = ""
            sendButton.isEnabled = false
            self.scrollToBottom()
            self.minInputHeight.constant = 25
            self.inputText.layoutIfNeeded()
        }else{
            self.showNoConnectionToast()
        }
    }
    func tapMediaDisplay(_ sender: ChatTapRecognizer){
        if let delegate = self.cellDelegate{
            delegate.didTapMediaCell(URL(string: "file://\(sender.fileLocalPath)")!, mediaName: sender.fileName)
        }else{
            var currentIndex = 0
            self.galleryItems = [QiscusGalleryItem]()
            var i = 0
            for groupComment in self.comment{
                for singleComment in groupComment {
                    if singleComment.commentType != QiscusCommentType.text {
                        let file = QiscusFile.getCommentFile(singleComment.commentFileId)
                        if file?.fileType == QFileType.media || file?.fileType == .video{
                            if file!.isLocalFileExist(){
                                if file?.fileLocalPath == sender.fileLocalPath{
                                    currentIndex = i
                                }
                                i += 1
                                if file?.fileType == .media {
                                    let urlString = "file://\((file?.fileLocalPath)!)"
                                    if let url = URL(string: urlString) {
                                        if let data = try? Data(contentsOf: url) {
                                            let image = UIImage(data: data)!
                                            if file?.fileLocalPath == sender.fileLocalPath{
                                                self.selectedImage = image
                                            }
                                            let item = QiscusGalleryItem()
                                            item.image = image
                                            item.isVideo = false
                                            self.galleryItems.append(item)
                                        }
                                    }
                                }else{
                                    let urlString = "file://\((file?.fileLocalPath)!)"
                                    let urlThumb = "file://\((file?.fileThumbPath)!)"
                                    if let url = URL(string: urlThumb) {
                                        if let data = try? Data(contentsOf: url) {
                                            let image = UIImage(data: data)!
                                            if file?.fileLocalPath == sender.fileLocalPath{
                                                self.selectedImage = image
                                            }
                                            let item = QiscusGalleryItem()
                                            item.image = image
                                            item.isVideo = true
                                            item.url = urlString
                                            self.galleryItems.append(item)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
            closeButton.setImage(Qiscus.image(named: "close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            closeButton.tintColor = UIColor.white
            closeButton.imageView?.contentMode = .scaleAspectFit
            
            let seeAllButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
            seeAllButton.setTitle("", for: UIControlState())
            seeAllButton.setImage(Qiscus.image(named: "viewmode")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            seeAllButton.tintColor = UIColor.white
            seeAllButton.imageView?.contentMode = .scaleAspectFit
            

            let gallery = GalleryViewController(startIndex: currentIndex, itemsDatasource: self, displacedViewsDatasource: nil, configuration: self.galleryConfiguration())
            self.presentImageGallery(gallery)
        }
    }
    func tapChatFile(_ sender: ChatTapRecognizer){
        let url = sender.fileURL
        let fileName = sender.fileName
        
        let preview = ChatPreviewDocVC()
        preview.fileName = fileName
        preview.url = url
        preview.roomName = QiscusTextConfiguration.sharedInstance.chatTitle
        self.navigationController?.pushViewController(preview, animated: true)
    }
    func uploadImage(){
        self.view.endEditing(true)
        if Qiscus.sharedInstance.connected{
            let photoPermissions = PHPhotoLibrary.authorizationStatus()
            
            if(photoPermissions == PHAuthorizationStatus.authorized){
                self.goToGaleryPicker()
            }else if(photoPermissions == PHAuthorizationStatus.notDetermined){
                PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                    switch status{
                    case .authorized:
                        self.goToGaleryPicker()
                        break
                    case .denied:
                        self.showPhotoAccessAlert()
                        break
                    default:
                        self.showPhotoAccessAlert()
                        break
                    }
                })
            }else{
                self.showPhotoAccessAlert()
            }
        }else{
            self.showNoConnectionToast()
        }
    }
    func uploadFromCamera(){
        self.view.endEditing(true)
        if Qiscus.sharedInstance.connected{
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
            {
                DispatchQueue.main.async(execute: {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.allowsEditing = false
                    picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                    
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(picker, animated: true, completion: nil)
                })
            }else{
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                    if granted {
                        let picker = UIImagePickerController()
                        picker.delegate = self
                        picker.allowsEditing = false
                        picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                        
                        picker.sourceType = UIImagePickerControllerSourceType.camera
                        self.present(picker, animated: true, completion: nil)
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.showCameraAccessAlert()
                        })
                    }
                })
            }
        }else{
            self.showNoConnectionToast()
        }
    }
    func recordAudio(){
        self.view.endEditing(true)
        if Qiscus.sharedInstance.connected{
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) == AVAuthorizationStatus.authorized{
                DispatchQueue.main.async(execute: {
                    let controller = IQAudioRecorderViewController()
                    controller.delegate = self
                    controller.title = NSLocalizedString("RECORDER", comment: "Recorder")
                    controller.allowCropping = true
                    self.presentBlurredAudioRecorderViewControllerAnimated(controller)
                })
            }else{
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted :Bool) -> Void in
                    if granted {
                        let controller = IQAudioRecorderViewController()
                        controller.delegate = self
                        controller.title = NSLocalizedString("RECORDER", comment: "Recorder")
                        controller.allowCropping = true
                        self.presentBlurredAudioRecorderViewControllerAnimated(controller)
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.showMicrophoneAccessAlert()
                        })
                    }
                })
            }
        }else{
            self.showNoConnectionToast()
        }
    }
    func iCloudOpen(){
        if Qiscus.sharedInstance.connected{
            let documentPicker = UIDocumentPickerViewController(documentTypes: self.UTIs, in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        }else{
            self.showNoConnectionToast()
        }
    }
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.showLoading("Processing File")
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: url, options: NSFileCoordinator.ReadingOptions.forUploading, error: nil) { (dataURL) in
            do{
                let data:Data = try Data(contentsOf: dataURL, options: NSData.ReadingOptions.mappedIfSafe)
                var fileName = dataURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
                fileName = fileName.replacingOccurrences(of: " ", with: "_")
                
                let fileNameArr = (fileName as String).characters.split(separator: ".")
                let ext = String(fileNameArr.last!).lowercased()
                
                // get file extension
                let isGifImage:Bool = (ext == "gif" || ext == "gif_")
                let isJPEGImage:Bool = (ext == "jpg" || ext == "jpg_")
                let isPNGImage:Bool = (ext == "png" || ext == "png_")
                
                if isGifImage || isPNGImage || isJPEGImage{
                    var imagePath:URL?
                    let image = UIImage(data: data)
                    if isGifImage{
                        imagePath = dataURL
                    }
                    self.dismissLoading()
                    let text = QiscusTextConfiguration.sharedInstance.confirmationImageUploadText
                    let okText = QiscusTextConfiguration.sharedInstance.alertOkText
                    let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
                    QPopUpView.showAlert(withTarget: self, image: image, message: text, firstActionTitle: okText, secondActionTitle: cancelText,
                        doneAction: {
                            self.continueImageUpload(image, imageName: fileName, imagePath: imagePath)
                        },
                        cancelAction: {}
                    )
                }else{
                    self.dismissLoading()
                    let textFirst = QiscusTextConfiguration.sharedInstance.confirmationFileUploadText
                    let textMiddle = "\(fileName as String)"
                    let textLast = QiscusTextConfiguration.sharedInstance.questionMark
                    let text = "\(textFirst) \(textMiddle) \(textLast)"
                    let okText = QiscusTextConfiguration.sharedInstance.alertOkText
                    let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
                    QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: okText, secondActionTitle: cancelText,
                        doneAction: {
                            self.continueImageUpload(imageName: fileName, imagePath: dataURL, imageNSData: data)
                        },
                        cancelAction: {
                        }
                    )
                }
            }catch _{
                self.dismissLoading()
            }
        }
    }
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Upload Action
    func continueImageUpload(_ image:UIImage? = nil,imageName:String,imagePath:URL? = nil, imageNSData:Data? = nil, videoFile:Bool = false, audioFile:Bool = false){
        if Qiscus.sharedInstance.connected{
            print("come here")
            commentClient.uploadImage(self.topicId, image: image, imageName: imageName, imagePath: imagePath, imageNSData: imageNSData, videoFile: videoFile, audioFile:audioFile)
        }else{
            self.showNoConnectionToast()
        }
    }
    
    // MARK: UIImagePicker Delegate
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let fileType:String = info[UIImagePickerControllerMediaType] as! String
        picker.dismiss(animated: true, completion: nil)
        
        if fileType == "public.image"{
            var imageName:String = ""
            var image = UIImage()
            var imagePath:URL?
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL{
                imageName = imageURL.lastPathComponent
                image = info[UIImagePickerControllerOriginalImage] as! UIImage
                
                let imageNameArr = imageName.characters.split(separator: ".")
                let imageExt:String = String(imageNameArr.last!).lowercased()
                
                if imageExt.isEqual("gif") || imageExt.isEqual("gif_"){
                    imagePath = imageURL
                }
            }else{
                imageName = "\(timeToken).jpg"
                image = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            let text = QiscusTextConfiguration.sharedInstance.confirmationImageUploadText
            let okText = QiscusTextConfiguration.sharedInstance.alertOkText
            let cancelText = QiscusTextConfiguration.sharedInstance.alertCancelText
            
            QPopUpView.showAlert(withTarget: self, image: image, message: text, firstActionTitle: okText, secondActionTitle: cancelText,
                doneAction: {
                    self.continueImageUpload(image, imageName: imageName, imagePath: imagePath)
                },
                cancelAction: {}
            )
        }else if fileType == "public.movie" {
            let mediaURL = info[UIImagePickerControllerMediaURL] as! URL
            let fileName = mediaURL.lastPathComponent
            let fileNameArr = fileName.characters.split(separator: ".")
            let fileExt:NSString = String(fileNameArr.last!).lowercased() as NSString
            
            let mediaData = try? Data(contentsOf: mediaURL)
            
            print("mediaURL: \(mediaURL)\nfileName: \(fileName)\nfileExt: \(fileExt)")
            
            //create thumb image
            let assetMedia = AVURLAsset(url: mediaURL)
            let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
            thumbGenerator.appliesPreferredTrackTransform = true
            
            let thumbTime = CMTimeMakeWithSeconds(0, 30)
            let maxSize = CGSize(width: QiscusHelper.screenWidth(), height: QiscusHelper.screenWidth())
            thumbGenerator.maximumSize = maxSize
            
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                    doneAction: {
                                        print("continue video upload")
                                        self.continueImageUpload(thumbImage, imageName: fileName, imageNSData: mediaData, videoFile: true)
                    },
                                    cancelAction: {
                                        print("cancel upload")
                    }
                )
            }catch{
                print("error creating thumb image")
            }
        }
    }
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Load More Control
    func loadMore(){
        if self.comment.count > 0 {
            if Qiscus.sharedInstance.connected{
                let firstComment = self.comment[0][0]
                
                if firstComment.commentBeforeId > 0 {
                    commentClient.loadMoreComment(fromCommentId: firstComment.commentId, topicId: self.topicId, limit: 10)
                }else{
                    self.loadMoreControl.endRefreshing()
                    self.loadMoreControl.isEnabled = false
                }
            }else{
                self.showNoConnectionToast()
                self.loadMoreControl.endRefreshing()
            }
        }else{
            self.loadData()
        }
    }
    
    // MARK: - Back Button
    class func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let backLabel = UILabel()
        
        backLabel.text = QiscusTextConfiguration.sharedInstance.backText
        backLabel.textColor = UIColor.white
        backLabel.font = UIFont.systemFont(ofSize: 12)
        
        let image = UIImage(named: "ic_back", in: Qiscus.bundle, compatibleWith: nil)?.localizedImage()
        backIcon.image = image
        
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 0,width: 10,height: 15)
            backLabel.frame = CGRect(x: 15,y: 0,width: 45,height: 15)
        }else{
            backIcon.frame = CGRect(x: 50,y: 0,width: 10,height: 15)
            backLabel.frame = CGRect(x: 0,y: 0,width: 45,height: 15)
        }
        
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 60,height: 20))
        backButton.addSubview(backIcon)
        backButton.addSubview(backLabel)
        backButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
    
    func showAlert(alert:UIAlertController){
        self.present(alert, animated: true, completion: nil)
    }
    
    func setGradientChatNavigation(withTopColor topColor:UIColor, bottomColor:UIColor, tintColor:UIColor){
        self.topColor = topColor
        self.bottomColor = bottomColor
        self.tintColor = tintColor
        self.navigationController?.navigationBar.verticalGradientColor(self.topColor, bottomColor: self.bottomColor)
        self.navigationController?.navigationBar.tintColor = self.tintColor
        let _ = self.view
        self.sendButton.tintColor = self.topColor
        self.documentButton.tintColor = self.bottomColor
        self.galeryButton.tintColor = self.bottomColor
        self.cameraButton.tintColor = self.bottomColor
        self.emptyChatImage.tintColor = self.bottomColor
        self.audioButton.tintColor = self.bottomColor
    }
    func setNavigationColor(_ color:UIColor, tintColor:UIColor){
        self.topColor = color
        self.bottomColor = color
        self.tintColor = tintColor
        self.navigationController?.navigationBar.verticalGradientColor(topColor, bottomColor: bottomColor)
        self.navigationController?.navigationBar.tintColor = tintColor
        let _ = self.view
        self.sendButton.tintColor = self.topColor
        self.documentButton.tintColor = self.bottomColor
        self.galeryButton.tintColor = self.bottomColor
        self.cameraButton.tintColor = self.bottomColor
        self.emptyChatImage.tintColor = self.bottomColor
        self.audioButton.tintColor = self.bottomColor
    }
    func showNoConnectionToast(){
        QToasterSwift.toast(target: self, text: QiscusTextConfiguration.sharedInstance.noConnectionText, backgroundColor: UIColor(red: 0.9, green: 0,blue: 0,alpha: 0.8), textColor: UIColor.white)
    }
    
    // MARK: - Galery Function
    public func galleryConfiguration()-> GalleryConfiguration{
        let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
        closeButton.setImage(Qiscus.image(named: "close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        closeButton.tintColor = UIColor.white
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        let seeAllButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
        seeAllButton.setTitle("", for: UIControlState())
        seeAllButton.setImage(Qiscus.image(named: "viewmode")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        seeAllButton.tintColor = UIColor.white
        seeAllButton.imageView?.contentMode = .scaleAspectFit
        
        return [
            GalleryConfigurationItem.closeButtonMode(.custom(closeButton)),
            GalleryConfigurationItem.thumbnailsButtonMode(.custom(seeAllButton))
        ]
    }
    public func itemCount() -> Int {
        return self.galleryItems.count
    }
    public func provideGalleryItem(_ index: Int) -> GalleryItem {
        let item = self.galleryItems[index]
        if item.isVideo{
            return GalleryItem.video(fetchPreviewImageBlock: { $0(item.image)}, videoURL: URL(string: item.url)! )
        }else{
            return GalleryItem.image { $0(item.image) }
        }
    }
    func saveImageToGalery(){
        print("saving image")
        UIImageWriteToSavedPhotosAlbum(self.selectedImage, self, #selector(QiscusChatVC.succesSaveImage), nil)
    }
    func succesSaveImage(){
         QToasterSwift.toast(target: self.imagePreview!, text: "Successfully save image to your galery", backgroundColor: UIColor(red: 0, green: 0.8,blue: 0,alpha: 0.8), textColor: UIColor.white)
    }
    func setTitle(title:String = "", withSubtitle:String? = nil){
        QiscusUIConfiguration.sharedInstance.copyright.chatTitle = title
        if withSubtitle != nil {
            QiscusUIConfiguration.sharedInstance.copyright.chatSubtitle = withSubtitle!
        }
        self.navigationItem.setTitleWithSubtitle(title: QiscusTextConfiguration.sharedInstance.chatTitle, subtitle:QiscusTextConfiguration.sharedInstance.chatSubtitle)
    }
    func startTypingIndicator(withUser user:String){
        let typingText = "\(user) is typing ..."
        self.navigationItem.setTitleWithSubtitle(title: QiscusTextConfiguration.sharedInstance.chatTitle, subtitle:typingText)
    }
    func stopTypingIndicator(){
        self.navigationItem.setTitleWithSubtitle(title: QiscusTextConfiguration.sharedInstance.chatTitle, subtitle:QiscusTextConfiguration.sharedInstance.chatSubtitle)
    }
    
    func subscribeRealtime(onRoom room:QiscusRoom?){
        if room != nil {
            let typingChannel:String = "r/\(room!.roomId)/\(room!.roomLastCommentTopicId)/+/t"
            let readChannel:String = "r/\(room!.roomId)/\(room!.roomLastCommentTopicId)/+/r"
            let deliveryChannel:String = "r/\(room!.roomId)/\(room!.roomLastCommentTopicId)/+/r"
            Qiscus.addMqttChannel(channel: typingChannel)
            Qiscus.addMqttChannel(channel: readChannel)
            Qiscus.addMqttChannel(channel: deliveryChannel)
        }
    }
    func unsubscribeTypingRealtime(onRoom room:QiscusRoom?){
        if room != nil {
            let channel = "r/\(room!.roomId)/\(room!.roomLastCommentTopicId)/+/t"
            Qiscus.deleteMqttChannel(channel: channel)
        }
    }
    func appDidEnterBackground(){
        self.view.endEditing(true)
    }
    open func resendMessage(){
    
    }

    
    // MARK: AVAudioPlayerDelegate
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            
            activeAudioCell?.isPlaying = false
            stopTimer()
            updateAudioDisplay()
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        activeAudioCell?.isPlaying = false
        stopTimer()
        updateAudioDisplay()
    }
    
    
    // MARK: IQAudioRecorderViewControllerDelegate
    
    public func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        debugPrint("filePath \(filePath)")
        debugPrint("fileURL \(fileURL)")
        var fileContent: Data?
        fileContent = try! Data(contentsOf: fileURL)
        
        let fileName = fileURL.lastPathComponent
        
        self.continueImageUpload(imageName: fileName, imageNSData: fileContent, audioFile: true)
        //commentClient.uploadAudio(self.room.roomLastCommentTopicId, fileName: fileName, filePath: fileURL, roomId: self.room.roomId)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Audio Methods
    
    func audioTimerFired(_ timer: Timer) {
        self.updateAudioDisplay()
    }
    
    func stopTimer() {
        audioTimer?.invalidate()
        audioTimer = nil
    }
    
    func updateAudioDisplay() {
        if let currentTime = audioPlayer?.currentTime {
            activeAudioCell?.currentTimeSlider.setValue(Float(currentTime), animated: true)
            activeAudioCell?.seekTimeLabel.text = activeAudioCell?.timeFormatter?.string(from: currentTime)
        }
    }
    
    // MARK: ChatCellAudioDelegate
    func didTapDownloadButton(_ button: UIButton, onCell cell: ChatCellAudio) {
        print("downloading")
        cell.isDownloading = true
        cell.playButton.removeTarget(nil, action: nil, for: .allEvents)
        let selectedComment = self.comment[(cell.indexPath?.section)!][(cell.indexPath?.row)!]
        self.commentClient.downloadMedia(selectedComment, isAudioFile: true)
    }
    func didTapPlayButton(_ button: UIButton, onCell cell: ChatCellAudio) {
        let path = cell.filePath
        if let url = URL(string: path) {
            if audioPlayer != nil {
                if audioPlayer!.isPlaying {
                    activeAudioCell?.isPlaying = false
                    
                    audioPlayer?.stop()
                    stopTimer()
                    updateAudioDisplay()
                }
            }
            
            activeAudioCell = cell
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
            audioPlayer?.delegate = self
            audioPlayer?.currentTime = Double(cell.currentTimeSlider.value)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                //print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    //print("AVAudioSession is Active")
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                    
                    audioTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(audioTimerFired(_:)), userInfo: nil, repeats: true)
                    
                } catch _ as NSError {
                    //print(error.localizedDescription)
                }
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        }
    }
    
    func didTapPauseButton(_ button: UIButton, onCell cell: ChatCellAudio) {
        
        audioPlayer?.pause()
        stopTimer()
        
        updateAudioDisplay()
    }
    
    func didStartSeekTimeSlider(_ slider: UISlider, onCell cell: ChatCellAudio) {
        if audioTimer != nil {
            stopTimer()
        }
    }
    
    func didEndSeekTimeSlider(_ slider: UISlider, onCell cell: ChatCellAudio) {
        audioPlayer?.stop()
        
        let currentTime = cell.currentTimeSlider.value
        audioPlayer?.currentTime = Double(currentTime)
        
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
        audioTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(audioTimerFired(_:)), userInfo: nil, repeats: true)
    }
}
