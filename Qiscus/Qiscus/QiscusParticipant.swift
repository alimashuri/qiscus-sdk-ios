//
//  QiscusParticipant.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift

public class QiscusParticipant: Object {
    public dynamic var localId:Int = 0
    public dynamic var participantRoomId:Int = 0
    public dynamic var participantUserId:Int = 0
    public dynamic var participantIsDeleted:Bool = false
    
    public class var LastId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusParticipant).sorted("localId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.localId
            } else {
                return 0
            }
        }
    }
    
    override public class func primaryKey() -> String {
        return "localId"
    }
    public class func setDeleteAllParticipantInRoom(roomId:Int){
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        
        searchQuery = NSPredicate(format: "participantRoomId == %d ", roomId)
        let participantData = realm.objects(QiscusParticipant).filter(searchQuery)
        
        if(participantData.count > 0){
            for participant in participantData{
                try! realm.write {
                    participant.participantIsDeleted = true
                }
            }
        }
    }
    public class func addParticipant(userId:Int, roomId:Int){
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        
        searchQuery = NSPredicate(format: "participantRoomId == %d AND participantUserId == %d", roomId, userId)
        let participantData = realm.objects(QiscusParticipant).filter(searchQuery)
        
        if(participantData.count > 0){
            let participant = participantData.first!
            try! realm.write {
                participant.participantIsDeleted = true
            }
        }else{
            let participant = QiscusParticipant()
            participant.localId = QiscusParticipant.LastId + 1
            participant.participantRoomId = roomId
            participant.participantUserId = userId
            try! realm.write {
                realm.add(participant)
            }
        }
    }
    public class func CommitParticipantChange(roomId:Int){
        let realm = try! Realm()
        let searchQuery =  NSPredicate(format: "participantRoomId == %d AND participantIsDeleted == true", roomId)
        let participantData = realm.objects(QiscusParticipant).filter(searchQuery)
        
        if(participantData.count > 0){
            for participant in participantData{
                try! realm.write {
                    realm.delete(participant)
                }
            }
        }
    }
}
