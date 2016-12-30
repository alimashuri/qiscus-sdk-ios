//
//  QiscusCommentClient.swift
//  QiscusSDK
//
//  Created by ahmad athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation
import Photos

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let qiscus = Qiscus.sharedInstance

open class QiscusCommentClient: NSObject {
    open static let sharedInstance = QiscusCommentClient()
    
    open var commentDelegate: QCommentDelegate?
    open var roomDelegate: QiscusRoomDelegate?
    open var configDelegate: QiscusConfigDelegate?
    
    // MARK: - Login or register
    open func loginOrRegister(_ email:String = "", password:String = "", username:String? = nil, avatarURL:String? = nil){
        let manager = Alamofire.SessionManager.default
        var parameters:[String: AnyObject] = [String: AnyObject]()
        
        parameters = [
            "email"  : email as AnyObject,
            "password" : password as AnyObject,
        ]
        
        if let name = username{
            parameters["username"] = name as AnyObject?
        }
        if let avatar =  avatarURL{
            parameters["avatar_url"] = avatar as AnyObject?
        }
        
        DispatchQueue.global().async(execute: {
            print("login url: \(QiscusConfig.LOGIN_REGISTER)")
            print("post parameters: \(parameters)")
            print("post headers: \(QiscusConfig.sharedInstance.requestHeader)")
            let request = manager.request(QiscusConfig.LOGIN_REGISTER, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: { response in
                print("login register result: \(response)")
                print("login url: \(QiscusConfig.LOGIN_REGISTER)")
                print("post parameters: \(parameters)")
                print("post headers: \(QiscusConfig.sharedInstance.requestHeader)")
                switch response.result {
                    case .success:
                        DispatchQueue.main.async(execute: {
                            if let result = response.result.value{
                                let json = JSON(result)
                                let success:Bool = (json["status"].intValue == 200)
                                
                                if success {
                                    let userData = json["results"]["user"]
                                    let _ = QiscusMe.saveData(fromJson: userData)
                                    if self.configDelegate != nil {
                                        Qiscus.setupReachability()
                                        self.configDelegate!.qiscusConnected()
                                    }
                                }else{
                                    self.configDelegate!.qiscusFailToConnect("[Qiscus]: \(json["message"].stringValue)")
                                }
                            }else{
                                if self.configDelegate != nil {
                                    self.configDelegate!.qiscusFailToConnect("[Qiscus]: Cant get data from qiscus server")
                                }
                            }
                        })
                    break
                    case .failure(let error):
                        DispatchQueue.main.async(execute: {
                            if self.configDelegate != nil {
                                self.configDelegate!.qiscusFailToConnect("[Qiscus]: \(error)")
                            }
                        })
                    break
                }
            })
            request.resume()
        })
    }
    
    // MARK: - Comment Methode
    open func postMessage(message: String, topicId: Int, roomId:Int? = nil){ //USED
        let comment = QiscusComment.newCommentWithMessage(message: message, inTopicId: topicId)
        self.postComment(comment, roomId: roomId)
        self.commentDelegate?.gotNewComment([comment])
    }
    open func postComment(_ comment:QiscusComment, file:QiscusFile? = nil, roomId:Int? = nil){ //USED
        
        let manager = Alamofire.SessionManager.default
        var parameters:[String: AnyObject] = [String: AnyObject]()
        
        parameters = [
            "comment"  : comment.commentText as AnyObject,
            "topic_id" : comment.commentTopicId as AnyObject,
            "unique_temp_id" : comment.commentUniqueId as AnyObject
        ]
        
        if QiscusConfig.sharedInstance.requestHeader == nil{
            parameters["token"] = qiscus.config.USER_TOKEN as AnyObject?
        }
        if roomId != nil {
            parameters["room_id"] = roomId as AnyObject?
        }
        DispatchQueue.global().async(execute: {
            let request = manager.request(QiscusConfig.postCommentURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: {response in
                print("[Qiscus] post message result: \(response)")
                print("[Qiscus] post url: \(QiscusConfig.postCommentURL)")
                print("[Qiscus] post parameters: \(parameters)")
                print("[Qiscus] post headers: \(QiscusConfig.sharedInstance.requestHeader)")
                
                switch response.result {
                    case .success:
                        DispatchQueue.main.async(execute: {
                            if let result = response.result.value {
                                let json = JSON(result)
                                let success = (json["status"].intValue == 200)
                                
                                if success == true {
                                    let commentJSON = json["results"]["comment"]
                                    comment.updateCommentId(commentJSON["id"].intValue)
                                    comment.updateCommentStatus(QiscusCommentStatus.sent)
                                    let commentBeforeid = QiscusComment.getCommentBeforeIdFromJSON(commentJSON)
                                    if(QiscusComment.isValidCommentIdExist(commentBeforeid)){
                                        comment.updateCommentIsSync(true)
                                    }else{
                                        self.syncMessage(comment.commentTopicId)
                                    }
                                    
                                    self.commentDelegate?.didSuccesPostComment(comment)
                                    
                                    if file != nil {
                                        let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                        if(file != nil){
                                            file?.updateCommentId(thisComment!.commentId)
                                        }
                                        
                                        self.commentDelegate?.didSuccessPostFile(comment)
                                    }
                                }
                            }else{
                                comment.updateCommentStatus(QiscusCommentStatus.failed)
                                self.commentDelegate?.didFailedPostComment(comment)
                                
                                if file != nil{
                                    let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                    if(file != nil){
                                        file?.updateCommentId(thisComment!.commentId)
                                    }
                                    self.commentDelegate?.didFailedPostFile(comment)
                                }
                            }
                        })
                    break
                    case .failure(let error):
                        DispatchQueue.main.async(execute: {
                            comment.updateCommentStatus(QiscusCommentStatus.failed)
                            self.commentDelegate?.didFailedPostComment(comment)
                            if file != nil{
                                let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                if(file != nil){
                                    file?.updateCommentId(thisComment!.commentId)
                                }
                                self.commentDelegate?.didFailedPostFile(comment)
                            }
                            print("[Qiscus]: fail to post comment with error: \(error)")
                        })
                    break
                }
            })
            request.resume()
        })
    }
    
    open func downloadMedia(_ comment:QiscusComment, thumbImageRef:UIImage? = nil, isAudioFile:Bool = false){
        let file = QiscusFile.getCommentFile(comment.commentFileId)!
        let manager = Alamofire.SessionManager.default
        
        //let headers = QiscusConfig.requestHeader
        
        file.updateIsDownloading(true)
        manager.request(file.fileURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseData(completionHandler: { response in
            print("[Qiscus] download result: \(response)")
            if let data = response.data {
                if !isAudioFile{
                    if let image = UIImage(data: data) {
                        var thumbImage = UIImage()
                        if !(file.fileExtension == "gif" || file.fileExtension == "gif_"){
                            thumbImage = QiscusFile.createThumbImage(image, fillImageSize: thumbImageRef)
                        }
                        DispatchQueue.main.async(execute: {
                            file.updateDownloadProgress(1.0)
                            file.updateIsDownloading(false)
                        })
                        print("[Qiscus] Download completed")
                        
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                        let fileName = "\(comment.commentId)-Q-\(file.fileName as String)"
                        let path = "\(documentsPath)/\(fileName)"
                        let thumbPath = "\(documentsPath)/thumb_\(fileName)"
                        
                        if (file.fileExtension == "png" || file.fileExtension == "png_") {
                            try? UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
                            try? UIImagePNGRepresentation(thumbImage)!.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                        } else if(file.fileExtension == "jpg" || file.fileExtension == "jpg_"){
                            try? UIImageJPEGRepresentation(image, 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
                            try? UIImageJPEGRepresentation(thumbImage, 1.0)!.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                        } else if(file.fileExtension == "gif" || file.fileExtension == "gif_"){
                            try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
                            try? data.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                            thumbImage = image
                        }
                        DispatchQueue.main.async(execute: {
                            file.updateLocalPath(path)
                            file.updateThumbPath(thumbPath)
                            
                            self.commentDelegate?.didDownloadMedia(comment)
                        })
                    }else{
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                        let path = "\(documentsPath)/\(file.fileName as String)"
                        let thumbPath = "\(documentsPath)/thumb_\(file.fileCommentId).png"
                        
                        try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
                        
                        let assetMedia = AVURLAsset(url: URL(fileURLWithPath: "\(path)"))
                        let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
                        thumbGenerator.appliesPreferredTrackTransform = true
                        
                        let thumbTime = CMTimeMakeWithSeconds(0, 30)
                        let maxSize = CGSize(width: file.screenWidth, height: file.screenWidth)
                        thumbGenerator.maximumSize = maxSize
                        var thumbImage:UIImage?
                        do{
                            let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                            thumbImage = UIImage(cgImage: thumbRef)
                            
                            let thumbData = UIImagePNGRepresentation(thumbImage!)
                            try? thumbData!.write(to: URL(fileURLWithPath: thumbPath), options: [.atomic])
                        }catch{
                            print("error creating thumb image")
                        }
                        
                        DispatchQueue.main.async(execute: {
                            file.updateDownloadProgress(1.0)
                            file.updateIsDownloading(false)
                            file.updateLocalPath(path)
                            file.updateThumbPath(thumbPath)
                            self.commentDelegate?.didDownloadMedia(comment)
                        })
                    }
                }else{
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                    let path = "\(documentsPath)/\(file.fileName as String)"
                    //print
                    try! data.write(to: URL(fileURLWithPath: path), options: [.atomic])
                    
                    DispatchQueue.main.async {
                        file.updateDownloadProgress(1.0)
                        file.updateIsDownloading(false)
                        file.updateLocalPath(path)
                        self.commentDelegate?.didDownloadMedia(comment)
                    }
                }
            }
        }).downloadProgress(closure: { progressData in
            let progress = CGFloat(progressData.fractionCompleted)
            DispatchQueue.main.async(execute: {
                print("[Qiscus] Download progress: \(progress)")
                file.updateDownloadProgress(progress)
                self.commentDelegate?.downloadingMedia(comment)
            })
        })
    }
    open func reUploadFile(onComment comment:QiscusComment){
        if let commentFile = QiscusFile.getCommentFileWithComment(comment){
            let fileLocalURL = URL(fileURLWithPath: commentFile.fileLocalPath)
            if let fileData = try? Data(contentsOf: fileLocalURL){
                let mimeType = QiscusFileHelper.mimeTypes["\(commentFile.fileExtension)"]!
                let fileName = commentFile.fileName
                let headers = QiscusConfig.sharedInstance.requestHeader
                
                var urlUpload = URLRequest(url: URL(string: QiscusConfig.UPLOAD_URL)!)
                if headers != nil && headers?.count > 0 {
                    for (key,value) in headers! {
                        urlUpload.setValue(value, forHTTPHeaderField: key)
                    }
                }
                urlUpload.httpMethod = "POST"
                
                Alamofire.upload(multipartFormData: {formData in
                    formData.append(fileData, withName: "file", fileName: fileName, mimeType: mimeType)
                }, with: urlUpload, encodingCompletion: {
                    encodingResult in
                    print("[Qiscus] fileName to upload: \(fileName)")
                    print("[Qiscus] mimeType to upload: \(mimeType)")
                    print("[Qiscus] encodingResult on upload: \(encodingResult)")
                    switch encodingResult{
                    case .success(let upload, _, _):
                        upload.responseJSON(completionHandler: {response in
                            print("[Qiscus] success upload: \(response)")
                            if let jsonData = response.result.value {
                                let json = JSON(jsonData)
                                if let url = json["url"].string {
                                    DispatchQueue.main.async(execute: {
                                        comment.updateCommentStatus(QiscusCommentStatus.sending)
                                        comment.updateCommentText("[file]\(url) [/file]")
                                        print("[Qiscus] upload success")
                                        
                                        commentFile.updateURL(url)
                                        commentFile.updateIsUploading(false)
                                        commentFile.updateUploadProgress(1.0)
                                        
                                        self.commentDelegate?.didUploadFile(comment)
                                        self.postComment(comment, file: commentFile)
                                    })
                                }
                                else if json["results"].count > 0 {
                                    let data = json["results"]
                                    if data["file"].count > 0 {
                                        let file = data["file"]
                                        if let url = file["url"].string {
                                            DispatchQueue.main.async(execute: {
                                                comment.updateCommentStatus(QiscusCommentStatus.sending)
                                                comment.updateCommentText("[file]\(url) [/file]")
                                                print("[Qiscus] upload success")
                                                
                                                commentFile.updateURL(url)
                                                commentFile.updateIsUploading(false)
                                                commentFile.updateUploadProgress(1.0)
                                                
                                                self.commentDelegate?.didUploadFile(comment)
                                                self.postComment(comment, file: commentFile)
                                            })
                                        }
                                    }
                                }
                            }else{
                                print("[Qiscus] fail to upload file")
                                DispatchQueue.main.async(execute: {
                                    comment.updateCommentStatus(QiscusCommentStatus.failed)
                                    commentFile.updateIsUploading(false)
                                    commentFile.updateUploadProgress(0)
                                    self.commentDelegate?.didFailedUploadFile(comment)
                                })
                            }
                        })
                        upload.uploadProgress(closure: {uploadProgress in
                            let progress = CGFloat(uploadProgress.fractionCompleted)
                            print("[Qiscus] upload progress: \(progress)")
                            let currentComment = QiscusComment.getCommentByUniqueId(comment.commentUniqueId)
                            commentFile.updateIsUploading(true)
                            commentFile.updateUploadProgress(progress)
                            
                            self.commentDelegate?.uploadingFile(currentComment!)
                        })
                        break
                    case .failure(let error):
                        print("[Qiscus] fail to upload with error: \(error)")
                        DispatchQueue.main.async(execute: {
                            comment.updateCommentStatus(QiscusCommentStatus.failed)
                            commentFile.updateIsUploading(false)
                            commentFile.updateUploadProgress(0)
                            self.commentDelegate?.didFailedUploadFile(comment)
                        })
                        break
                    }
                })
            }
        }
    }
    open func uploadImage(_ topicId: Int,image:UIImage?,imageName:String,imagePath:URL? = nil, imageNSData:Data? = nil, roomId:Int? = nil, thumbImageRef:UIImage? = nil, videoFile:Bool = true, audioFile:Bool = false){
        print("[Qiscus] uploading image")
        var imageData:Data = Data()
        if imageNSData != nil {
            imageData = imageNSData!
        }
        var thumbData:Data = Data()
        var imageMimeType:String = ""
        print("[Qiscus] imageName: \(imageName)")
        let imageNameArr = imageName.characters.split(separator: ".")
        let imageExt:String = String(imageNameArr.last!).lowercased()
        let comment = QiscusComment.newCommentWithMessage(message: "", inTopicId: topicId)
        
        if image != nil {
            if !videoFile{
                var thumbImage = UIImage()
                print("\(imageName) --- \(imageExt) -- \(imageExt != "gif")")
                
                let isGifImage:Bool = (imageExt == "gif" || imageExt == "gif_")
                let isJPEGImage:Bool = (imageExt == "jpg" || imageExt == "jpg_")
                let isPNGImage:Bool = (imageExt == "png" || imageExt == "png_")
                
                print("\(imagePath)")
                
                if !isGifImage{
                    thumbImage = QiscusFile.createThumbImage(image!, fillImageSize: thumbImageRef)
                }
                
                if isJPEGImage == true{
                    let imageSize = image?.size
                    var bigPart = CGFloat(0)
                    if(imageSize?.width > imageSize?.height){
                        bigPart = (imageSize?.width)!
                    }else{
                        bigPart = (imageSize?.height)!
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    
                    imageData = UIImageJPEGRepresentation(image!, compressVal)!
                    thumbData = UIImageJPEGRepresentation(thumbImage, 1)!
                    imageMimeType = "image/jpg"
                }else if isPNGImage == true{
                    imageData = UIImagePNGRepresentation(image!)!
                    thumbData = UIImagePNGRepresentation(thumbImage)!
                    imageMimeType = "image/png"
                }else if isGifImage == true{
                    if imageNSData == nil{
                        let asset = PHAsset.fetchAssets(withALAssetURLs: [imagePath!], options: nil)
                        if let phAsset = asset.firstObject {
                            
                            let option = PHImageRequestOptions()
                            option.isSynchronous = true
                            option.isNetworkAccessAllowed = true
                            PHImageManager.default().requestImageData(for: phAsset, options: option) {
                                (data, dataURI, orientation, info) -> Void in
                                imageData = data!
                                thumbData = data!
                                imageMimeType = "image/gif"
                            }
                        }
                    }else{
                        imageData = imageNSData!
                        thumbData = imageNSData!
                        imageMimeType = "image/gif"
                    }
                }
            }else{
                if let mime:String = QiscusFileHelper.mimeTypes["\(imageExt)"] {
                    imageMimeType = mime
                    print("mime: \(mime)")
                }
                thumbData = UIImagePNGRepresentation(image!)!
            }
        }else{
            if let mime:String = QiscusFileHelper.mimeTypes["\(imageExt)"] {
                imageMimeType = mime
                print("mime: \(mime)")
            }
        }
        var imageThumbName = "thumb_\(comment.commentUniqueId).\(imageExt)"
        let fileName = "\(comment.commentUniqueId).\(imageExt)"
        if videoFile{
            imageThumbName = "thumb_\(comment.commentUniqueId).png"
        }
        let commentFile = QiscusFile()
        if image != nil {
            commentFile.fileLocalPath = QiscusFile.saveFile(imageData, fileName: fileName)
            commentFile.fileThumbPath = QiscusFile.saveFile(thumbData, fileName: imageThumbName)
        }else{
            commentFile.fileLocalPath = QiscusFile.saveFile(imageData, fileName: fileName)
        }
        commentFile.fileTopicId = topicId
        commentFile.isUploading = true
        commentFile.uploaded = false
        commentFile.saveCommentFile()
        
        comment.updateCommentText("[file]\(fileName) [/file]")
        comment.updateCommentFileId(commentFile.fileId)
        
        commentFile.updateIsUploading(true)
        commentFile.updateUploadProgress(0.0)
        
        self.commentDelegate?.gotNewComment([comment])
        
        let headers = QiscusConfig.sharedInstance.requestHeader
        
        var urlUpload = URLRequest(url: URL(string: QiscusConfig.UPLOAD_URL)!)
        if headers != nil && headers?.count > 0 {
            for (key,value) in headers! {
                urlUpload.setValue(value, forHTTPHeaderField: key)
            }
        }
        urlUpload.httpMethod = "POST"
        
        
        Alamofire.upload(multipartFormData: {formData in
                formData.append(imageData, withName: "file", fileName: fileName, mimeType: imageMimeType)
            }, with: urlUpload, encodingCompletion: {
                encodingResult in
                print("[Qiscus] fileName to upload: \(fileName)")
                print("[Qiscus] mimeType to upload: \(imageMimeType)")
                print("[Qiscus] encodingResult on upload: \(encodingResult)")
                switch encodingResult{
                    case .success(let upload, _, _):
                        upload.responseJSON(completionHandler: {response in
                            print("[Qiscus] success upload: \(response)")
                            if let jsonData = response.result.value {
                                let json = JSON(jsonData)
                                if let url = json["url"].string {
                                    DispatchQueue.main.async(execute: {
                                        comment.updateCommentStatus(QiscusCommentStatus.sending)
                                        comment.updateCommentText("[file]\(url) [/file]")
                                        print("[Qiscus] upload success")
                                        
                                        commentFile.updateURL(url)
                                        commentFile.updateIsUploading(false)
                                        commentFile.updateUploadProgress(1.0)
                                        
                                        self.commentDelegate?.didUploadFile(comment)
                                        self.postComment(comment, file: commentFile, roomId: roomId)
                                    })
                                }
                                else if json["results"].count > 0 {
                                    let data = json["results"]
                                    if data["file"].count > 0 {
                                        let file = data["file"]
                                        if let url = file["url"].string {
                                            DispatchQueue.main.async(execute: {
                                                comment.updateCommentStatus(QiscusCommentStatus.sending)
                                                comment.updateCommentText("[file]\(url) [/file]")
                                                print("[Qiscus] upload success")
                                                
                                                commentFile.updateURL(url)
                                                commentFile.updateIsUploading(false)
                                                commentFile.updateUploadProgress(1.0)
                                                
                                                self.commentDelegate?.didUploadFile(comment)
                                                self.postComment(comment, file: commentFile, roomId: roomId)
                                            })
                                        }
                                    }
                                }
                            }else{
                                print("[Qiscus] fail to upload file")
                                DispatchQueue.main.async(execute: {
                                    comment.updateCommentStatus(QiscusCommentStatus.failed)
                                    commentFile.updateIsUploading(false)
                                    commentFile.updateUploadProgress(0)
                                    self.commentDelegate?.didFailedUploadFile(comment)
                                })
                            }
                        })
                        upload.uploadProgress(closure: {uploadProgress in
                            let progress = CGFloat(uploadProgress.fractionCompleted)
                            print("[Qiscus] upload progress: \(progress)")
                            let currentComment = QiscusComment.getCommentByUniqueId(comment.commentUniqueId)
                            commentFile.updateIsUploading(true)
                            commentFile.updateUploadProgress(progress)
                            
                            self.commentDelegate?.uploadingFile(currentComment!)
                        })
                    break
                    case .failure(let error):
                        print("[Qiscus] fail to upload with error: \(error)")
                        DispatchQueue.main.async(execute: {
                            comment.updateCommentStatus(QiscusCommentStatus.failed)
                            commentFile.updateIsUploading(false)
                            commentFile.updateUploadProgress(0)
                            self.commentDelegate?.didFailedUploadFile(comment)
                        })
                    break
                }
        })
    }
    
    // MARK: - Communicate with Server
    open func syncMessage(_ topicId: Int, triggerDelegate:Bool = false) {
        DispatchQueue.main.async {
            let manager = Alamofire.SessionManager.default
            if let commentId = QiscusComment.getLastSyncCommentId(topicId) {
                let loadURL = QiscusConfig.LOAD_URL
                let parameters:[String: AnyObject] =  [
                        "comment_id"  : commentId as AnyObject,
                        "topic_id" : topicId as AnyObject,
                        "token" : qiscus.config.USER_TOKEN as AnyObject,
                        "after":"true" as AnyObject
                    ]
                manager.request(loadURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: {responseData in
                    print("[Qiscus] sync comment parameters: \n\(parameters)")
                    print("[Qiscus] sync comment response: \n\(responseData)")
                    if let response = responseData.result.value {
                        let json = JSON(response)
                        let results = json["results"]
                        let error = json["error"]
                        if results != nil{
                            let comments = json["results"]["comments"].arrayValue
                            if comments.count > 0 {
                                DispatchQueue.main.async(execute: {
                                    var newMessageCount: Int = 0
                                    var newComments = [QiscusComment]()
                                    for comment in comments {
                                        
                                        let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                                        
                                        if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                            thisComment.updateCommentStatus(QiscusCommentStatus.delivered)
                                            if isSaved {
                                                newMessageCount += 1
                                                newComments.insert(thisComment, at: 0)
                                            }
                                        }
                                    }
                                    if newComments.count > 0 {
                                        self.commentDelegate?.gotNewComment(newComments)
                                    }
                                    if triggerDelegate{
                                        let syncData = QSyncNotifData()
                                        syncData.newMessageCount = newMessageCount
                                        syncData.topicId = topicId
                                        self.commentDelegate?.finishedLoadFromAPI(topicId)
                                    }
                                })
                            }
                        }else if error != nil{
                            if triggerDelegate{
                                self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to sync message with error \(error)")
                            }
                            print("error sync message: \(error)")
                        }
                    }else{
                        if triggerDelegate{
                            self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to sync message, connection error")
                        }
                        print("[Qiscus] error sync message")
                    }
                    
                })
            }
        }
    }
    
    open func getListComment(topicId: Int, commentId: Int, triggerDelegate:Bool = false, loadMore:Bool = false){ //USED
        let manager = Alamofire.SessionManager.default
        var parameters:[String: AnyObject]? = nil
        var loadURL = ""
            loadURL = QiscusConfig.LOAD_URL
            parameters =  [
                "last_comment_id"  : commentId as AnyObject,
                "topic_id" : topicId as AnyObject,
                "token" : qiscus.config.USER_TOKEN as AnyObject
            ]

        print("request getListComment parameters: \(parameters)")
        print("request getListComment url \(loadURL)")
        manager.request(loadURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: {responseData in
            print("[Qiscus] getListComment result: \(responseData)")
            if let response = responseData.result.value{
                let json = JSON(response)
                let results = json["results"]
                let error = json["error"]
                if results != nil{
                    var newMessageCount: Int = 0
                    let comments = json["results"]["comments"].arrayValue
                    if comments.count > 0 {
                        var newComments = [QiscusComment]()
                        for comment in comments {
                            let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                            if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                if loadMore{
                                    thisComment.updateCommentStatus(.read)
                                }else{
                                    thisComment.updateCommentStatus(QiscusCommentStatus.delivered)
                                }
                                if isSaved {
                                    newMessageCount += 1
                                    if loadMore {
                                        newComments.append(thisComment)
                                    }else{
                                        newComments.insert(thisComment, at: 0)
                                    }
                                }
                            }
                        }
                        if newComments.count > 0 {
                            self.commentDelegate?.gotNewComment(newComments)
                        }
                        if loadMore {
                            self.commentDelegate?.didFinishLoadMore()
                        }
                    }
                    if triggerDelegate{
                        self.commentDelegate?.finishedLoadFromAPI(topicId)
                    }
                }else if error != nil{
                    print("error getListComment: \(error)")
                    if triggerDelegate{
                        self.commentDelegate?.didFailedLoadDataFromAPI("failed to load message with error \(error)")
                    }
                }
            }else{
                if triggerDelegate {
                    self.commentDelegate?.didFailedLoadDataFromAPI("failed to sync message, connection error")
                }
            }
        })
    }
    open func getRoom(withID roomId:Int, triggerDelegate:Bool = false, optionalDataCompletion: @escaping (String) -> Void){
        let manager = Alamofire.SessionManager.default
        let loadURL = QiscusConfig.ROOM_REQUEST_ID_URL
        
        let parameters:[String : AnyObject] =  [
            "id" : roomId as AnyObject,
            "token"  : qiscus.config.USER_TOKEN as AnyObject
        ]
        print("get or create room with id url: \(loadURL)")
        print("get or room with id parameters: \(parameters)")
        manager.request(loadURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: {responseData in
            print("response data: \(responseData)")
            if let response = responseData.result.value {
                print("[Qiscus] get or create room api response:\n\(response)")
                let json = JSON(response)
                let results = json["results"]
                let error = json["error"]
                
                if results != nil{
                    print("[Qiscus] getRoom API response: \(responseData)")
                    let roomData = json["results"]["room"]
                    let room = QiscusRoom.getRoom(roomData)
                    let topicId = room.roomLastCommentTopicId
                    
                    
                    QiscusUIConfiguration.sharedInstance.topicId = topicId
                    QiscusChatVC.sharedInstance.topicId = topicId
                    var newMessageCount: Int = 0
                    let comments = json["results"]["comments"].arrayValue
                    if comments.count > 0 {
                        var newComments = [QiscusComment]()
                        for comment in comments {
                            let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                            if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                thisComment.updateCommentStatus(.sent)
                                if isSaved {
                                    newMessageCount += 1
                                    newComments.insert(thisComment, at: 0)
                                }
                            }
                        }
                        if newComments.count > 0 {
                            self.commentDelegate?.gotNewComment(newComments)
                        }
                    }
                    
                    let participants = roomData["participants"].arrayValue
                    for participant in participants{
                        let user = QiscusUser()
                        user.userEmail = participant["email"].stringValue
                        user.userFullName = participant["username"].stringValue
                        user.userAvatarURL = participant["avatar_url"].stringValue
                        
                        let _ = user.saveUser()
                        if user.userEmail != QiscusMe.sharedInstance.email {
                            room.updateUser(user.userEmail)
                        }
                    }
                    
                    if triggerDelegate{
                        self.commentDelegate?.finishedLoadFromAPI(topicId)
                    }
                    optionalDataCompletion(room.optionalData)
                }else if error != nil{
                    print("[Qiscus] error getRoom: \(error)")
                    if triggerDelegate{
                        self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to load message with error \(error)")
                    }
                }
                
            }else{
                if triggerDelegate {
                    self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to sync message, connection error")
                }
            }
        })
    }
    open func getListComment(withUsers users:[String], triggerDelegate:Bool = false, loadMore:Bool = false, distincId:String? = nil, optionalData:String? = nil,optionalDataCompletion: @escaping (String) -> Void){ //USED
        let manager = Alamofire.SessionManager.default
        let loadURL = QiscusConfig.ROOM_REQUEST_URL

        var parameters:[String : AnyObject] =  [
                "emails" : users as AnyObject,
                "token"  : qiscus.config.USER_TOKEN as AnyObject
            ]
        if distincId != nil{
            if distincId != "" {
                parameters["distinct_id"] = distincId! as AnyObject
            }
        }
        if optionalData != nil{
            parameters["options"] = optionalData! as AnyObject
        }
        print("get or create room parameters: \(parameters)")
        manager.request(loadURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: QiscusConfig.sharedInstance.requestHeader).responseJSON(completionHandler: {responseData in
            if let response = responseData.result.value {
                print("[Qiscus] get or create room api response:\n\(response)")
                let json = JSON(response)
                let results = json["results"]
                let error = json["error"]
                
                if results != nil{
                    print("[Qiscus] getListComment with user response: \(responseData)")
                    let roomData = json["results"]["room"]
                    let room = QiscusRoom.getRoom(roomData)
                    let topicId = room.roomLastCommentTopicId
                    let users = parameters["emails"] as! [String]
                    if users.count == 1 {
                        room.updateUser(users.first!)
                    }
                    if distincId != nil {
                        room.updateDistinctId(distincId!)
                    }
                    QiscusUIConfiguration.sharedInstance.topicId = topicId
                    QiscusChatVC.sharedInstance.topicId = topicId
                    var newMessageCount: Int = 0
                    let comments = json["results"]["comments"].arrayValue
                    if comments.count > 0 {
                        var newComments = [QiscusComment]()
                        for comment in comments {
                            let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                            if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                thisComment.updateCommentStatus(QiscusCommentStatus.delivered)
                                if isSaved {
                                    newMessageCount += 1
                                    newComments.insert(thisComment, at: 0)
                                }
                            }
                        }
                        if newComments.count > 0 {
                            self.commentDelegate?.gotNewComment(newComments)
                        }
                        if loadMore {
                            self.commentDelegate?.didFinishLoadMore()
                        }
                    }
                    
                    let participants = roomData["participants"].arrayValue
                    for participant in participants{
                        let user = QiscusUser()
                        user.userEmail = participant["email"].stringValue
                        user.userFullName = participant["username"].stringValue
                        user.userAvatarURL = participant["avatar_url"].stringValue
                        
                        let _ = user.saveUser()
                    }
                    
                    if triggerDelegate{
                        self.commentDelegate?.finishedLoadFromAPI(topicId)
                    }
                    optionalDataCompletion(room.optionalData)
                }else if error != nil{
                    print("[Qiscus] error getListComment: \(error)")
                    if triggerDelegate{
                        self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to load message with error \(error)")
                    }
                }
                
            }else{
                if triggerDelegate {
                    self.commentDelegate?.didFailedLoadDataFromAPI("[Qiscus] failed to sync message, connection error")
                }
            }
        })
    }
    // MARK: - Load More
    open func loadMoreComment(fromCommentId commentId:Int, topicId:Int, limit:Int = 10){
        let comments = QiscusComment.loadMoreComment(fromCommentId: commentId, topicId: topicId, limit: limit)
        print("got \(comments.count) new comments")
        
        if comments.count > 0 {
            var commentData = [QiscusComment]()
            for comment in comments{
                commentData.insert(comment, at: 0)
            }
            print("got \(comments.count) new comments")
            self.commentDelegate?.gotNewComment(commentData)
            self.commentDelegate?.didFinishLoadMore()
        }else{
            self.getListComment(topicId: topicId, commentId: commentId, loadMore: true)
        }
    }
}
