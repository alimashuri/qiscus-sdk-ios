//
//  QiscusRoom.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

open class QiscusRoom: Object {
    open dynamic var localId:Int = 0
    open dynamic var roomId:Int = 0
    open dynamic var roomName:String = ""
    open dynamic var roomChannel:String = ""
    open dynamic var roomLastCommentId:Int = 0
    open dynamic var roomLastCommentMessage:String = ""
    open dynamic var roomLastCommentSender:String = ""
    open dynamic var roomLastCommentTopicId:Int = 0
    open dynamic var roomLastCommentTopicTitle:String = ""
    open dynamic var roomCountNotif:Int = 0
    open dynamic var roomSecretCode:String = ""
    open dynamic var roomSecretCodeEnabled:Bool = false
    open dynamic var roomSecretCodeURL:String = ""
    open dynamic var roomIsDeleted:Bool = false
    open dynamic var desc:String = ""
    open dynamic var optionalData:String = ""
    open dynamic var distinctId:String = ""
    open dynamic var user:String = ""
    
    // MARK: - Primary Key
    override open class func primaryKey() -> String {
        return "localId"
    }
    
    
    // MARK: - Getter Methode
    open class func getRoomById(_ roomId:Int)->QiscusRoom?{ //USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d",roomId)
        let roomData = realm.objects(QiscusRoom.self).filter(searchQuery)
        
        if(roomData.count > 0){
            return roomData.first
        }else{
            return nil
        }
    }
    open class func getRoom(_ withDistinctId:Int, andUserEmail:String)->QiscusRoom?{ //USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "distinctId == %@",withDistinctId)
        let roomData = realm.objects(QiscusRoom.self).filter(searchQuery)
        
        if(roomData.count > 0){
            return roomData.first
        }else{
            return nil
        }
    }
    
    open class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusRoom.self).sorted(byProperty: "localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    
    open class func getRoom(_ fromJSON:JSON)->QiscusRoom{
        let room = QiscusRoom()
        if let id = fromJSON["id"].int {  room.roomId = id  }
        if let commentId = fromJSON["last_comment_id"].int {room.roomLastCommentId = commentId}
        if let lastMessage = fromJSON["last_comment_message"].string {
            room.roomLastCommentMessage = lastMessage
        }
        if let topicId = fromJSON["last_topic_id"].int { room.roomLastCommentTopicId = topicId}
        if let option = fromJSON["options"].string {
            if option != "" && option != "<null>" {
                room.optionalData = option
            }
        }
        if let distinctId = fromJSON["distinct_id"].string { room.distinctId = distinctId}
        
        room.saveRoom()
        return room
    }
    open func updateUser(_ user:String){
        let realm = try! Realm()
        try! realm.write {
            self.user = user
        }
    }
    open func updateDistinctId(_ distinctId:String){
        let realm = try! Realm()
        try! realm.write {
            self.distinctId = distinctId
        }
    }
    open func updateDesc(_ desc:String){
        let realm = try! Realm()
        try! realm.write {
            self.desc = desc
        }
    }
    open func updateRoomName(_ name:String){
        let realm = try! Realm()
        try! realm.write {
            self.roomName = name
        }
    }
    open class func getAllRoom() -> [QiscusRoom]{
        var allRoom = [QiscusRoom]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == false")
        let roomData = realm.objects(QiscusRoom.self).filter(searchQuery).sorted(byProperty: "roomLastCommentId", ascending: false)
        
        if(roomData.count > 0){
            for room in roomData{
                allRoom.append(room)
            }
        }
        return allRoom
    }
    open class func getRoomWithLastTopicId(_ topicId:Int)->Int{
        var roomId:Int = 0
        let realm = try! Realm()
        let searchQuery:NSPredicate = NSPredicate(format: "roomLastCommentTopicId == %d",topicId)
        let roomData = realm.objects(QiscusRoom.self).filter(searchQuery)
        
        if(roomData.count > 0){
            roomId = roomData.first!.roomId
        }
        return roomId
    }
    // MARK: - Save Room
    open func saveRoom(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d", self.roomId)
        let roomData = realm.objects(QiscusRoom.self).filter(searchQuery)
        
        if(self.localId == 0){
            self.localId = QiscusRoom.getLastId() + 1
        }
        if(roomData.count == 0){
            try! realm.write {
                realm.add(self)
            }
        }else{
            let room = roomData.first!
            try! realm.write {
                room.roomId = self.roomId
                if room.roomName != "" { room.roomName = self.roomName }
                if room.roomChannel != "" { room.roomChannel = self.roomChannel }
                if room.roomLastCommentId != 0 { room.roomLastCommentId = self.roomLastCommentId }
                if room.roomLastCommentMessage != "" {
                    room.roomLastCommentMessage = self.roomLastCommentMessage
                }
                
                room.roomLastCommentSender = self.roomLastCommentSender
                room.roomLastCommentTopicId = self.roomLastCommentTopicId
                room.roomLastCommentTopicTitle = self.roomLastCommentTopicTitle
                room.roomCountNotif = self.roomCountNotif
                room.roomSecretCode = self.roomSecretCode
                room.roomSecretCodeEnabled = self.roomSecretCodeEnabled
                room.roomSecretCodeURL = self.roomSecretCodeURL
                room.roomIsDeleted = self.roomIsDeleted
                if room.optionalData != "" { room.optionalData = self.optionalData }
                if room.distinctId != "" {room.distinctId = self.distinctId}
            }
        }
    }
}
