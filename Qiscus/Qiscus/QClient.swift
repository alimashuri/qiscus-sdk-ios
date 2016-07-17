//
//  QiscusAPI.swift
//  LinkDokter
//
//  Created by asharijuang on 1/7/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import Foundation
import UIKit
import PusherSwift
import RxSwift
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation

let qiscus = Qiscus.sharedInstance

public protocol QCommentDelegate {
    func didSuccesPostComment(indexPath:NSIndexPath)
    func didFailedPostComment(indexPath:NSIndexPath)
    func downloadingMedia(pogressData:QProgressData)
    func didDownloadMedia(progressData: QProgressData)
    func didUploadFile(postData:QProgressData)
    func uploadingFile(progressData:QProgressData)
    func didFailedUploadFile(data:QPostData)
    func didSuccessPostFile(data:QPostData)
    func didFailedPostFile(data:QPostData)
}

public class QClient: NSObject {
    static let sharedInstance = QClient()
    
    var commentDelegate: QCommentDelegate?
    
    // MARK: - Comment Methode
    public func postComment(comment:QiscusComment, indexPath:NSIndexPath, file:QiscusFile?){

            let manager = Alamofire.Manager.sharedInstance
            var timestamp: String {
                return "\(NSDate().timeIntervalSince1970 * 1000)"
            }
            let parameters = [
                "token" : qiscus.config.USER_TOKEN,
                "comment"  : comment.commentText,
                "topic_id" : comment.commentTopicId,
                "unique_id" : comment.commentUniqueId
            ]
            let request = manager.request(.POST, QiscusConfig.postCommentURL, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
                switch response.result {
                    case .Success:
                        if let result = response.result.value {
                            let json = JSON(result)
                            let success = json["success"].boolValue
                            if success == true {
                                comment.updateCommentId(json["comment_id"].intValue)
                                comment.updateCommentStatus(QiscusCommentStatus.Sent)
                                let commentBeforeid = QiscusComment.getCommentBeforeIdFromJSON(json)
                                if(QiscusComment.isValidCommentIdExist(commentBeforeid)){
                                    comment.updateCommentIsSync(true)
                                }else{
                                    QiscusComment.syncMessage(comment.commentTopicId)
                                }
                                
                                self.commentDelegate?.didSuccesPostComment(indexPath)
                                
                                if file != nil {
                                    let data = QPostData()
                                    let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                    if(file != nil){
                                        file?.updateCommentId(thisComment!.commentId)
                                        let thisFile = QiscusFile().getCommentFileWithComment(thisComment!)
                                        data.file = thisFile
                                    }
                                    data.comment = thisComment!
                                    data.indexPath = indexPath
                                    
                                    self.commentDelegate?.didSuccessPostFile(data)
                                }
                            }
                        }else{
                            comment.updateCommentStatus(QiscusCommentStatus.Failed)
                            self.commentDelegate?.didFailedPostComment(indexPath)
                            
                            if file != nil{
                                let data = QPostData()
                                let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                                if(file != nil){
                                    file?.updateCommentId(thisComment!.commentId)
                                    let thisFile = QiscusFile().getCommentFileWithComment(thisComment!)
                                    data.file = thisFile
                                }
                                data.comment = thisComment!
                                data.indexPath = indexPath
                                self.commentDelegate?.didFailedPostFile(data)
                            }
                        }
                        break
                    case .Failure(_):
                        comment.updateCommentStatus(QiscusCommentStatus.Failed)
                        self.commentDelegate?.didFailedPostComment(indexPath)
                        if file != nil{
                            let data = QPostData()
                            let thisComment = QiscusComment.getCommentByLocalId(comment.localId)
                            if(file != nil){
                                file?.updateCommentId(thisComment!.commentId)
                                let thisFile = QiscusFile().getCommentFileWithComment(thisComment!)
                                data.file = thisFile
                            }
                            data.comment = thisComment!
                            data.indexPath = indexPath
                            self.commentDelegate?.didFailedPostFile(data)
                    }
                }
            }
            request.resume()
    }
    
    func downloadMedia(file:QiscusFile, indexPath: NSIndexPath){
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
    
    
    // MARK: - empty methode
    func emptyCallBack(data: QPostData){}
    
    // MARK: - unused(maybe) methode
    func getRoomOnly() -> Observable<Any> {
        return Observable.create { observer in
            let manager = Alamofire.Manager.sharedInstance
            let params = "token=\(qiscus.config.USER_TOKEN)"
            
            let request = manager.request(.GET, qiscus.config.BASE_URL + "/rooms_only?\(params)", parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    let status = json["status"].stringValue
                    print("status \(status), data json: \(json)")
                    
                    if status == "200"{
                        let rooms = json["results"]["balance"].arrayValue
                        print("rooms: \(rooms)")
                        observer.onNext(rooms)
                    }else{

                        observer.onError(RxError.Unknown)
                        let errorAlert = json["data"]["message"].stringValue
                        print(errorAlert)
                    }
                    
                }else{
                    
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }

}
