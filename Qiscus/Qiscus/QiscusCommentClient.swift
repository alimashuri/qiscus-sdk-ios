//
//  QiscusCommentClient.swift
//  QiscusSDK
//
//  Created by ahmad athaullah on 7/17/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import Foundation
import UIKit
import PusherSwift
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation

let qiscus = Qiscus.sharedInstance

public class QiscusCommentClient: NSObject {
    public static let sharedInstance = QiscusCommentClient()
    
    public var commentDelegate: QCommentDelegate?
    
    // MARK: - Comment Methode
    public func postMessage(message message: String, topicId: Int, indexPath: NSIndexPath){ //USED
        let comment = QiscusComment.newCommentWithMessage(message: message, inTopicId: topicId)
        self.postComment(comment, indexPath: indexPath)
        self.commentDelegate?.gotNewComment(comment)
    }
    public func postComment(comment:QiscusComment, indexPath:NSIndexPath, file:QiscusFile? = nil){ //USED
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let manager = Alamofire.Manager.sharedInstance
            var timestamp: String {
                return "\(NSDate().timeIntervalSince1970 * 1000)"
            }
            let parameters:[String: AnyObject] = [
                "token" : qiscus.config.USER_TOKEN,
                "comment"  : comment.commentText,
                "topic_id" : comment.commentTopicId,
                "unique_id" : comment.commentUniqueId
            ]
            let request = manager.request(.POST, QiscusConfig.postCommentURL, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
                switch response.result {
                    case .Success:
                        dispatch_async(dispatch_get_main_queue()) {
                            if let result = response.result.value {
                                let json = JSON(result)
                                print("json post message: \(json)")
                                let success = json["success"].boolValue
                                
                                if success == true {
                                    comment.updateCommentId(json["comment_id"].intValue)
                                    comment.updateCommentStatus(QiscusCommentStatus.Sent)
                                    let commentBeforeid = QiscusComment.getCommentBeforeIdFromJSON(json)
                                    if(QiscusComment.isValidCommentIdExist(commentBeforeid)){
                                        comment.updateCommentIsSync(true)
                                    }else{
                                        self.syncMessage(comment.commentTopicId)
                                    }
                                    
                                    self.commentDelegate?.didSuccesPostComment(comment)
                                    
                                    if file != nil {
                                        let data = QPostData()
                                        let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                        if(file != nil){
                                            file?.updateCommentId(thisComment!.commentId)
                                            let thisFile = QiscusFile.getCommentFileWithComment(thisComment!)
                                            data.file = thisFile
                                        }
                                        data.comment = thisComment!
                                        data.indexPath = indexPath
                                        
                                        self.commentDelegate?.didSuccessPostFile(data)
                                    }
                                }
                            }else{
                                comment.updateCommentStatus(QiscusCommentStatus.Failed)
                                self.commentDelegate?.didFailedPostComment(comment)
                                
                                if file != nil{
                                    let data = QPostData()
                                    let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                    if(file != nil){
                                        file?.updateCommentId(thisComment!.commentId)
                                        let thisFile = QiscusFile.getCommentFileWithComment(thisComment!)
                                        data.file = thisFile
                                    }
                                    data.comment = thisComment!
                                    data.indexPath = indexPath
                                    self.commentDelegate?.didFailedPostFile(data)
                                }
                            }
                        }
                        break
                    case .Failure(_):
                        dispatch_async(dispatch_get_main_queue()) {
                            comment.updateCommentStatus(QiscusCommentStatus.Failed)
                            self.commentDelegate?.didFailedPostComment(comment)
                            if file != nil{
                                let data = QPostData()
                                let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                if(file != nil){
                                    file?.updateCommentId(thisComment!.commentId)
                                    let thisFile = QiscusFile.getCommentFileWithComment(thisComment!)
                                    data.file = thisFile
                                }
                                data.comment = thisComment!
                                data.indexPath = indexPath
                                self.commentDelegate?.didFailedPostFile(data)
                        }
                    }
                }
            }
            request.resume()
        }
    }
    
    public func downloadMedia(file:QiscusFile, indexPath: NSIndexPath){
        let manager = Alamofire.Manager.sharedInstance
        
        let headers = QiscusConfig.requestHeader
        
        file.updateIsDownloading(true)
        manager.request(.GET, (file.fileURL as String), parameters: nil, encoding: ParameterEncoding.URL, headers: headers)
            .progress{bytesRead, totalBytesRead, totalBytesExpectedToRead in
                let progress = CGFloat(CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead))
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("Download progress: \(progress)")
                    file.updateDownloadProgress(progress)
                    let data = QProgressData()
                    data.indexPath = indexPath
                    data.progress = progress
                    self.commentDelegate?.downloadingMedia(data)
                }
            }
            .responseData { response in
                if let fileData:NSData = response.data{
                    if let image:UIImage = UIImage(data: fileData) {
                        var thumbImage = UIImage()
                        if !(file.fileExtension.isEqualToString("gif") || file.fileExtension.isEqualToString("gif_")){
                            thumbImage = file.createThumbImage(image)
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            file.updateDownloadProgress(1.0)
                            file.updateIsDownloading(false)
                        }
                        print("Download finish")
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let path = "\(documentsPath)/\(file.fileName as String)"
                        let thumbPath = "\(documentsPath)/thumb_\(file.fileName as String)"
                        
                        if (file.fileExtension.isEqualToString("png")||file.fileExtension.isEqualToString("png_")) {
                            UIImagePNGRepresentation(image)!.writeToFile(path, atomically: true)
                            UIImagePNGRepresentation(thumbImage)!.writeToFile(thumbPath, atomically: true)
                        } else if(file.fileExtension.isEqualToString("jpg")||file.fileExtension.isEqualToString("jpg_")){
                            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(path, atomically: true)
                            UIImageJPEGRepresentation(thumbImage, 1.0)!.writeToFile(thumbPath, atomically: true)
                        } else if(file.fileExtension.isEqualToString("gif")||file.fileExtension.isEqualToString("gif_")){
                            fileData.writeToFile(path, atomically: true)
                            fileData.writeToFile(thumbPath, atomically: true)
                            thumbImage = image
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            file.updateLocalPath(path)
                            file.updateThumbPath(thumbPath)
                            let data = QProgressData()
                            data.indexPath = indexPath
                            data.progress = 1.1
                            data.localImage = thumbImage
                            
                            self.commentDelegate?.didDownloadMedia(data)
                        }
                        
                    }else{
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let path = "\(documentsPath)/\(file.fileName as String)"
                        let thumbPath = "\(documentsPath)/thumb_\(file.fileCommentId).png"
                        
                        fileData.writeToFile(path, atomically: true)
                        
                        let assetMedia = AVURLAsset(URL: NSURL(string: "file://\(path)")!)
                        let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
                        thumbGenerator.appliesPreferredTrackTransform = true
                        
                        let thumbTime = CMTimeMakeWithSeconds(0, 30)
                        let maxSize = CGSizeMake(file.screenWidth, file.screenWidth)
                        thumbGenerator.maximumSize = maxSize
                        var thumbImage:UIImage?
                        do{
                            let thumbRef = try thumbGenerator.copyCGImageAtTime(thumbTime, actualTime: nil)
                            thumbImage = UIImage(CGImage: thumbRef)
                            
                            let thumbData = UIImagePNGRepresentation(thumbImage!)
                            thumbData?.writeToFile(thumbPath, atomically: true)
                        }catch{
                            print("error creating thumb image")
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            file.updateDownloadProgress(1.0)
                            file.updateIsDownloading(false)
                            file.updateLocalPath(path)
                            file.updateThumbPath(thumbPath)
                            let data = QProgressData()
                            data.indexPath = indexPath
                            data.progress = 1.1
                            data.localImage = thumbImage!
                            data.isVideoFile = true
                            self.commentDelegate?.didDownloadMedia(data)
                        }
                    }
                }
        }
    }
    public func uploadImage(data:NSData, fileName:String, mimeType:String, indexPath:NSIndexPath, comment:QiscusComment,commentFile:QiscusFile){
        
        commentFile.updateIsUploading(true)
        commentFile.updateUploadProgress(0.0)
        
        let headers = QiscusConfig.requestHeader
        
        Alamofire.upload(.POST, qiscus.config.UPLOAD_URL,
                         headers: headers,
                         multipartFormData: { multipartFormData in
                            multipartFormData.appendBodyPart(data: data, name: "raw_file", fileName: "\(fileName)", mimeType: "\(mimeType)")
            }, encodingCompletion: { encodingResult in
                print("encodingResult: \(encodingResult)")
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let JSON = response.result.value {
                            print(JSON)
                            let responseDictionary = JSON as! NSDictionary
                            print(responseDictionary)
                            if let data:NSDictionary = responseDictionary.valueForKey("data") as? NSDictionary{
                                if let file:NSDictionary = data.valueForKey("file") as? NSDictionary{
                                    if let url:String = file.valueForKey("url") as? String{
                                        
                                        dispatch_async(dispatch_get_main_queue(),{
                                            comment.updateCommentStatus(QiscusCommentStatus.Sending)
                                            comment.updateCommentText("[file]\(url) [/file]")
                                            print("upload success")
                                            let progressData = QProgressData()
                                            progressData.progress = 1.1
                                            progressData.url = url
                                            progressData.indexPath = indexPath
                                            progressData.comment = comment
                                            commentFile.updateURL(url)
                                            commentFile.updateIsUploading(false)
                                            commentFile.updateUploadProgress(1.0)
                                            progressData.file = commentFile
                                            
                                            self.commentDelegate?.didUploadFile(progressData)
                                            
                                            self.postComment(comment, indexPath: indexPath, file: commentFile)
                                            
                                        })
                                    }
                                }
                            }
                        }
                    }
                    upload.progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in //
                        dispatch_async(dispatch_get_main_queue(),{
                            let progress = CGFloat(CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite))
                            print("upload progress: ",progress)
                            
                            let progressData = QProgressData()
                            progressData.progress = progress
                            progressData.indexPath = indexPath
                            progressData.comment = comment
                            commentFile.updateIsUploading(true)
                            commentFile.updateUploadProgress(progress)
                            progressData.file = commentFile
                            self.commentDelegate?.uploadingFile(progressData)
                        })
                    })
                    upload.response(completionHandler: { (request, httpResponse, data, error) in
                        if error != nil || httpResponse?.statusCode >= 400 {
                            comment.updateCommentStatus(QiscusCommentStatus.Failed)
                            let progressData = QPostData()
                            progressData.indexPath = indexPath
                            progressData.comment = comment
                            commentFile.updateIsUploading(false)
                            commentFile.updateUploadProgress(0)
                            progressData.file = commentFile
                            
                            self.commentDelegate?.didFailedUploadFile(progressData)
                        }else{
                            print("http response upload: \(httpResponse)\n")
                        }
                    })
                case .Failure(_):
                    print("encoding error:")
                    comment.updateCommentStatus(QiscusCommentStatus.Failed)
                    let progressData = QPostData()
                    progressData.indexPath = indexPath
                    progressData.comment = comment
                    commentFile.updateIsUploading(false)
                    commentFile.updateUploadProgress(0)
                    progressData.file = commentFile
                    self.commentDelegate?.didFailedUploadFile(progressData)
                }
            }
        )
    }
    // MARK: - Communicate with Server
    public func syncMessage(topicId: Int, triggerDelegate:Bool = false) {
        dispatch_async(dispatch_get_main_queue()) {
            let manager = Alamofire.Manager.sharedInstance
            let commentId = QiscusComment.getLastSyncCommentId(topicId)
            print(";ast synced comment id: \(commentId)")
            manager.request(.GET, QiscusConfig.SYNC_URL(topicId, commentId: commentId), parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    print ("syncing....")
                    print ("stnc data:\n\(json)")
                    let results = json["results"]
                    let error = json["error"]
                    if results != nil{
                        let comments = json["results"]["comments"].arrayValue
                        if comments.count > 0 {
                            dispatch_async(dispatch_get_main_queue(), {
                                var newMessageCount: Int = 0
                                for comment in comments {
                                    print("comment from sync: \(comment)")
                                    let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                                    
                                    if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                        thisComment.updateCommentStatus(QiscusCommentStatus.Delivered)
                                        if isSaved {
                                            newMessageCount += 1
                                            self.commentDelegate?.gotNewComment(thisComment)
                                        }
                                    }
                                }
                                
                                if triggerDelegate{
                                    let syncData = QSyncNotifData()
                                    syncData.newMessageCount = newMessageCount
                                    syncData.topicId = topicId
                                    self.commentDelegate?.finishedLoadFromAPI(syncData)
                                }
                                
                            })
                        }
                    }else if error != nil{
                        if triggerDelegate{
                            self.commentDelegate?.didFailedLoadDataFromAPI("failed to sync message with error \(error)")
                        }
                        print("error sync message: \(error)")
                    }
                }else{
                    if triggerDelegate{
                        self.commentDelegate?.didFailedLoadDataFromAPI("failed to sync message, connection error")
                    }
                    print("error sync message")
                }
            }
        }
    }
    
    public func getListComment(topicId topicId: Int, commentId: Int, triggerDelegate:Bool = false){ //USED
        let manager = Alamofire.Manager.sharedInstance
        
        manager.request(.GET, QiscusConfig.LOAD_URL(topicId, commentId: commentId), parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                let results = json["results"]
                let error = json["error"]
                if results != nil{
                    var newMessageCount: Int = 0
                    let comments = json["results"]["comments"].arrayValue
                    if comments.count > 0 {
                        for comment in comments {
                            let isSaved = QiscusComment.getCommentFromJSON(comment, topicId: topicId, saved: true)
                            if let thisComment = QiscusComment.getCommentById(QiscusComment.getCommentIdFromJSON(comment)){
                                thisComment.updateCommentStatus(QiscusCommentStatus.Delivered)
                                if isSaved {
                                    newMessageCount += 1
                                    self.commentDelegate?.gotNewComment(thisComment)
                                }
                            }
                        }
                        
                        if triggerDelegate{
                            let syncData = QSyncNotifData()
                            syncData.newMessageCount = newMessageCount
                            syncData.topicId = topicId
                            self.commentDelegate?.finishedLoadFromAPI(syncData)
                        }
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
        }
    }
}
