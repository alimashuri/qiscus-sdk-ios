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

enum QiscusCommentType:Int {
    case Text
    case Attachment
}
enum QiscusCommentStatus:Int{
    case Sending
    case Sent
    case Delivered
    case Failed
}

public class QiscusComment: Object {
    // MARK: - Dynamic Variable
    dynamic var localId:Int = 0
    dynamic var commentId:Int = 0
    dynamic var commentText:NSString = ""
    dynamic var commentCreatedAt: Double = 0
    dynamic var commentUniqueId: NSString = ""
    dynamic var commentTopicId:Int = 0
    dynamic var commentSenderEmail:NSString = ""
    dynamic var commentFileId:Int = 0
    dynamic var commentStatusRaw:Int = QiscusCommentStatus.Sending.rawValue
    dynamic var commentIsDeleted:Bool = false
    dynamic var commentIsSynced:Bool = false
    dynamic var commentBeforeId:Int = 0
    dynamic var commentCellHeight:CGFloat = 0
        
    var commentStatus:QiscusCommentStatus {
        get {
            return QiscusCommentStatus(rawValue: commentStatusRaw)!
        }
    }
    var commentType: QiscusCommentType {
        get {
            var type = QiscusCommentType.Text
            if isFileMessage(){
                type = QiscusCommentType.Attachment
            }
            return type
        }
    }
    var commentDate: String {
        get {
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.dateFormat = "d MMMM yyyy"
            let dateString = dateFormatter.stringFromDate(date)
            
            return dateString
        }
    }
    var commentTime: String {
        get {
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let timeFormatter = NSDateFormatter()
            timeFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.stringFromDate(date)
            
            return timeString
        }
    }
    var commentDay: String {
        get {
            let now = NSDate()
            
            let date = NSDate(timeIntervalSince1970: commentCreatedAt)
            let dayFormatter = NSDateFormatter()
            dayFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
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
    var commentIsFile: Bool {
        get {
            return isFileMessage()
        }
    }
    

    // MARK: - Set Primary Key
    override public class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Getter Class Methode
    class var LastId:Int{
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
    class var LastCommentId:Int{
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
    class func deleteAllFailedMessage(){
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
    class func deleteAllUnsendMessage(){
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
    class func lastCommentIdInTopic(topicId:Int)->Int{
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
    func getMediaURL() -> String{
        let component1 = (self.commentText as String).componentsSeparatedByString("[file]")
        let component2 = component1.last!.componentsSeparatedByString("[/file]")
        let mediaUrlString = component2.first?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return mediaUrlString!
    }
    class func getCommentByLocalId(localId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "localId == %d", localId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    class func getCommentById(commentId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    class func getAllComment(topicId: Int, limit:Int)->[QiscusComment]{
        QiscusComment.deleteAllFailedMessage()
        var allComment = [QiscusComment]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt", ascending: false), SortDescriptor(property: "commentId", ascending: false)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery).sorted(sortProperties)
        
        if(commentData.count > 0){
            var i:Int = 0
            dataLoop: for comment in commentData{
                if(i >= limit){
                    break dataLoop
                }else{
                    allComment.insert(comment, atIndex: 0)
                }
                i += 1
            }
        }
        return allComment
    }
    class func getAllComment(topicId: Int)->[QiscusComment]{
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
    class func groupAllCommentByDate(topicId: Int,limit:Int)->[[QiscusComment]]{
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
    class func groupAllCommentByDate(topicId: Int)->[[QiscusComment]]{
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
    class func lastUnsyncCommentId(topicId:Int)->Int{
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
    func updateCommentCellHeight(newHeight:CGFloat){
        let realm = try! Realm()
        try! realm.write {
            self.commentCellHeight = newHeight
        }
    }
    class func getLastSyncCommentId(topicId:Int)->Int{
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
    class func countCommentOntTopic(topicId:Int)->Int{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d", topicId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        return commentData.count
    }
    // MARK: - getComment from JSON
    class func getCommentTopicIdFromJSON(data: JSON) -> Int{
        return data["topic_id"].intValue
    }
    class func getCommentIdFromJSON(data: JSON) -> Int{
        var commentId:Int = 0

        if let id = data["id"].int{
            commentId = id
        }else if let id = data["comment_id"].int{
            commentId = id
        }
        return commentId
    }
    class func getCommentBeforeIdFromJSON(data: JSON) -> Int{
        return data["comment_before_id"].intValue
    }
    class func getSenderFromJSON(data: JSON) -> String{
        return data["username_real"].stringValue
    }
    class func getCommentFromJSON(data: JSON) -> Bool{
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
    
    
    class func getCommentFromJSON(data: JSON, topicId:Int, saved:Bool) -> Bool{
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
    func updateCommentId(commentId:Int){
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
    func updateCommentIsSync(sync: Bool){
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
    func updateCommentStatus(status: QiscusCommentStatus){
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
    func updateCommentFileId(fileId:Int){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(!self.commentUniqueId.isEqualToString("")){
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

    func updateCommentText(text:NSString){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(!self.commentUniqueId.isEqualToString("")){
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
    func newCommentWithMessage(text:NSString, inTopicId:Int)->QiscusComment{
        let comment = QiscusComment()
        let time = Double(NSDate().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let uniqueID = "ldios-\(timeToken)"
        let config = QiscusConfig.sharedInstance
        comment.localId = QiscusComment.LastId + 1
        comment.commentText = text
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
    class func deleteFailedComment(topicId:Int){
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
    class func deleteUnsendComment(topicId:Int){
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
    func saveComment(saved:Bool)->Bool{
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
    func saveComment()->QiscusComment{
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(!self.commentUniqueId.isEqualToString("")){
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
    func isFileMessage() -> Bool{
        var check:Bool = false
        if((self.commentText as String).hasPrefix("[file]")){
            check = true
        }
        return check
    }
    class func isCommentExist(comment:QiscusComment)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", comment.commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    class func isCommentIdExist(commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    class func isValidCommentIdExist(commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d AND commentIsSynced == true AND commentStatusRaw == %d", commentId,QiscusCommentStatus.Delivered.rawValue)
        let commentData = realm.objects(QiscusComment).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    class func isUnsyncMessageExist(topicId:Int)->Bool{
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
