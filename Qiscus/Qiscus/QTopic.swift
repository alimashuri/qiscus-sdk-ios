//
//  QTopic.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class QTopic: Object {
    dynamic var localId:Int = 0
    dynamic var topicId:Int = 0
    dynamic var topicName:NSString = ""
    dynamic var topicRoomId:Int = 0
    dynamic var topicLastUpdate:Double = 0
    dynamic var topicIsDeleted:Bool = false
    dynamic var topicDeletable:Bool = false
    dynamic var topicUnread:Int = 0
    
    override class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Setter Methode
    func setDeletedAll(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = true
                }
            }
        }
    }
    func setUndeleteAll(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = false
                }
            }
        }
    }
    func setUndelete(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            try! realm.write {
                topic.topicIsDeleted = false
            }
        }else{
            self.topicIsDeleted = true
        }
    }
    func deleteUnusedTopic(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
    func clearNotif(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            try! realm.write {
                topic.topicUnread = 0
            }
        }else{
            self.topicUnread = 0
        }
    }
    
    // MARK: - Getter Methode
    func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QTopic).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    class func getTopicById(topicId:Int) -> QTopic?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d",topicId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            return topic
        }else{
            return nil
        }
    }
    func getAllTopic(roomId: Int) -> [QTopic]{
        var allTopic = [QTopic]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QTopic).filter(searchQuery).sorted("topicUnread", ascending: false)
        
        if(topicData.count > 0){
            for topic in topicData{
                allTopic.append(topic)
            }
        }
        self.deleteUnusedTopic(roomId)
        return allTopic
    }
    // MARK : - getTopic from JSON
    func getTopicFromJSON(data: JSON, roomId:Int) -> QTopic{
        let topic = QTopic()
        topic.topicId = data["id"].intValue
        topic.topicName = data["title"].stringValue
        topic.topicDeletable = data["deleted"].boolValue
        topic.topicUnread = data["comment_unread"].intValue
        topic.topicRoomId = roomId
        topic.saveTopics()
        
        return topic
    }
    
    // MARK : - save topics
    func saveTopics(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(self.localId == 0){
            self.localId = getLastId() + 1
        }
        if(topicData.count == 0){
            try! realm.write {
                realm.add(self)
            }
        }else{
            let topic = topicData.first!
            try! realm.write {
                topic.topicId = self.topicId
                topic.topicName = self.topicName
                topic.topicRoomId = self.topicRoomId
                topic.topicLastUpdate = self.topicLastUpdate
                topic.topicIsDeleted = self.topicIsDeleted
                topic.topicDeletable = self.topicDeletable
                topic.topicUnread = self.topicUnread
            }
        }
    }
    
    // MARK: - delete all topic in Room
    func deleteAllTopicsInRoom(roomId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicRoomId == %d",roomId)
        let topicData = realm.objects(QTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
}
