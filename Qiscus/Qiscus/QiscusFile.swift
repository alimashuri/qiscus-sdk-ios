//
//  QiscusFile.swift
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
import QAsyncImageView

public enum QFileType:Int {
    case Media
    case Document
    case Video
    case Others
}

public class QiscusFile: Object {
    public dynamic var fileId:Int = 0
    public dynamic var fileURL:String = ""
    public dynamic var fileLocalPath:String = ""
    public dynamic var fileThumbPath:String = ""
    public dynamic var fileTopicId:Int = 0
    public dynamic var fileCommentId:Int = 0
    public dynamic var isDownloading:Bool = false
    public dynamic var isUploading:Bool = false
    public dynamic var downloadProgress:CGFloat = 0
    public dynamic var uploadProgress:CGFloat = 0
    public dynamic var uploaded = true
    public dynamic var unusedVar:Bool = false
    
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
    
    public var fileExtension:String{
        get{
            return getExtension()
        }
    }
    public var fileName:String{
        get{
            return getFileName()
        }
    }
    public var fileType:QFileType{
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
    public var qiscus:Qiscus{
        get{
            return Qiscus.sharedInstance
        }
    }
    override public class func primaryKey() -> String {
        return "fileId"
    }
    
    public class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusFile).sorted("fileId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.fileId
        } else {
            return 0
        }
    }
    public class func getCommentFileWithComment(comment: QiscusComment)->QiscusFile?{
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        var file:QiscusFile?
        
        searchQuery = NSPredicate(format: "fileId == %d", comment.commentFileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            searchQuery = NSPredicate(format: "fileCommentId == %d", comment.commentId)
            let data = realm.objects(QiscusFile).filter(searchQuery)
            if(data.count > 0){
                file = data.first!
            }
        }else{
            file = fileData.first!
        }
        return file
    }
    public class func getCommentFileWithURL(url: String)->QiscusFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileURL == %@", url)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    public class func getCommentFile(fileId: Int)->QiscusFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    public func saveCommentFile(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(self.fileId == 0){
            self.fileId = QiscusFile.getLastId() + 1
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
    public func updateURL(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileURL = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileURL = url
            }
        }
    }
    public func updateCommentId(commentId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileCommentId = commentId
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileCommentId = commentId
            }
        }
    }
    public func updateLocalPath(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileLocalPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileLocalPath = url
            }
        }
    }
    public func updateThumbPath(url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileThumbPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileThumbPath = url
            }
        }
    }
    public func updateIsUploading(uploading: Bool){
        let realm = try! Realm()
        
        try! realm.write{
            self.isUploading = uploading
        }
    }
    public func updateIsDownloading(downloading: Bool){
        let realm = try! Realm()

        try! realm.write{
            self.isDownloading = downloading
        }
    }
    public func updateUploadProgress(progress: CGFloat){
        let realm = try! Realm()
        
        try! realm.write{
            self.uploadProgress = progress
        }
    }
    public func updateDownloadProgress(progress: CGFloat){
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
        if(self.fileLocalPath == ""){
            mediaURL = NSURL(string: self.fileURL as String)!
            fileName = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
        }else if(self.fileLocalPath as String).rangeOfString("/") == nil{
            fileName = self.fileLocalPath as String
        }else{
            mediaURL = NSURL(string: self.fileLocalPath as String)!
            let fileNameOri = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
            fileName = fileNameOri?.componentsSeparatedByString("-Q-").last
        }
        
        return fileName!
    }
    private func isPdfFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "pdf" || ext == "pdf_"){
            check = true
        }

        return check
    }
    private func isVideoFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "mov" || ext == "mov_" || ext == "mp4" || ext == "mp4_"){
            check = true
        }
        
        return check
    }
    private func isMediaFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "jpg" || ext == "jpg_" || ext == "png" || ext == "png_" || ext == "gif" || ext == "gif_"){
            check = true
        }
        
        return check
    }
    
    // MARK: - image manipulation
    public func getLocalThumbImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileThumbPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    public func getLocalImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileLocalPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    public class func createThumbImage(image:UIImage, withMaskImage:UIImage? = nil, fillImageSize:UIImage? = nil)->UIImage{
        var inputImage = image
        if withMaskImage != nil {
            inputImage = QAsyncImageView.maskImage(image, mask: withMaskImage!)
        }
        if fillImageSize == nil{
            var smallPart:CGFloat = inputImage.size.height
            
            if(inputImage.size.width > inputImage.size.height){
                smallPart = inputImage.size.width
            }
            let ratio:CGFloat = CGFloat(396.0/smallPart)
            let newSize = CGSizeMake((inputImage.size.width * ratio),(inputImage.size.height * ratio))
            
            UIGraphicsBeginImageContext(newSize)
            inputImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }else{
            let newImage = UIImage.resizeImage(inputImage, toFillOnImage: fillImageSize!)
            
            return newImage
        }
    }
    public class func saveFile(fileData: NSData, fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = "\(documentsPath)/\(fileName)"
        
        fileData.writeToFile(path, atomically: true)
        
        return path
    }
    public func isLocalFileExist()->Bool{
        var check:Bool = false
        
        let checkValidation = NSFileManager.defaultManager()
        
        if (self.fileLocalPath != "" && checkValidation.fileExistsAtPath(self.fileLocalPath as String) && checkValidation.fileExistsAtPath(self.fileThumbPath as String))
        {
            check = true
        }
        return check
    }
}
