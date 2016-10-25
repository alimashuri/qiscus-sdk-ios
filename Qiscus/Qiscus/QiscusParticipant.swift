//
//  QiscusParticipant.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift

open class QiscusParticipant: Object {
    open dynamic var localId:Int = 0
    open dynamic var participantRoomId:Int = 0
    open dynamic var participantUserId:Int = 0
    open dynamic var participantIsDeleted:Bool = false
    
    open class var LastId:Int{
        get{
            let realm = try! Realm()
            let RetNext = realm.objects(QiscusParticipant.self).sorted("localId")
            
            if RetNext.count > 0 {
                let last = RetNext.last!
                return last.localId
            } else {
                return 0
            }
        }
    }
    
    override open class func primaryKey() -> String {
        return "localId"
    }
    open class func setDeleteAllParticipantInRoom(_ roomId:Int){
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        
        searchQuery = NSPredicate(format: "participantRoomId == %d ", roomId)
        let participantData = realm.objects(QiscusParticipant.self).filter(searchQuery)
        
        if(participantData.count > 0){
            for participant in participantData{
                try! realm.write {
                    participant.participantIsDeleted = true
                }
            }
        }
    }
    open class func addParticipant(_ userId:Int, roomId:Int){ // USED
        let realm = try! Realm()
        var searchQuery = NSPredicate()
        
        searchQuery = NSPredicate(format: "participantRoomId == %d AND participantUserId == %d", roomId, userId)
        let participantData = realm.objects(QiscusParticipant.self).filter(searchQuery)
        
        if(participantData.count == 0){
            let participant = QiscusParticipant()
            participant.localId = QiscusParticipant.LastId + 1
            participant.participantRoomId = roomId
            participant.participantUserId = userId
            try! realm.write {
                realm.add(participant)
            }
        }
    }
    open class func CommitParticipantChange(_ roomId:Int){
        let realm = try! Realm()
        let searchQuery =  NSPredicate(format: "participantRoomId == %d AND participantIsDeleted == true", roomId)
        let participantData = realm.objects(QiscusParticipant.self).filter(searchQuery)
        
        if(participantData.count > 0){
            for participant in participantData{
                try! realm.write {
                    realm.delete(participant)
                }
            }
        }
    }
}
