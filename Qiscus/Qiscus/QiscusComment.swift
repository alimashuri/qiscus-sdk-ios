//
//  QiscusComment.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

public enum QiscusCommentType:Int {
    case Text
    case Attachment
}
public enum QiscusCommentStatus:Int{
    case Sending
    case Sent
    case Delivered
    case Failed
}

public class QiscusComment: Object {
    // MARK: - Dynamic Variable
    public dynamic var localId:Int = 0
    public dynamic var commentId:Int = Int.max
    public dynamic var commentText:String = ""
    public dynamic var commentCreatedAt: Double = 0
    public dynamic var commentUniqueId: String = ""
    public dynamic var commentTopicId:Int = 0
    public dynamic var commentSenderEmail:String = ""
    public dynamic var commentFileId:Int = 0
    public dynamic var commentStatusRaw:Int = QiscusCommentStatus.Sending.rawValue
    public dynamic var commentIsDeleted:Bool = false
    public dynamic var commentIsSynced:Bool = false
    public dynamic var commentBeforeId:Int = 0
    public dynamic var commentCellHeight:CGFloat = 0
        
    public var commentStatus:QiscusCommentStatus {
        get {
            return QiscusCommentStatus(rawValue: commentStatusRaw)!
        }
    }
    public var commentType: QiscusCommentType {
        get {
            var type = QiscusCommentType.Text
            if isFileMessage(){
                type = QiscusCommentType.Attachment
            }
            return type
        }
    }
    public var commentDate: String {
        get {
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            let dateString = dateFormatter.stringFromDate(date)
            
            return dateString
        }
    }
    public var commentTime: String {
        get {
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.stringFromDate(date)
            
            return timeString
        }
    }
    public var commentTime24: String {
        get {
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.stringFromDate(date)
            
            return timeString
        }
    }
    public var commentDay: String {
        get {
            let now = NSDate()
            
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let dayFormatter = NSDateFormatter()
            //dayFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dayFormatter.dateFormat = "EEEE"
            let dayString = dayFormatter.stringFromDate(date)
            let dayNow = dayFormatter.stringFromDate(now)
            if dayNow == dayString {
                return "Today"
            }else{
                return dayString
            }
        }
    }
    public var commentIsFile: Bool {
        get {
            return isFileMessage()
        }
    }
    

    // MARK: - Set Primary Key
    override public class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Getter Class Methode
    public class var LastId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusComment).sorted("localId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.localId
            } else {
                return 0
            }
        }
    }
    public class var LastCommentId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusComment).sorted("commentId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.commentId
            } else {
                return 0
            }
        }
    }
    public class func deleteAllFailedMessage(){ // USED
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentStatusRaw == %d", QiscusCommentStatus.Failed.rawValue)
        let RetNext = realm.objects(QiscusComment).filter(searchQuery)
        
        if RetNext.count > 0 {
            for failedComment in RetNext{
                try! realm.write {
                    realm.delete(failedComment)
                }
            }
        }
    }
    public class func deleteAllUnsendMessage(){
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentStatusRaw == %d", QiscusCommentStatus.Sending.rawValue)
        let RetNext = realm.objects(QiscusComment).filter(searchQuery)
        
        if RetNext.count > 0 {
            for sendingComment in RetNext{
                if let file = QiscusFile.getCommentFileWithComment(sendingComment){
                    if !file.fileLocalPath.isEqualToString("") && file.isLocalFileExist(){
                        let manager = NSFileManager.defaultManager()
                        try! manager.removeItemAtPath("\(file.fileLocalPath as String)")
                        try! manager.removeItemAtPath("\(file.fileThumbPath as String)")
                    }
                    try! realm.write {
                        realm.delete(file)
                    }
                }
                try! realm.write {
                    realm.delete(sendingComment)
                }
            }
        }
    }
    public class func lastCommentIdInTopic(topicId:Int)->Int{
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d", topicId)
        let RetNext = realm.objects(QiscusComment).filter(searchQuery).sorted("commentId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.commentId
        } else {
            return 0
        }
    }
    public func getMediaURL() -> String{
        let component1 = (self.commentText as String).componentsSeparatedByString("[file]")
        let component2 = component1.last!.componentsSeparatedByString("[/file]")
        let mediaUrlString = component2.first?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return mediaUrlString!
    }
    public class func getCommentByLocalId(localId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "localId == %d", localId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    public class func getCommentById(commentId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    public class func getAllComment(topicId: Int, limit:Int, firstLoad:Bool = false)->[QiscusComment]{ // USED
        if firstLoad {
            QiscusComment.deleteAllFailedMessage()
        }
        var allComment = [QiscusComment]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt", ascending: false), SortDescriptor(property: "commentId", ascending: false)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted(sortProperties)
        
        var needSync = false
        
        if(commentData.count > 0){
            var i:Int = 0
            dataLoop: for comment in commentData{
                if !comment.commentIsSynced {
                    needSync = true
                }
                if(i >= limit){
                    break dataLoop
                }else{
                    allComment.insert(comment, atIndex: 0)
                }
                i += 1
            }
        }
        if needSync {
            QiscusCommentClient.sharedInstance.syncMessage(topicId)
        }
        print("OK from getAllComment")
        return allComment
    }
    public class func getAllComment(topicId: Int)->[QiscusComment]{
        var allComment = [QiscusComment]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt"), SortDescriptor(property: "commentId", ascending: true)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted(sortProperties)
        
        if(commentData.count > 0){
            for comment in commentData{
                allComment.append(comment)
            }
        }
        return allComment
    }
    public class func groupAllCommentByDate(topicId: Int,limit:Int, firstLoad:Bool = false)->[[QiscusComment]]{ //USED
        var allComment = [[QiscusComment]]()
        let commentData = QiscusComment.getAllComment(topicId, limit: limit)
        
        if(commentData.count > 0){
            var firstCommentInGroup = commentData.first!
            var grouppedMessage = [QiscusComment]()
            var i:Int = 1
            for comment in commentData{
                if(comment.commentDate == firstCommentInGroup.commentDate){
                    grouppedMessage.append(comment)
                }else{
                    allComment.append(grouppedMessage)
                    grouppedMessage = [QiscusComment]()
                    firstCommentInGroup = comment
                    grouppedMessage.append(comment)
                }
                if( i == commentData.count){
                    allComment.append(grouppedMessage)
                }
                i += 1
            }
        }
        return allComment
    }
    public class func groupAllCommentByDate(topicId: Int)->[[QiscusComment]]{
        var allComment = [[QiscusComment]]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt"), SortDescriptor(property: "commentId", ascending: true)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted(sortProperties)
        
        if(commentData.count > 0){
            var firstCommentInGroup = commentData.first!
            var grouppedMessage = [QiscusComment]()
            var i:Int = 1
            for comment in commentData{
                if(comment.commentDate == firstCommentInGroup.commentDate){
                    grouppedMessage.append(comment)
                }else{
                    allComment.append(grouppedMessage)
                    grouppedMessage = [QiscusComment]()
                    firstCommentInGroup = comment
                    grouppedMessage.append(comment)
                }
                if( i == commentData.count){
                    allComment.append(grouppedMessage)
                }
                i += 1
            }
        }
        return allComment
    }
    public class func lastUnsyncCommentId(topicId:Int)->Int{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "(commentIsSynced == false AND commentTopicId == %d) OR commentStatusRaw < %d",topicId,QiscusCommentStatus.Delivered.rawValue)
        let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted("commentCreatedAt")
        
        if commentData.count > 0{
            let firstData = commentData.first!
            return firstData.commentId
        }else{
            return 0
        }
    }
    public func updateCommentCellHeight(newHeight:CGFloat){
        let realm = try! Realm()
        try! realm.write {
            self.commentCellHeight = newHeight
        }
    }
    public class func getLastSyncCommentId(topicId:Int)->Int{
        if QiscusComment.isUnsyncMessageExist(topicId) {
            var lastSyncCommentId:Int = QiscusComment.LastCommentId
            
            let realm = try! Realm()
            let searchQuery = NSPredicate(format: "commentIsSynced == true AND commentId < %d AND commentStatusRaw == %d",QiscusComment.lastUnsyncCommentId(topicId),QiscusCommentStatus.Delivered.rawValue)
            let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted("commentId")
            
            if commentData.count > 0{
                lastSyncCommentId = commentData.first!.commentId
            }
            return lastSyncCommentId
        }else{
            return QiscusComment.LastCommentId
        }
    }
    public class func countCommentOntTopic(topicId:Int)->Int{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d", topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        return commentData.count
    }
    // MARK: - getComment from JSON
    public class func getCommentTopicIdFromJSON(data: JSON) -> Int{
        return data["topic_id"].intValue
    }
    public class func getCommentIdFromJSON(data: JSON) -> Int{
        var commentId:Int = 0

        if let id = data["id"].int{
            commentId = id
        }else if let id = data["comment_id"].int{
            commentId = id
        }
        return commentId
    }
    public class func getCommentBeforeIdFromJSON(data: JSON) -> Int{
        return data["comment_before_id"].intValue
    }
    public class func getSenderFromJSON(data: JSON) -> String{
        return data["username_real"].stringValue
    }
    public class func getCommentFromJSON(data: JSON) -> Bool{
        let comment = QiscusComment()
        comment.commentTopicId = data["topic_id"].intValue
        comment.commentSenderEmail = data["username_real"].stringValue
        comment.commentStatusRaw = QiscusCommentStatus.Delivered.rawValue
        comment.commentBeforeId = data["comment_before_id"].intValue
        var created_at:String = ""
        var usernameAs:String = ""
        if(data["message"] != nil){
            comment.commentText = data["message"].stringValue
            comment.commentId = data["id"].intValue
            usernameAs = data["username_as"].stringValue
            comment.commentIsDeleted = data["deleted"].boolValue
            created_at = data["created_at"].stringValue
        }else{
            comment.commentText = data["comment"].stringValue
            comment.commentId = data["comment_id"].intValue
            usernameAs = data["username"].stringValue
            if let uniqueId = data["unique_id"].string {
                comment.commentUniqueId = uniqueId
            }else if let randomme = data["randomme"].string {
                comment.commentUniqueId = randomme
            }
            created_at = data["created_at_ios"].stringValue
        }
        if let sender = QiscusUser().getUserWithEmail(comment.commentSenderEmail as String){
            sender.usernameAs(usernameAs)
        }
        let rawDateFormatter = NSDateFormatter()
        rawDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        rawDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let chatDate = rawDateFormatter.dateFromString("\(created_at as String) +0000")
        
        if chatDate != nil{
            let timetoken = Double(chatDate!.timeIntervalSince1970)
            comment.commentCreatedAt = timetoken
        }
        comment.commentStatusRaw = QiscusCommentStatus.Delivered.rawValue
        let saved = comment.saveComment(true)
        return saved
    }
    
    
    public class func getCommentFromJSON(data: JSON, topicId:Int, saved:Bool) -> Bool{ // USED
        let comment = QiscusComment()
        comment.commentTopicId = topicId
        comment.commentSenderEmail = data["username_real"].stringValue
        comment.commentStatusRaw = QiscusCommentStatus.Delivered.rawValue
        comment.commentBeforeId = data["comment_before_id"].intValue
        var created_at:String = ""
        var usernameAs:String = ""
        if(data["message"] != nil){
            comment.commentText = data["message"].stringValue
            comment.commentId = data["id"].intValue
            usernameAs = data["username_as"].stringValue
            comment.commentIsDeleted = data["deleted"].boolValue
            created_at = data["created_at"].stringValue
        }else{
            comment.commentText = data["comment"].stringValue
            comment.commentId = data["comment_id"].intValue
            usernameAs = data["username"].stringValue
            if let uniqueId = data["unique_id"].string {
                comment.commentUniqueId = uniqueId
            }else if let randomme = data["randomme"].string {
                comment.commentUniqueId = randomme
            }
            created_at = data["created_at_ios"].stringValue
        }
        if let sender = QiscusUser().getUserWithEmail(comment.commentSenderEmail as String){
            sender.usernameAs(usernameAs)
        }
        let rawDateFormatter = NSDateFormatter()
        rawDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        rawDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let chatDate = rawDateFormatter.dateFromString("\(created_at as String) +0000")
        
        if chatDate != nil{
            let timetoken = Double(chatDate!.timeIntervalSince1970)
            comment.commentCreatedAt = timetoken
        }
        comment.commentIsSynced = true
        let isSaved = comment.saveComment(true)
        return isSaved
    }
    
    // MARK: - Updater Methode
    public func updateCommentId(commentId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            self.commentId = commentId
        }else{
            try! realm.write {
                self.commentId = commentId
            }
        }
    }
    public func updateCommentIsSync(sync: Bool){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d", self.commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            self.commentIsSynced = sync
        }else{
            try! realm.write {
                self.commentIsSynced = sync
            }
        }
    }
    public func updateCommentStatus(status: QiscusCommentStatus){
        if(self.commentStatusRaw < status.rawValue){
            let realm = try! Realm()
            
            let searchQuery:NSPredicate = NSPredicate(format: "commentId <= %d AND commentTopicId == %d", self.commentId,self.commentTopicId)
            let commentData = realm.objects(QiscusComment).filter(searchQuery)
            
            if(commentData.count == 0){
                self.commentStatusRaw = status.rawValue
            }else{
                for comment in commentData{
                    try! realm.write {
                        comment.commentStatusRaw = status.rawValue
                    }
                }
            }
        }
    }
    public func updateCommentFileId(fileId:Int){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment).filter(searchQuery!)
        
        if commentData.count == 0 {
            self.commentFileId = fileId
        }else{
            try! realm.write {
                self.commentFileId = fileId
            }
        }
    }

    public func updateCommentText(text:String){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment).filter(searchQuery!)
        
        if commentData.count == 0 {
            self.commentText = text
        }else{
            try! realm.write {
                self.commentText = text
            }
        }
    }
    // Create New Comment
    public class func newCommentWithMessage(message message:String, inTopicId:Int)->QiscusComment{
        let comment = QiscusComment()
        let time = Double(NSDate().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let uniqueID = "ios-\(timeToken)"
        let config = QiscusConfig.sharedInstance
        comment.localId = QiscusComment.LastId + 1
        comment.commentText = message
        comment.commentCreatedAt = Double(NSDate().timeIntervalSince1970)
        comment.commentUniqueId = uniqueID
        comment.commentTopicId = inTopicId
        comment.commentSenderEmail = config.USER_EMAIL
        comment.commentStatusRaw = QiscusCommentStatus.Sending.rawValue
        comment.commentIsSynced = false
        
        comment.saveComment()
        return comment
    }
    
    // MARK: - Save and Delete Comment
    public class func deleteFailedComment(topicId:Int){
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentStatusRaw == %d AND commentTopicId == %d", QiscusCommentStatus.Failed.rawValue,topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0 {
            for comment in commentData{
                try! realm.write {
                    realm.delete(comment)
                }
            }
        }
    }
    public class func deleteUnsendComment(topicId:Int){
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "(commentStatusRaw == %d || commentStatusRaw == %d) AND commentTopicId == %d", QiscusCommentStatus.Sending.rawValue,QiscusCommentStatus.Failed.rawValue,topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0 {
            for comment in commentData{
                try! realm.write {
                    realm.delete(comment)
                }
            }
        }
    }
    public func saveComment(saved:Bool)->Bool{
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        searchQuery = NSPredicate(format: "(commentId == %d AND commentId != %d) OR (commentUniqueId == %@ && commentUniqueId != %@)", self.commentId,0, self.commentUniqueId,"")

        let commentData = realm.objects(QiscusComment).filter(searchQuery!)
        
        if(self.localId == 0){
            self.localId = QiscusComment.LastId + 1
        }
        if(commentData.count == 0){
            if self.commentIsFile{
                let fileURL = self.getMediaURL()
                var file = QiscusFile.getCommentFileWithURL(fileURL)
                
                if(file == nil){
                    file = QiscusFile()
                }
                file?.updateURL(fileURL)
                file?.updateCommentId(self.commentId)
                file?.saveCommentFile()
                
                file = QiscusFile.getCommentFileWithComment(self)
                self.commentFileId = file!.fileId
            }
            try! realm.write {
                realm.add(self)
            }
            return true
        }else{
            let comment = commentData.first!
            try! realm.write {
                comment.commentId = self.commentId
                comment.commentText = self.commentText
                if(self.commentCreatedAt > 0){
                    comment.commentCreatedAt = self.commentCreatedAt
                }
                
                comment.commentTopicId = self.commentTopicId
                comment.commentSenderEmail = self.commentSenderEmail
                if self.commentFileId > 0 {
                    comment.commentFileId = self.commentFileId
                }
                if(comment.commentStatusRaw < self.commentStatusRaw){
                    comment.commentStatusRaw = self.commentStatusRaw
                }
                if self.commentIsSynced{
                    comment.commentIsSynced = true
                }
                comment.commentIsDeleted = self.commentIsDeleted
            }
            return false
        }
    }
    public func saveComment()->QiscusComment{
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment).filter(searchQuery!)
        
        if(self.localId == 0){
            self.localId = QiscusComment.LastId + 1
        }
        if(commentData.count == 0){
            if self.commentIsFile{
                let fileURL = self.getMediaURL()
                var file = QiscusFile.getCommentFileWithURL(fileURL)
                
                if(file == nil){
                    file = QiscusFile()
                }
                file?.updateURL(fileURL)
                file?.updateCommentId(self.commentId)
                file?.saveCommentFile()
                
                file = QiscusFile.getCommentFileWithComment(self)
                self.commentFileId = file!.fileId
            }
            try! realm.write {
                realm.add(self)
            }
            return self
        }else{
            let comment = commentData.first!
            try! realm.write {
                comment.commentId = self.commentId
                comment.commentText = self.commentText
                if(self.commentCreatedAt > 0){
                    comment.commentCreatedAt = self.commentCreatedAt
                }

                comment.commentTopicId = self.commentTopicId
                comment.commentSenderEmail = self.commentSenderEmail
                if self.commentFileId > 0 {
                    comment.commentFileId = self.commentFileId
                }
                if(comment.commentStatusRaw < self.commentStatusRaw){
                    comment.commentStatusRaw = self.commentStatusRaw
                }
                if self.commentIsSynced{
                    comment.commentIsSynced = true
                }
                comment.commentIsDeleted = self.commentIsDeleted
            }
            return comment
        }
    }
    
    // MARK: - Checking Methode
    public func isFileMessage() -> Bool{
        var check:Bool = false
        if((self.commentText as String).hasPrefix("[file]")){
            check = true
        }
        return check
    }
    public class func isCommentExist(comment:QiscusComment)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", comment.commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    public class func isCommentIdExist(commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    public class func isValidCommentIdExist(commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d AND commentIsSynced == true AND commentStatusRaw == %d", commentId,QiscusCommentStatus.Delivered.rawValue)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    public class func isUnsyncMessageExist(topicId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "(commentIsSynced == false AND commentTopicId == %d) OR commentStatusRaw < %d",topicId,QiscusCommentStatus.Delivered.rawValue)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
}
