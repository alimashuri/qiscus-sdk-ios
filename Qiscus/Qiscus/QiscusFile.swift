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

public enum QFileType:Int {
    case media
    case document
    case video
    case audio
    case others
}

open class QiscusFile: Object {
    open dynamic var fileId:Int = 0
    open dynamic var fileURL:String = ""
    open dynamic var fileLocalPath:String = ""
    open dynamic var fileThumbPath:String = ""
    open dynamic var fileTopicId:Int = 0
    open dynamic var fileCommentId:Int = 0
    open dynamic var isDownloading:Bool = false
    open dynamic var isUploading:Bool = false
    open dynamic var downloadProgress:CGFloat = 0
    open dynamic var uploadProgress:CGFloat = 0
    open dynamic var uploaded = true
    open dynamic var unusedVar:Bool = false
    
    var isUploaded:Bool{
        get{
            var check = false
            let regex = "^(http|https)://"
            let url = self.fileURL
            if let range = url.range(of:regex, options: .regularExpression) {
                let result = url.substring(with:range)
                if result != "" {
                    check = true
                }
            }
            return check
        }
    }
    var isOnlyLocalFileExist:Bool{
        get{
            var check:Bool = false
            let checkValidation = FileManager.default
            if (self.fileLocalPath != "" && checkValidation.fileExists(atPath: self.fileLocalPath as String))
            {
                check = true
            }
            return check
        }
    }
    var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    var screenHeight:CGFloat{
        get{
            return UIScreen.main.bounds.size.height
        }
    }
    
    open var fileExtension:String{
        get{
            return getExtension()
        }
    }
    open var fileName:String{
        get{
            return getFileName()
        }
    }
    open var fileType:QFileType{
        get {
            var type:QFileType = QFileType.others
            if(isMediaFile()){
                type = QFileType.media
            }else if(isPdfFile()){
                type = QFileType.document
            }else if(isVideoFile()){
                type = QFileType.video
            }else if isAudioFile() {
                type = QFileType.audio
            }
            return type
        }
    }
    open var qiscus:Qiscus{
        get{
            return Qiscus.sharedInstance
        }
    }
    override open class func primaryKey() -> String {
        return "fileId"
    }
    
    open class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusFile.self).sorted(byProperty: "fileId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.fileId
        } else {
            return 0
        }
    }
    open class func getCommentFileWithComment(_ comment: QiscusComment)->QiscusFile?{
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        var file:QiscusFile?
        
        searchQuery = NSPredicate(format: "fileId == %d", comment.commentFileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            searchQuery = NSPredicate(format: "fileCommentId == %d", comment.commentId)
            let data = realm.objects(QiscusFile.self).filter(searchQuery)
            if(data.count > 0){
                file = data.first!
            }
        }else{
            file = fileData.first!
        }
        return file
    }
    open class func getCommentFileWithURL(_ url: String)->QiscusFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileURL == %@", url)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    open class func getCommentFile(_ fileId: Int)->QiscusFile?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            return nil
        }else{
            return fileData.first!
        }
    }
    open func saveCommentFile(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
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
    open func updateURL(_ url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileURL = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileURL = url
            }
        }
    }
    open func updateCommentId(_ commentId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileCommentId = commentId
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileCommentId = commentId
            }
        }
    }
    open func updateLocalPath(_ url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileLocalPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileLocalPath = url
            }
        }
    }
    open func updateThumbPath(_ url: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "fileId == %d", self.fileId)
        let fileData = realm.objects(QiscusFile.self).filter(searchQuery)
        
        if(fileData.count == 0){
            self.fileThumbPath = url
        }else{
            let file = fileData.first!
            try! realm.write{
                file.fileThumbPath = url
            }
        }
    }
    open func updateIsUploading(_ uploading: Bool){
        let realm = try! Realm()
        
        try! realm.write{
            self.isUploading = uploading
        }
    }
    open func updateIsDownloading(_ downloading: Bool){
        let realm = try! Realm()

        try! realm.write{
            self.isDownloading = downloading
        }
    }
    open func updateUploadProgress(_ progress: CGFloat){
        let realm = try! Realm()
        
        try! realm.write{
            self.uploadProgress = progress
        }
    }
    open func updateDownloadProgress(_ progress: CGFloat){
        let realm = try! Realm()
        
        try! realm.write{
            self.downloadProgress = progress
        }
    }
    // MARK: Additional Methode
    fileprivate func getExtension() -> String{
        var ext = ""
        if (self.fileName as String).range(of: ".") != nil{
            let fileNameArr = (self.fileName as String).characters.split(separator: ".")
            ext = String(fileNameArr.last!).lowercased()
        }
        return ext
    }
    fileprivate func getFileName() ->String{
        var mediaURL:URL?
        var fileName:String? = ""
        if(self.fileLocalPath == ""){
            mediaURL = URL(string: self.fileURL as String)!
            fileName = mediaURL!.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
        }else if(self.fileLocalPath as String).range(of: "/") == nil{
            fileName = self.fileLocalPath as String
        }else{
            let fileLastPath = String(self.fileLocalPath.characters.split(separator: "/").last!)
            fileName = fileLastPath.replacingOccurrences(of: " ", with: "_")
        }
        return fileName!
    }
    fileprivate func isPdfFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "pdf" || ext == "pdf_"){
            check = true
        }

        return check
    }
    fileprivate func isVideoFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "mov" || ext == "mov_" || ext == "mp4" || ext == "mp4_"){
            check = true
        }
        
        return check
    }
    fileprivate func isAudioFile() -> Bool {
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "m4a" || ext == "m4a_" || ext == "aac" || ext == "aac_" || ext == "mp3" || ext == "mp3_"){
            check = true
        }
        
        return check
    }
    fileprivate func isMediaFile() -> Bool{
        var check:Bool = false
        let ext = self.getExtension()
        
        if(ext == "jpg" || ext == "jpg_" || ext == "png" || ext == "png_" || ext == "gif" || ext == "gif_"){
            check = true
        }
        
        return check
    }
    
    // MARK: - image manipulation
    open func getLocalThumbImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileThumbPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    open func getLocalImage() -> UIImage{
        if let image = UIImage(contentsOfFile: (self.fileLocalPath as String)) {
            return image
        }else{
            return UIImage()
        }
    }
    open class func createThumbImage(_ image:UIImage, withMaskImage:UIImage? = nil, fillImageSize:UIImage? = nil)->UIImage{
        var inputImage = image
        if withMaskImage != nil {
            inputImage = QiscusAsyncImageView.maskImage(image, mask: withMaskImage!)
        }
        if fillImageSize == nil{
            var smallPart:CGFloat = inputImage.size.height
            
            if(inputImage.size.width > inputImage.size.height){
                smallPart = inputImage.size.width
            }
            let ratio:CGFloat = CGFloat(396.0/smallPart)
            let newSize = CGSize(width: (inputImage.size.width * ratio),height: (inputImage.size.height * ratio))
            
            UIGraphicsBeginImageContext(newSize)
            inputImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }else{
            let newImage = UIImage.resizeImage(inputImage, toFillOnImage: fillImageSize!)
            
            return newImage
        }
    }
    open class func saveFile(_ fileData: Data, fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = "\(documentsPath)/\(fileName)"
        
        try? fileData.write(to: URL(fileURLWithPath: path), options: [.atomic])
        
        return path
    }
    open func isLocalFileExist()->Bool{
        var check:Bool = false
        
        let checkValidation = FileManager.default
        
        if (self.fileLocalPath != "" && checkValidation.fileExists(atPath: self.fileLocalPath as String) && checkValidation.fileExists(atPath: self.fileThumbPath as String))
        {
            check = true
        }
        return check
    }
    
}
