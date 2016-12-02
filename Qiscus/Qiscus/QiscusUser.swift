//
//  QiscusUser.swift
//  LinkDokter
//
//  Created by Qiscus on 2/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import AlamofireImage
import SwiftyJSON

open class QiscusUser: Object {
    // MARK: - Class Attribute
    open dynamic var localId:Int = 0
    open dynamic var userId:Int = 0
    open dynamic var userAvatarURL:String = ""
    open dynamic var userAvatarLocalPath:String = ""
    open dynamic var userNameAs:String = ""
    open dynamic var userEmail:String = ""
    open dynamic var userFullName:String = ""
    open dynamic var userAvailability:Bool = true
    open dynamic var role:String = ""
    open dynamic var desc: String = ""

    // MARK: - Primary Key
    override open class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - UpdaterMethode
    open func userId(_ value:Int){
        let realm = try! Realm()
        try! realm.write {
            self.userId = value
        }
    }
    open func userAvatarURL(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarURL = value
        }
    }
    open func userAvatarLocalPath(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarLocalPath = value
        }
    }
    open func userNameAs(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userNameAs = value
        }
    }
    open func userEmail(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userEmail = value
        }
    }
    open func userFullName(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userFullName = value
        }
    }
    open func userRole(_ value:String){
        let realm = try! Realm()
        try! realm.write {
            self.role = value
        }
    }
    open func usernameAs(_ nameAs: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail, self.role)
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)
        
        if(userData.count == 0){
            self.userNameAs = nameAs
        }else{
            let user = userData.first!
            try! realm.write {
                user.userNameAs = nameAs
            }
        }
    }
    open func updateDescription(_ desc: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail, self.role)
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)
        
        if(userData.count == 0){
            self.desc = desc
        }else{
            let user = userData.first!
            try! realm.write {
                user.desc = desc
            }
        }
    }
    // MARK: - Getter Methode
    open func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusUser.self).sorted(byProperty: "localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    
    open func getAllUser()->[QiscusUser]?{
        let realm = try! Realm()
        let userData = realm.objects(QiscusUser.self)
        var users = [QiscusUser]()
        if(userData.count == 0){
            return nil
        }else{
            for user in userData{
                users.append(user)
            }
            return users
        }
    }
    open class func getUserWithEmail(_ email:String)->QiscusUser?{ // USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", email)
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)
        
        if(userData.count == 0){
            return nil
        }else{
            return userData.first!
        }
    }

    open func updateUserFullName(_ fullName: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail,self.role)
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)
        
        if(userData.count == 0){
            self.userFullName = fullName
        }else{
            let user = userData.first!
            try! realm.write {
                user.userFullName = fullName
            }
        }
    }
    
    open func getUserFromRoomJSON(_ json:JSON, role:String = "")->QiscusUser{
        var user = QiscusUser()
        user.userId = json["id"].intValue
        user.userAvatarURL = json["image"].stringValue
        user.userAvatarLocalPath = ""
        user.userEmail = json["email"].stringValue
        user.userFullName = json["fullname"].stringValue
        user.role = role
        
        user = user.saveUser()

        return user
    }
    open func saveUser()->QiscusUser{ //USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", self.userEmail)
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)

        if(self.localId == 0){
            self.localId = getLastId() + 1
        }
        
        if(userData.count == 0){
            try! realm.write {
                realm.add(self)
            }
            return self
        }else{
            let user = userData.first!
            if(user.userAvatarURL != self.userAvatarURL){
                try! realm.write {
                    user.userAvatarURL = self.userAvatarURL
                }
            }
            try! realm.write {
                user.userId = self.userId
                //user.userNameAs = self.userNameAs
                user.role = self.role
                user.userFullName = self.userFullName
            }
            return user
        }
    }
    fileprivate func getFileName() ->String{
        let mediaURL:URL = URL(string: self.userAvatarURL as String)!
        let fileName = mediaURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
        return fileName
    }
    
    open class func setUnavailableAll(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userAvailability == true")
        let userData = realm.objects(QiscusUser.self).filter(searchQuery)
        
        if userData.count > 0{
            for user in userData{
                user.userAvailability = false
            }
        }
    }
}
