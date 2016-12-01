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
    case text
    case attachment
}
public enum QiscusCommentStatus:Int{
    case sending
    case sent
    case delivered
    case failed
}

open class QiscusComment: Object {
    // MARK: - Dynamic Variable
    open dynamic var localId:Int = 0
    open dynamic var commentId:Int = Int.max
    open dynamic var commentText:String = ""
    open dynamic var commentCreatedAt: Double = 0
    open dynamic var commentUniqueId: String = ""
    open dynamic var commentTopicId:Int = 0
    open dynamic var commentSenderEmail:String = ""
    open dynamic var commentFileId:Int = 0
    open dynamic var commentStatusRaw:Int = QiscusCommentStatus.sending.rawValue
    open dynamic var commentIsDeleted:Bool = false
    open dynamic var commentIsSynced:Bool = false
    open dynamic var commentBeforeId:Int = 0
    open dynamic var commentCellHeight:CGFloat = 0
    
    
    open var roomId:Int{
        get{
            var roomId:Int = 0
            if let room = QiscusRoom.getRoom(withLastTopicId: self.commentTopicId){
                roomId = room.roomId
            }
            return roomId
        }
    }
    open var commentStatus:QiscusCommentStatus {
        get {
            return QiscusCommentStatus(rawValue: commentStatusRaw)!
        }
    }
    open var commentType: QiscusCommentType {
        get {
            var type = QiscusCommentType.text
            if isFileMessage(){
                type = QiscusCommentType.attachment
            }
            return type
        }
    }
    open var commentDate: String {
        get {
            let date = Date(timeIntervalSince1970: commentCreatedAt)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            let dateString = dateFormatter.string(from: date)
            
            return dateString
        }
    }
    open var commentTime: String {
        get {
            let date = Date(timeIntervalSince1970: commentCreatedAt)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: date)
            
            return timeString
        }
    }
    open var commentTime24: String {
        get {
            let date = Date(timeIntervalSince1970: commentCreatedAt)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: date)
            
            return timeString
        }
    }
    open var commentDay: String {
        get {
            let now = Date()
            
            let date = Date(timeIntervalSince1970: commentCreatedAt)
            let dayFormatter = DateFormatter()
            //dayFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dayFormatter.dateFormat = "EEEE"
            let dayString = dayFormatter.string(from: date)
            let dayNow = dayFormatter.string(from: now)
            if dayNow == dayString {
                return "Today"
            }else{
                return dayString
            }
        }
    }
    open var commentIsFile: Bool {
        get {
            return isFileMessage()
        }
    }
    

    // MARK: - Set Primary Key
    override open class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Getter Class Methode
    open class var LastId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusComment.self).sorted(byProperty: "localId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.localId
            } else {
                return 0
            }
        }
    }
    open class var LastCommentId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusComment.self).sorted(byProperty: "commentId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.commentId
            } else {
                return 0
            }
        }
    }
    open class func deleteAllFailedMessage(){ // USED
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentStatusRaw == %d", QiscusCommentStatus.failed.rawValue)
        let RetNext = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if RetNext.count > 0 {
            for failedComment in RetNext{
                try! realm.write {
                    realm.delete(failedComment)
                }
            }
        }
    }
    open class func deleteAllUnsendMessage(){
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentStatusRaw == %d", QiscusCommentStatus.sending.rawValue)
        let RetNext = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if RetNext.count > 0 {
            for sendingComment in RetNext{
                if let file = QiscusFile.getCommentFileWithComment(sendingComment){
                    if file.fileLocalPath != "" && file.isLocalFileExist(){
                        let manager = FileManager.default
                        try! manager.removeItem(atPath: "\(file.fileLocalPath as String)")
                        try! manager.removeItem(atPath: "\(file.fileThumbPath as String)")
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
    open class func lastCommentIdInTopic(_ topicId:Int)->Int{
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d", topicId)
        let RetNext = realm.objects(QiscusComment.self).filter(searchQuery).sorted(byProperty: "commentId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.commentId
        } else {
            return 0
        }
    }
    open func getMediaURL() -> String{
        let component1 = (self.commentText as String).components(separatedBy: "[file]")
        let component2 = component1.last!.components(separatedBy: "[/file]")
        let mediaUrlString = component2.first?.trimmingCharacters(in: CharacterSet.whitespaces)
        return mediaUrlString!
    }
    open class func getCommentByLocalId(_ localId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "localId == %d", localId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    open class func getCommentById(_ commentId: Int)->QiscusComment?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if(commentData.count == 0){
            return nil
        }else{
            return commentData.first
        }
    }
    open class func getAllComment(_ topicId: Int, limit:Int, firstLoad:Bool = false)->[QiscusComment]{ // USED
        if firstLoad {
            QiscusComment.deleteAllFailedMessage()
        }
        var allComment = [QiscusComment]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt", ascending: false), SortDescriptor(property: "commentId", ascending: false)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(by: sortProperties)
        
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
                    allComment.insert(comment, at: 0)
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
    open class func getAllComment(_ topicId: Int)->[QiscusComment]{
        var allComment = [QiscusComment]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt"), SortDescriptor(property: "commentId", ascending: true)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(by: sortProperties)
        
        if(commentData.count > 0){
            for comment in commentData{
                allComment.append(comment)
            }
        }
        return allComment
    }
    open class func groupAllCommentByDate(_ topicId: Int,limit:Int, firstLoad:Bool = false)->[[QiscusComment]]{ //USED
        var allComment = [[QiscusComment]]()
        let commentData = QiscusComment.getAllComment(topicId, limit: limit, firstLoad: firstLoad)
        
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
    open class func groupAllCommentByDate(_ topicId: Int)->[[QiscusComment]]{
        var allComment = [[QiscusComment]]()
        let realm = try! Realm()
        
        let sortProperties = [SortDescriptor(property: "commentCreatedAt"), SortDescriptor(property: "commentId", ascending: true)]
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(by: sortProperties)
        
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
    open class func firstUnsyncCommentId(_ topicId:Int)->Int{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentIsSynced == false AND commentTopicId == %d AND (commentStatusRaw == %d OR commentStatusRaw == %d)",topicId,QiscusCommentStatus.sent.rawValue,QiscusCommentStatus.delivered.rawValue)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(byProperty: "commentCreatedAt")
        
        if commentData.count > 0{
            let firstData = commentData.first!
            return firstData.commentId
        }else{
            return 0
        }
    }
    open func updateCommentCellHeight(_ newHeight:CGFloat){
        let realm = try! Realm()
        try! realm.write {
            self.commentCellHeight = newHeight
        }
    }
    open class func getLastSyncCommentId(_ topicId:Int)->Int?{ //USED
        if QiscusComment.isUnsyncMessageExist(topicId) {
            var lastSyncCommentId:Int?
            
            let realm = try! Realm()
            let searchQuery = NSPredicate(format: "commentIsSynced == true AND commentTopicId == %d AND (commentStatusRaw == %d OR commentStatusRaw == %d) AND commentId < %d",topicId,QiscusCommentStatus.sent.rawValue,QiscusCommentStatus.delivered.rawValue,QiscusComment.firstUnsyncCommentId(topicId))
            let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(byProperty: "commentCreatedAt")
            
            if commentData.count > 0{
                lastSyncCommentId = commentData.last!.commentId
            }else{
                lastSyncCommentId = QiscusComment.lastCommentIdInTopic(topicId)
            }
            return lastSyncCommentId
        }else{
            return QiscusComment.lastCommentIdInTopic(topicId)
        }
    }
    open class func countCommentOntTopic(_ topicId:Int)->Int{ // USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentTopicId == %d", topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        return commentData.count
    }
    // MARK: - getComment from JSON
    open class func getCommentTopicIdFromJSON(_ data: JSON) -> Int{ //USED
        return data["topic_id"].intValue
    }
    open class func getCommentIdFromJSON(_ data: JSON) -> Int{ // USED
        var commentId:Int = 0

        if let id = data["id"].int{
            commentId = id
        }else if let id = data["comment_id"].int{
            commentId = id
        }
        return commentId
    }
    open class func getComment(fromRealtimeJSON data:JSON)->QiscusComment{
        /*
        {
            "user_avatar" : "https:\/\/qiscuss3.s3.amazonaws.com\/uploads\/2843d09883c80473ff84a5cc4922f561\/qiscus-dp.png",
            "unique_temp_id" : "ios-14805592733157",
            "topic_id" : 407,
            "created_at" : "2016-12-01T02:27:54.930Z",
            "room_name" : "ee",
            "username" : "ee",
            "message" : "dddd",
            "email" : "e3@qiscus.com",
            "comment_before_id" : 13764,
            "room_id" : 427,
            "timestamp" : "2016-12-01T02:27:54Z",
            "id" : 13765,
            "chat_type" : "single"
        }
        */
        let comment = QiscusComment()
        comment.commentTopicId = data["topic_id"].intValue
        comment.commentSenderEmail = data["email"].stringValue
        comment.commentStatusRaw = QiscusCommentStatus.delivered.rawValue
        comment.commentBeforeId = data["comment_before_id"].intValue
        comment.commentText = data["message"].stringValue
        comment.commentId = data["id"].intValue
        comment.commentUniqueId = data["unique_temp_id"].stringValue
        
        if let sender = QiscusUser.getUserWithEmail(comment.commentSenderEmail as String){
            sender.usernameAs(data["username"].stringValue)
        }
        let isSaved = comment.saveComment(true)
        if isSaved{
            print("[Qiscus] New comment saved")
        }
        return comment
    }
    open class func getCommentBeforeIdFromJSON(_ data: JSON) -> Int{//USED
        return data["comment_before_id"].intValue
    }
    open class func getSenderFromJSON(_ data: JSON) -> String{
        return data["username_real"].stringValue
    }
    open class func getCommentFromJSON(_ data: JSON) -> Bool{
        let comment = QiscusComment()
        comment.commentTopicId = data["topic_id"].intValue
        comment.commentSenderEmail = data["username_real"].stringValue
        comment.commentStatusRaw = QiscusCommentStatus.delivered.rawValue
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
            comment.commentId = data["id"].intValue
            usernameAs = data["username"].stringValue
            if let uniqueId = data["unique_temp_id"].string {
                comment.commentUniqueId = uniqueId
            }else if let randomme = data["randomme"].string {
                comment.commentUniqueId = randomme
            }
            created_at = data["created_at_ios"].stringValue
        }
        if let sender = QiscusUser.getUserWithEmail(comment.commentSenderEmail as String){
            sender.usernameAs(usernameAs)
        }
        let rawDateFormatter = DateFormatter()
        rawDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let chatDate = rawDateFormatter.date(from: "\(created_at as String) +0000")
        
        if chatDate != nil{
            let timetoken = Double(chatDate!.timeIntervalSince1970)
            comment.commentCreatedAt = timetoken
        }
        comment.commentStatusRaw = QiscusCommentStatus.delivered.rawValue
        let saved = comment.saveComment(true)
        return saved
    }
    
    
    open class func getCommentFromJSON(_ data: JSON, topicId:Int, saved:Bool) -> Bool{ // USED
        let comment = QiscusComment()
        print("getCommentFromJSON: \(data)")
        comment.commentTopicId = topicId
        comment.commentSenderEmail = data["email"].stringValue
        comment.commentStatusRaw = QiscusCommentStatus.delivered.rawValue
        comment.commentBeforeId = data["comment_before_id"].intValue
        var created_at:String = ""
        var usernameAs:String = ""
        if(data["message"] != nil){
            comment.commentText = data["message"].stringValue
            comment.commentId = data["id"].intValue
            usernameAs = data["username"].stringValue
            comment.commentIsDeleted = data["deleted"].boolValue
            created_at = data["timestamp"].stringValue
            if let uniqueId = data["unique_temp_id"].string {
                comment.commentUniqueId = uniqueId
            }else if let randomme = data["randomme"].string {
                comment.commentUniqueId = randomme
            }
        }else{
            comment.commentText = data["comment"].stringValue
            comment.commentId = data["id"].intValue
            usernameAs = data["username"].stringValue
            if let uniqueId = data["unique_temp_id"].string {
                comment.commentUniqueId = uniqueId
            }else if let randomme = data["randomme"].string {
                comment.commentUniqueId = randomme
            }
            created_at = data["timestamp"].stringValue
        }
        if let sender = QiscusUser.getUserWithEmail(comment.commentSenderEmail as String){
            sender.usernameAs(usernameAs)
        }
        let dateTimeArr = created_at.characters.split(separator: "T")
        let dateString = String(dateTimeArr.first!)
        let timeArr = String(dateTimeArr.last!).characters.split(separator: "Z")
        let timeString = String(timeArr.first!)
        let dateTimeString = "\(dateString) \(timeString) +0000"
        print("dateTimeString: \(dateTimeString)")
        print("commentid: \(comment.commentId)")
        
        let rawDateFormatter = DateFormatter()
        rawDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let chatDate = rawDateFormatter.date(from: dateTimeString)
        
        if chatDate != nil{
            let timetoken = Double(chatDate!.timeIntervalSince1970)
            comment.commentCreatedAt = timetoken
        }
        if QiscusComment.isValidCommentIdExist(comment.commentBeforeId) || QiscusComment.countCommentOntTopic(topicId) == 0{
            comment.commentIsSynced = true
        }
        let isSaved = comment.saveComment(true)
        return isSaved
    }
    
    // MARK: - Updater Methode
    open func updateCommentId(_ commentId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if(commentData.count > 0){
            try! realm.write {
                self.commentId = commentId
            }
        }
    }
    open func updateCommentIsSync(_ sync: Bool){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d", self.commentId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if(commentData.count == 0){
            self.commentIsSynced = sync
        }else{
            try! realm.write {
                self.commentIsSynced = sync
            }
        }
    }
    open func updateCommentStatus(_ status: QiscusCommentStatus){
        if(self.commentStatusRaw < status.rawValue){
            let realm = try! Realm()
            
            let searchQuery:NSPredicate = NSPredicate(format: "commentId == %d AND commentTopicId == %d", self.commentId,self.commentTopicId)
            let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
            
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
    open func updateCommentFileId(_ fileId:Int){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery!)
        
        if commentData.count == 0 {
            self.commentFileId = fileId
        }else{
            try! realm.write {
                self.commentFileId = fileId
            }
        }
    }

    open func updateCommentText(_ text:String){
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery!)
        
        if commentData.count == 0 {
            self.commentText = text
        }else{
            try! realm.write {
                self.commentText = text
            }
        }
    }
    // Create New Comment
    open class func newCommentWithMessage(message:String, inTopicId:Int)->QiscusComment{
        let comment = QiscusComment()
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let uniqueID = "ios-\(timeToken)"
        let config = QiscusConfig.sharedInstance
        comment.localId = QiscusComment.LastId + 1
        comment.commentText = message
        comment.commentCreatedAt = Double(Date().timeIntervalSince1970)
        comment.commentUniqueId = uniqueID
        comment.commentTopicId = inTopicId
        comment.commentSenderEmail = config.USER_EMAIL
        comment.commentStatusRaw = QiscusCommentStatus.sending.rawValue
        comment.commentIsSynced = false
        
        return comment.saveComment()
    }
    
    // MARK: - Save and Delete Comment
    open class func deleteFailedComment(_ topicId:Int){
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentStatusRaw == %d AND commentTopicId == %d", QiscusCommentStatus.failed.rawValue,topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0 {
            for comment in commentData{
                try! realm.write {
                    realm.delete(comment)
                }
            }
        }
    }
    open class func deleteUnsendComment(_ topicId:Int){
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "(commentStatusRaw == %d || commentStatusRaw == %d) AND commentTopicId == %d", QiscusCommentStatus.sending.rawValue,QiscusCommentStatus.failed.rawValue,topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0 {
            for comment in commentData{
                try! realm.write {
                    realm.delete(comment)
                }
            }
        }
    }
    open func saveComment(_ saved:Bool)->Bool{ // USED
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        searchQuery = NSPredicate(format: "(commentId == %d AND commentId != %d) OR (commentUniqueId == %@ && commentUniqueId != %@)", self.commentId,Int.max, self.commentUniqueId,"")

        let commentData = realm.objects(QiscusComment.self).filter(searchQuery!)
        
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
    open func saveComment()->QiscusComment{
        let realm = try! Realm()
        let searchQuery:NSPredicate?
        
        if(self.commentUniqueId != ""){
            searchQuery = NSPredicate(format: "commentUniqueId == %@ && commentUniqueId != %@", self.commentUniqueId,"")
        }else{
            searchQuery = NSPredicate(format: "commentId == %d", self.commentId)
        }
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery!)
        
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
    open func isFileMessage() -> Bool{
        var check:Bool = false
        if((self.commentText as String).hasPrefix("[file]")){
            check = true
        }
        return check
    }
    open class func isCommentExist(_ comment:QiscusComment)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", comment.commentId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    open class func isCommentIdExist(_ commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d", commentId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    open class func isValidCommentIdExist(_ commentId:Int)->Bool{
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId == %d AND commentIsSynced == true AND commentStatusRaw == %d", commentId,QiscusCommentStatus.delivered.rawValue)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    open class func isUnsyncMessageExist(_ topicId:Int)->Bool{ // USED
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentIsSynced == false AND commentTopicId == %d",topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery)
        
        if commentData.count > 0{
            return true
        }else{
            return false
        }
    }
    
    // MARK: - Load More
    open class func loadMoreComment(fromCommentId commentId:Int, topicId:Int, limit:Int = 10)->[QiscusComment]{
        var comments = [QiscusComment]()
        let realm = try! Realm()
        let searchQuery = NSPredicate(format: "commentId < %d AND commentTopicId == %d", commentId, topicId)
        let commentData = realm.objects(QiscusComment.self).filter(searchQuery).sorted(byProperty: "commentId")
        
        if commentData.count > 0{
            var i = 0
            for comment in commentData {
                if i < limit {
                    comments.append(comment)
                }else{
                    break
                }
                i += 1
            }
        }
        
        return comments
    }
    
    open class func deleteAll(){
        let realm = try! Realm()
        let comments = realm.objects(QiscusComment.self)
        
        if comments.count > 0 {
            try! realm.write {
                realm.delete(comments)
            }
        }
    }
}
