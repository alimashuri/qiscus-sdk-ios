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

public class QiscusRoom: Object {
    public dynamic var localId:Int = 0
    public dynamic var roomId:Int = 0
    public dynamic var roomName:String = ""
    public dynamic var roomChannel:String = ""
    public dynamic var roomLastCommentId:Int = 0
    public dynamic var roomLastCommentMessage:String = ""
    public dynamic var roomLastCommentSender:String = ""
    public dynamic var roomLastCommentTopicId:Int = 0
    public dynamic var roomLastCommentTopicTitle:String = ""
    public dynamic var roomCountNotif:Int = 0
    public dynamic var roomSecretCode:String = ""
    public dynamic var roomSecretCodeEnabled:Bool = false
    public dynamic var roomSecretCodeURL:String = ""
    public dynamic var roomIsDeleted:Bool = false
    public dynamic var desc:String = ""

    

    // MARK: - Primary Key
    override public class func primaryKey() -> String {
        return "localId"
    }
    
    
    // MARK: - Getter Methode
    public class func getRoomById(roomId:Int)->QiscusRoom?{ //USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d",roomId)
        let roomData = realm.objects(QiscusRoom).filter(searchQuery)
        
        if(roomData.count > 0){
            return roomData.first
        }else{
            return nil
        }
    }

    public class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusRoom).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    

    public func updateDesc(desc:String){
        let realm = try! Realm()
        try! realm.write {
            self.desc = desc
        }
    }
    public func updateRoomName(name:String){
        let realm = try! Realm()
        try! realm.write {
            self.roomName = name
        }
    }
    public class func getAllRoom() -> [QiscusRoom]{
        var allRoom = [QiscusRoom]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomIsDeleted == false")
        let roomData = realm.objects(QiscusRoom).filter(searchQuery).sorted("roomLastCommentId", ascending: false)
        
        if(roomData.count > 0){
            for room in roomData{
                allRoom.append(room)
            }
        }
        return allRoom
    }
    
    // MARK: - Save Room
    public func saveRoom(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "roomId == %d", self.roomId)
        let roomData = realm.objects(QiscusRoom).filter(searchQuery)
        
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
