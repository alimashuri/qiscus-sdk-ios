//
//  QCommentFile.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import AlamofireImage
import AVFoundation
import SwiftyJSON

enum QFileType:Int {
    case Media
    case Document
    case Video
    case Others
}

public class QCommentFile: Object {
    dynamic var fileId:Int = 0
    dynamic var fileURL:NSString = ""
    dynamic var fileLocalPath:NSString = ""
    dynamic var fileThumbPath:NSString = ""
    dynamic var fileTopicId:Int = 0
    dynamic var fileCommentId:Int = 0
    dynamic var isDownloading:Bool = false
    dynamic var isUploading:Bool = false
    dynamic var downloadProgress:CGFloat = 0
    dynamic var uploadProgress:CGFloat = 0
    dynamic var uploaded = true
    dynamic var unusedVar:Bool = false
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.width
        }
    }
    var screenHeight:CGFloat{
        get{
            return UIScreen.mainScreen().bounds.size.height
        }
    }
    
    var fileExtension:NSString{
        get{
            return getExtension()
        }
    }
    var fileName:NSString{
        get{
            return getFileName()
        }
    }
    var fileType:QFileType{
        get {
            var type:QFileType = QFileType.Others
            if(isMediaFile()){
                type = QFileType.Media
            }else if(isPdfFile()){
                type = QFileType.Document
            }else if(isVideoFile()){
                type = QFileType.Video
            }
            return type
        }
    }
    var qiscus:Qiscus{
        get{
            return Qiscus.sharedInstance
        }
    }
    override public class func primaryKey() -> String {
        return "fileId"
    }
    
    func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QCommentFile).sorted("fileId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.fileId
        } else {
            return 0
        }
    }
    func getCommentFileWithComment(comment: QComment)->QCommentFile?{
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        var file:QCommentFile?
        
        searchQuery = NSPredicate(format: "fileId == %d", comment.commentFileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            searchQuery = NSPredicate(format: "fileCommentId == %d", comment.commentId)
            let data = realm.objects(QCommentFile).filter(searchQuery)
            print("data count on query: \(fileData.count)")
            if(data.count > 0){
                file = data.first!
            }
        }else{
            file = fileData.first!
        }
        return file
    }
    func getCommentFileWithURL(url: String)->QCommentFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileURL == %@", url)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    func getCommentFile(fileId: Int)->QCommentFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    func saveCommentFile(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(self.fileId == 0){
            self.fileId = getLastId() + 1
        }
        if(fileData.count == 0){
            try! realm.write {
                realm.add(self)
            }
        }else{
            let file = fileData.first!
            try! realm.write {
                file.fileURL = self.fileURL
                file.fileLocalPath = self.fileLocalPath
                file.fileThumbPath = self.fileThumbPath
                file.fileTopicId = self.fileTopicId
                file.fileCommentId = self.fileCommentId
            }
        }
    }
    
    // MARK: - Setter Methode
    func updateURL(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileURL = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileURL = url
            }
        }
    }
    func updateCommentId(commentId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileCommentId = commentId
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileCommentId = commentId
            }
        }
    }
    func updateLocalPath(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileLocalPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileLocalPath = url
            }
        }
    }
    func updateThumbPath(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QCommentFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileThumbPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileThumbPath = url
            }
        }
    }
    func updateIsUploading(uploading: Bool){
        let realm = try! Realm()
        
        try! realm.write{
            self.isUploading = uploading
        }
    }
    func updateIsDownloading(downloading: Bool){
        let realm = try! Realm()

        try! realm.write{
            self.isDownloading = downloading
        }
    }
    func updateUploadProgress(progress: CGFloat){
        let realm = try! Realm()
        
        try! realm.write{
            self.uploadProgress = progress
        }
    }
    func updateDownloadProgress(progress: CGFloat){
        let realm = try! Realm()
        
        try! realm.write{
            self.downloadProgress = progress
        }
    }
    // MARK: Additional Methode
    private func getExtension() -> String{
        var ext = ""
        if (self.fileName as String).rangeOfString(".") != nil{
            let fileNameArr = (self.fileName as String).characters.split(".")
            ext = String(fileNameArr.last!).lowercaseString
        }
        return ext
    }
    private func getFileName() ->String{
        var mediaURL:NSURL = NSURL()
        var fileName:String? = ""
        if(self.fileLocalPath.isEqualToString("")){
            mediaURL = NSURL(string: self.fileURL as String)!
            fileName = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
        }else if(self.fileLocalPath as String).rangeOfString("/") == nil{
            fileName = self.fileLocalPath as String
        }else{
            mediaURL = NSURL(string: self.fileLocalPath as String)!
            fileName = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
        }
        
        return fileName!
    }
    private func isPdfFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension() as NSString
        
        if(ext.isEqualToString("pdf") || ext.isEqualToString("pdf_")){
            check = true
        }

        return check
    }
    private func isVideoFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension() as NSString
        
        if(ext.isEqualToString("mov") || ext.isEqualToString("mov_") || ext.isEqualToString("mp4") || ext.isEqualToString("mp4_")){
            check = true
        }
        
        return check
    }
    private func isMediaFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension() as NSString
        
        if(ext.isEqualToString("jpg") || ext.isEqualToString("jpg_") || ext.isEqualToString("png") || ext.isEqualToString("png_") ||
            ext.isEqualToString("gif") || ext.isEqualToString("gif")){
            check = true
        }
        
        return check
    }
    func createThumbImage(image:UIImage, size: CGFloat)->UIImage{
        var smallPart:CGFloat = image.size.height
        if(image.size.width > image.size.height){
            smallPart = image.size.width
        }
        let ratio:CGFloat = CGFloat(size/smallPart)
        let newSize = CGSizeMake((image.size.width * ratio),(image.size.height * ratio))
        
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func downloadMedia(indexPath: NSIndexPath){
        let manager = Alamofire.Manager.sharedInstance
        
        print("download start: \(self.fileURL)")
        print("Token token=\(qiscus.config.USER_TOKEN)")
        let headers = qiscus.config.header
        
        self.updateIsDownloading(true)
        manager.request(.GET, (self.fileURL as String), parameters: nil, encoding: ParameterEncoding.URL, headers: headers)
            .progress{bytesRead, totalBytesRead, totalBytesExpectedToRead in
                let progress = CGFloat(CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead))
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("Download progress: \(progress)")
                    self.updateDownloadProgress(progress)
                    let data = QProgressData()
                    data.indexPath = indexPath
                    data.progress = progress
                    NSNotificationCenter.defaultCenter().postNotificationName("QCommentDataChange", object: data)
                }
                
            }
            .responseData { response in
                if let fileData:NSData = response.data{
                    if let image:UIImage = UIImage(data: fileData) {
                        var thumbImage = UIImage()
                        if !(self.fileExtension.isEqualToString("gif") || self.fileExtension.isEqualToString("gif_")){
                            thumbImage = self.createThumbImage(image)
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateDownloadProgress(1.0)
                            self.updateIsDownloading(false)
                        }
                        print("Download finish")
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let path = "\(documentsPath)/\(self.fileName as String)"
                        let thumbPath = "\(documentsPath)/thumb_\(self.fileName as String)"
                        
                        if (self.fileExtension.isEqualToString("png")||self.fileExtension.isEqualToString("png_")) {
                            UIImagePNGRepresentation(image)!.writeToFile(path, atomically: true)
                            UIImagePNGRepresentation(thumbImage)!.writeToFile(thumbPath, atomically: true)
                        } else if(self.fileExtension.isEqualToString("jpg")||self.fileExtension.isEqualToString("jpg_")){
                            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(path, atomically: true)
                            UIImageJPEGRepresentation(thumbImage, 1.0)!.writeToFile(thumbPath, atomically: true)
                        } else if(self.fileExtension.isEqualToString("gif")||self.fileExtension.isEqualToString("gif_")){
                            fileData.writeToFile(path, atomically: true)
                            fileData.writeToFile(thumbPath, atomically: true)
                            thumbImage = image
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateLocalPath(path)
                            self.updateThumbPath(thumbPath)
                            let data = QProgressData()
                            data.indexPath = indexPath
                            data.progress = 1.1
                            data.localImage = thumbImage
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("QCommentDataChange", object: data)
                        }
                        
                    }else{
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let path = "\(documentsPath)/\(self.fileName as String)"
                        let thumbPath = "\(documentsPath)/thumb_\(self.fileCommentId).png"
                        
                        fileData.writeToFile(path, atomically: true)
                        
                        let assetMedia = AVURLAsset(URL: NSURL(string: "file://\(path)")!)
                        let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
                        thumbGenerator.appliesPreferredTrackTransform = true
                        
                        let thumbTime = CMTimeMakeWithSeconds(0, 30)
                        let maxSize = CGSizeMake(self.screenWidth, self.screenWidth)
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
                            self.updateDownloadProgress(1.0)
                            self.updateIsDownloading(false)
                            self.updateLocalPath(path)
                            self.updateThumbPath(thumbPath)
                            let data = QProgressData()
                            data.indexPath = indexPath
                            data.progress = 1.1
                            data.localImage = thumbImage!
                            data.isVideoFile = true
                            NSNotificationCenter.defaultCenter().postNotificationName("QCommentDataChange", object: data)
                        }
                    }
                }
            }
    }
    
    // MARK: - image manipulation
    func getLocalThumbImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileThumbPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    func getLocalImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileLocalPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    public func createThumbImage(image:UIImage)->UIImage{
        var smallPart:CGFloat = image.size.height
        if(image.size.width > image.size.height){
            smallPart = image.size.width
        }
        let ratio:CGFloat = CGFloat(130.0/smallPart)
        let newSize = CGSizeMake((image.size.width * ratio),(image.size.height * ratio))
        
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func isLocalFileExist()->Bool{
        var check:Bool = false
        
        let checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(self.fileLocalPath as String) && checkValidation.fileExistsAtPath(self.fileThumbPath as String))
        {
            check = true
        }
        return check
    }
    func uploadImage(data:NSData, fileName:String, mimeType:String, indexPath:NSIndexPath, comment:QComment,commentFile:QCommentFile, success:(QPostData)->Void, failed:(QPostData)->Void){
        self.updateIsUploading(true)
        self.updateUploadProgress(0.0)
        
        //Processing Upload
        
        
        let headers = qiscus.config.header
        
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
                                            comment.updateCommentStatus(QCommentStatus.Sending)
                                            comment.updateCommentText("[file]\(url) [/file]")
                                            print("upload success")
                                            let progressData = QProgressData()
                                            progressData.progress = 1.1
                                            progressData.url = url
                                            progressData.indexPath = indexPath
                                            progressData.comment = comment
                                            progressData.file = commentFile
                                            self.updateURL(url)
                                            self.updateIsUploading(false)
                                            self.updateUploadProgress(1.0)
                                            progressData.file = self
                                            NSNotificationCenter.defaultCenter().postNotificationName("QCommentUploadSuccess", object: progressData)
                                            //QComment.postMessage(comment, file: commentFile, indexPaths: indexPath, success: success, failed: failed)
                                            
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
                            progressData.file = commentFile
                            self.updateIsUploading(true)
                            self.updateUploadProgress(progress)
                            NSNotificationCenter.defaultCenter().postNotificationName("QCommentUploadChange", object: progressData)
                        })
                    })
                    upload.response(completionHandler: { (request, httpResponse, data, error) in
                        if error != nil || httpResponse?.statusCode >= 400 {
                            comment.updateCommentStatus(QCommentStatus.Failed)
                            let progressData = QPostData()
                            progressData.indexPath = indexPath
                            progressData.comment = comment
                            progressData.file = commentFile
                            self.updateIsUploading(false)
                            self.updateUploadProgress(0)
                            failed(progressData)
                        }else{
                            print("http response upload: \(httpResponse)\n")
                        }
                    })
                case .Failure(_):
                    print("encoding error:")
                    comment.updateCommentStatus(QCommentStatus.Failed)
                    let progressData = QPostData()
                    progressData.indexPath = indexPath
                    progressData.comment = comment
                    progressData.file = commentFile
                    self.updateIsUploading(false)
                    self.updateUploadProgress(0)
                    failed(progressData)
                }
            }
        )
    }
}
