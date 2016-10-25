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
                room.roomName = self.roomName
                room.roomChannel = self.roomChannel
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
