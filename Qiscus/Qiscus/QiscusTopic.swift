//
//  QiscusTopic.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

public class QiscusTopic: Object {
    public dynamic var localId:Int = 0
    public dynamic var topicId:Int = 0
    public dynamic var topicName:NSString = ""
    public dynamic var topicRoomId:Int = 0
    public dynamic var topicLastUpdate:Double = 0
    public dynamic var topicIsDeleted:Bool = false
    public dynamic var topicDeletable:Bool = false
    public dynamic var topicUnread:Int = 0
    
    override public class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Setter Methode
    public class func setDeletedAll(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = true
                }
            }
        }
    }
    public class func setUndeleteAll(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = false
                }
            }
        }
    }
    public func setUndelete(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            try! realm.write {
                topic.topicIsDeleted = false
            }
        }else{
            self.topicIsDeleted = true
        }
    }
    public class func deleteUnusedTopic(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
    public func clearNotif(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
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
    public class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusTopic).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    public class func getTopicById(topicId:Int) -> QiscusTopic?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d",topicId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            return topic
        }else{
            return nil
        }
    }
    public class func getAllTopic(roomId: Int) -> [QiscusTopic]{
        var allTopic = [QiscusTopic]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery).sorted("topicUnread", ascending: false)
        
        if(topicData.count > 0){
            for topic in topicData{
                allTopic.append(topic)
            }
        }
        QiscusTopic.deleteUnusedTopic(roomId)
        return allTopic
    }
    
    
    // MARK : - save topics
    func saveTopics(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(self.localId == 0){
            self.localId = QiscusTopic.getLastId() + 1
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
    public class func deleteAllTopicsInRoom(roomId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
}
