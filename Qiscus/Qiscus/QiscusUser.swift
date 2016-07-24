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

public class QiscusUser: Object {
    // MARK: - Class Attribute
    public dynamic var localId:Int = 0
    public dynamic var userId:Int = 0
    public dynamic var userAvatarURL:String = ""
    public dynamic var userAvatarLocalPath:String = ""
    public dynamic var userNameAs:String = ""
    public dynamic var userEmail:String = ""
    public dynamic var userFullName:String = ""
    public dynamic var userAvailability:Bool = true
    public dynamic var role:String = ""
    public dynamic var desc: String = ""

    // MARK: - Primary Key
    override public class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - UpdaterMethode
    public func userId(value:Int){
        let realm = try! Realm()
        try! realm.write {
            self.userId = value
        }
    }
    public func userAvatarURL(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarURL = value
        }
    }
    public func userAvatarLocalPath(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarLocalPath = value
        }
    }
    public func userNameAs(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userNameAs = value
        }
    }
    public func userEmail(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userEmail = value
        }
    }
    public func userFullName(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.userFullName = value
        }
    }
    public func userRole(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.role = value
        }
    }
    public func usernameAs(nameAs: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail, self.role)
        let userData = realm.objects(QiscusUser).filter(searchQuery)
        
        if(userData.count == 0){
            self.userNameAs = nameAs
        }else{
            let user = userData.first!
            try! realm.write {
                user.userNameAs = nameAs
            }
        }
    }
    public func updateDescription(desc: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail, self.role)
        let userData = realm.objects(QiscusUser).filter(searchQuery)
        
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
    public func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QiscusUser).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    
    public func getAllUser()->[QiscusUser]?{
        let realm = try! Realm()
        let userData = realm.objects(QiscusUser)
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
    public class func getUserWithEmail(email:String, role:String = "")->QiscusUser?{ // USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", email,role)
        let userData = realm.objects(QiscusUser).filter(searchQuery)
        
        if(userData.count == 0){
            return nil
        }else{
            return userData.first!
        }
    }

    public func updateUserFullName(fullName: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ AND role == %@", self.userEmail,self.role)
        let userData = realm.objects(QiscusUser).filter(searchQuery)
        
        if(userData.count == 0){
            self.userFullName = fullName
        }else{
            let user = userData.first!
            try! realm.write {
                user.userFullName = fullName
            }
        }
    }
    
    public func getUserFromRoomJSON(json:JSON, role:String = "")->QiscusUser{
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
    public func saveUser()->QiscusUser{ //USED
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@ and role == %@", self.userEmail, self.role)
        let userData = realm.objects(QiscusUser).filter(searchQuery)

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
    private func getFileName() ->String{
        let mediaURL:NSURL = NSURL(string: self.userAvatarURL as String)!
        let fileName = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
        return fileName!
    }
    
    public class func setUnavailableAll(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userAvailability == true")
        let userData = realm.objects(QiscusUser).filter(searchQuery)
        
        if userData.count > 0{
            for user in userData{
                user.userAvailability = false
            }
        }
    }
}
