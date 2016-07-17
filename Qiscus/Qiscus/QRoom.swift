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
                QTopic().deleteAllTopicsInRoom(room.roomId)
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
    
    /*
    class func getFirstDoctorForRoomJSON(data:JSON) -> HDDoctor?{
        let room = QRoom()
        var doctor:HDDoctor?
        
        print("data room json: \(data)")
        
        let participants = data["participants"]
        let participantsDoctors = participants["doctors"].arrayValue
        if participantsDoctors.count > 0 {
            var count = 1
            for doctorData in participantsDoctors {
                if count == 1 {
                    doctor = HDDoctor()
                    doctor?.fullname = doctorData["fullname"].stringValue
                    doctor?.doctor_id = doctorData["id"].numberValue
                    doctor?.city = doctorData["city"].stringValue
                    doctor?.email = doctorData["email"].stringValue
                    doctor?.specialist_description = doctorData["specialist"].stringValue
                    doctor?.rate = doctorData["rate"].numberValue
                    doctor?.avatar_url = doctorData["image"].stringValue
                    doctor?.available = doctorData["available"].boolValue
                    doctor?.enoughBalance = doctorData["enough_balance"].boolValue
                    if let rspecialist = doctorData["rspecialist"].string{
                        doctor?.specialist_title = rspecialist
                    }
                    doctor?.next_available = doctorData["next_available"].stringValue
                    doctor?.fallback_phone = doctorData["fallback_phone"].stringValue
                    
                    if let availabilities = doctorData["availabilities"].array {
                        if availabilities.count > 0 {
                            for availability in availabilities {
                                var availObj = ["day" : "" , "time" : ""]
                                if let day = availability["day"].string {
                                    availObj["day"]  = day
                                }
                                if let start = availability["start"].string {
                                    if let finish = availability["finish"].string{
                                        availObj["time"] = "\(start) - \(finish)"
                                    }
                                }
                                
                                let availModel = HDDoctorAvailability()
                                availModel.day = availObj["day"]!
                                availModel.time = availObj["time"]!
                                doctor?.availabilities.append(availModel)
                            }
                        }
                    }
                }else{
                    break
                }
                count += 1
            }
        }
        return doctor
    }
 */
    class func getRoomFromJSON(data: JSON) -> QRoom{
        let room = QRoom()
        print("data room json: \(data)")
        if let roomId = data["id"].int {
           room.roomId = roomId
        }else if let roomId = data["room_id"].int{
           room.roomId = roomId
        }
        room.roomLastCommentId = data["last_comment_id"].intValue
        room.roomLastCommentMessage = data["last_comment_message"].stringValue
        room.roomCountNotif = data["count_notif"].intValue
        room.roomSecretCode = data["secret_code"].stringValue
        room.roomSecretCodeURL = data["url_secret_code"].stringValue
        room.roomName = data["name"].stringValue
        room.roomSecretCodeEnabled = data["secret_code_enabled"].boolValue
        room.roomLastCommentTopicId = data["last_comment_topic_id"].intValue
        room.roomLastCommentTopicTitle = data["last_comment_topic_title"].stringValue
        room.roomLastCommentSender = data["sender"].stringValue
        room.roomChannel = data["code_en"].stringValue
        
        let room_type = data["room_type"].stringValue
        switch room_type{
            case "LL-single":
                room.roomTypeRaw = QRoomType.LLSingle.rawValue
                break
            case "HL-single":
                room.roomTypeRaw = QRoomType.HLSingle.rawValue
                break
            case "LL-group":
                room.roomTypeRaw = QRoomType.LLGRoup.rawValue
                break
            case "HL-group":
                room.roomTypeRaw = QRoomType.HLGroup.rawValue
                break
            default :
                room.roomTypeRaw = QRoomType.HLSingle.rawValue
        }
        
        let participants = data["participants"]
        
        let participantsDoctors = participants["doctors"].arrayValue
        if participantsDoctors.count > 0 {
            QRoomParticipant.setDeleteAllParticipantInRoom(room.roomId)
            var count = 1
            for doctor in participantsDoctors {
                let user = QUser().getUserFromRoomJSON(doctor, type: QUserType.Doctor)
                let userOld = QUser().getUserWithEmail(user.userEmail)
//                if(userOld == nil){
//                    user.updateUserAvatarLocalPath()
//                }else{
//                    if !(userOld?.userAvatarURL)!.isEqualToString(user.userAvatarURL as String){
//                        user.updateUserAvatarLocalPath()
//                    }
//                }
                print("user parsed: \(user)")
                QRoomParticipant.addParticipant(user.userId, roomId: room.roomId)
                
                if(room.roomTypeRaw == QRoomType.LLSingle.rawValue || room.roomTypeRaw == QRoomType.HLSingle.rawValue){
                    user.updateDoctorChatRoomId(room.roomId)
                }
                if count == 1 {
                    room.roomRate = doctor["rate"].int64Value
                }
                count += 1
            }
            QRoomParticipant.CommitParticipantChange(room.roomId)
        }
        let participantsConsumers = participants["consumers"].arrayValue
        if participantsConsumers.count > 0 {
            QRoomParticipant.setDeleteAllParticipantInRoom(room.roomId)
            for consumer in participantsDoctors {
                let user = QUser().getUserFromRoomJSON(consumer, type: QUserType.Client)
//                let userOld = QUser().getUserWithEmail(user.userEmail)
//                if(userOld == nil){
//                    user.updateUserAvatarLocalPath()
//                }else{
//                    if !(userOld?.userAvatarURL)!.isEqualToString(user.userAvatarURL as String){
//                        user.updateUserAvatarLocalPath()
//                    }
//                }
                QRoomParticipant.addParticipant(user.userId, roomId: room.roomId)
            }
            QRoomParticipant.CommitParticipantChange(room.roomId)
        }
        if(participantsConsumers.count == 1 && participantsDoctors.count == 1){
            room.roomTypeRaw = QRoomType.HLSingle.rawValue
        }else if(participantsConsumers.count == 0 && participantsDoctors.count == 2){
            room.roomTypeRaw = QRoomType.LLSingle.rawValue
        }else if(participantsDoctors.count > 2 && participantsConsumers.count == 0){
            room.roomTypeRaw = QRoomType.LLGRoup.rawValue
        }else{
            room.roomTypeRaw = QRoomType.HLGroup.rawValue
        }
        room.saveRoom()
        return room
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
