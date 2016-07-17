//
//  QRoom.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

// MARK: - addOn for LinkDokter
enum QRoomType:Int {
    case HLSingle
    case HLGroup
    case LLSingle
    case LLGRoup
}


// MARK: - class QRoom
class QRoom: Object {
    dynamic var localId:Int = 0
    dynamic var roomId:Int = 0
    dynamic var roomName:NSString = ""
    dynamic var roomChannel:NSString = ""
    dynamic var roomTypeRaw:Int = QRoomType.HLSingle.rawValue
    dynamic var roomLastCommentId:Int = 0
    dynamic var roomLastCommentMessage:NSString = ""
    dynamic var roomLastCommentSender:NSString = ""
    dynamic var roomLastCommentTopicId:Int = 0
    dynamic var roomLastCommentTopicTitle:NSString = ""
    dynamic var roomCountNotif:Int = 0
    dynamic var roomSecretCode:NSString = ""
    dynamic var roomSecretCodeEnabled:Bool = false
    dynamic var roomSecretCodeURL:NSString = ""
    dynamic var roomIsDeleted:Bool = false
    
    //additional attribute for halodoc
    dynamic var roomRate:Int64 = 0
    
    //add new variable to force update db scheme
    dynamic var dummy:Bool = true
    
    var roomType: QRoomType {
        get {
            return QRoomType(rawValue: roomTypeRaw)!
        }
    }
    
    // MARK: - Primary Key
    override class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Setter Methode
    func setDeletedAll(type:QRoomType){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == false AND roomTypeRaw == %d",type.rawValue)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            for room in roomData{
                try! realm.write {
                    room.roomIsDeleted = true
                }
            }
        }
    }
    func setUndeleteAll(type:QRoomType){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == true AND roomTypeRaw == %d",type.rawValue)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            for room in roomData{
                try! realm.write {
                    room.roomIsDeleted = false
                }
            }
        }
    }
    func setUndelete(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d", self.roomId)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            let room = roomData.first!
            try! realm.write {
                room.roomIsDeleted = false
            }
        }else{
            self.roomIsDeleted = true
        }
    }
    func deleteUnusedRoom(type:QRoomType){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == true AND roomTypeRaw == %d",type.rawValue)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            for room in roomData{
                QiscusTopic.deleteAllTopicsInRoom(room.roomId)
                try! realm.write {
                    realm.delete(room)
                }
            }
        }
    }
    // MARK: - Getter Methode
    class func getRoomById(roomId:Int)->QRoom?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d",roomId)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            return roomData.first
        }else{
            return nil
        }
    }
    
    class func updateRoom(data:JSON)->Bool{
        let roomId:Int = data["room_id"].intValue
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d", roomId)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        let config = QiscusConfig.sharedInstance
        
        if(roomData.count > 0){
            let room = roomData.first!
            try! realm.write {
                room.roomIsDeleted = false
                room.roomLastCommentId = data["comment_id"].intValue
                room.roomLastCommentMessage = data["real_comment"].stringValue
                room.roomLastCommentSender = data["username_real"].stringValue
                room.roomLastCommentTopicId = data["topic_id"].intValue
                room.roomLastCommentTopicTitle = data["topic_title"].stringValue
                if(!room.roomLastCommentSender.isEqualToString(config.USER_EMAIL as String)){
                    room.roomCountNotif = room.roomCountNotif+1
                }
            }
            return true
        }else{
            return false
        }
    }

    func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QRoom).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    

    func updateRoomRate(rate:Int64){
        let realm = try! Realm()
        try! realm.write {
            self.roomRate = rate
        }
    }
    func updateRoomName(name:String){
        let realm = try! Realm()
        try! realm.write {
            self.roomName = name
        }
    }
    func getAllRoom(type:QRoomType) -> [QRoom]{
        var allRoom = [QRoom]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == false AND roomTypeRaw == %d",type.rawValue)
        let roomData = realm.objects(QRoom).filter(searchQuery).sorted("roomLastCommentId", ascending: false)
        
        if(roomData.count > 0){
            for room in roomData{
                allRoom.append(room)
            }
        }
        self.deleteUnusedRoom(type)
        return allRoom
    }
    
    // MARK: - Save Room
    func saveRoom(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d", self.roomId)
        let roomData = realm.objects(QRoom).filter(searchQuery)
        
        if(self.localId == 0){
            self.localId = getLastId() + 1
        }
        if(roomData.count == 0){
            try! realm.write {
                realm.add(self)
            }
        }else{
            let room = roomData.first!
            try! realm.write {
                room.roomId = self.roomId
                room.roomName = self.roomName
                room.roomChannel = self.roomChannel
                room.roomTypeRaw = self.roomTypeRaw
                room.roomLastCommentId = self.roomLastCommentId
                room.roomLastCommentMessage = self.roomLastCommentMessage
                room.roomLastCommentSender = self.roomLastCommentSender
                room.roomLastCommentTopicId = self.roomLastCommentTopicId
                room.roomLastCommentTopicTitle = self.roomLastCommentTopicTitle
                room.roomCountNotif = self.roomCountNotif
                room.roomSecretCode = self.roomSecretCode
                room.roomSecretCodeEnabled = self.roomSecretCodeEnabled
                room.roomSecretCodeURL = self.roomSecretCodeURL
                room.roomIsDeleted = self.roomIsDeleted
            }
            
        }
    }
}
