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

open class QiscusTopic: Object {
    open dynamic var localId:Int = 0
    open dynamic var topicId:Int = 0
    open dynamic var topicName:NSString = ""
    open dynamic var topicRoomId:Int = 0
    open dynamic var topicLastUpdate:Double = 0
    open dynamic var topicIsDeleted:Bool = false
    open dynamic var topicDeletable:Bool = false
    open dynamic var topicUnread:Int = 0
    
    override open class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - Setter Methode
    open class func setDeletedAll(_ roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = true
                }
            }
        }
    }
    open class func setUndeleteAll(_ roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    topic.topicIsDeleted = false
                }
            }
        }
    }
    open func setUndelete(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            try! realm.write {
                topic.topicIsDeleted = false
            }
        }else{
            self.topicIsDeleted = true
        }
    }
    open class func deleteUnusedTopic(_ roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == true AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
    open func clearNotif(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
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
    open class func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusTopic.self).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    open class func getTopicById(_ topicId:Int) -> QiscusTopic?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d",topicId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            let topic = topicData.first!
            return topic
        }else{
            return nil
        }
    }
    open class func getAllTopic(_ roomId: Int) -> [QiscusTopic]{
        var allTopic = [QiscusTopic]()
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicIsDeleted == false AND topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery).sorted("topicUnread", ascending: false)
        
        if(topicData.count > 0){
            for topic in topicData{
                allTopic.append(topic)
            }
        }
        QiscusTopic.deleteUnusedTopic(roomId)
        return allTopic
    }
    
    
    // MARK : - save topics
    open func saveTopics(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicId == %d", self.topicId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
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
    open class func deleteAllTopicsInRoom(_ roomId: Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "topicRoomId == %d",roomId)
        let topicData = realm.objects(QiscusTopic.self).filter(searchQuery)
        
        if(topicData.count > 0){
            for topic in topicData{
                try! realm.write {
                    realm.delete(topic)
                }
            }
        }
    }
}
