//
//  QUser.swift
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

//MARK: - addOn enum for linkDokter
enum QUserType:Int {
    case Doctor
    case Client
}

class QUser: Object {
    // MARK: - Class Attribute
    dynamic var localId:Int = 0
    dynamic var userId:Int = 0
    dynamic var userAvatarURL:NSString = ""
    dynamic var userAvatarLocalPath:NSString = ""
    dynamic var userNameAs:NSString = ""
    dynamic var userEmail:NSString = ""
    dynamic var userFullName:NSString = ""

    
    // MARK: - addOn Attribute for LinkDokter
    dynamic var userTypeRaw:Int = QUserType.Doctor.rawValue
    
    // MARK: - Doctor only variable
    dynamic var doctorStr:String = "-"
    dynamic var doctorAvailable:Bool = false
    dynamic var doctorChatRoomId:Int = 0
    dynamic var doctorCity:String = "-"
    dynamic var doctorSpeciality:String = "-"
    dynamic var doctorAge:Int = 0
    dynamic var doctorLocation:String = "-"
    dynamic var doctorPhoneNumber:String = "-"
    dynamic var doctorPracticeName:String = "-"
    dynamic var doctorPracticeLocName:String = "-"
    dynamic var doctorRate:Int64 = 0
    
    var userType:QUserType{
        get{
            return QUserType(rawValue: userTypeRaw)!
        }
    }
    // MARK: - Primary Key
    override class func primaryKey() -> String {
        return "localId"
    }
    
    // MARK: - UpdaterMethode
    func doctorRate(value:Int64){
        let realm = try! Realm()
        try! realm.write {
            self.doctorRate = value
        }
    }
    func userId(value:Int){
        let realm = try! Realm()
        try! realm.write {
            self.userId = value
        }
    }
    func userAvatarURL(value:NSString){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarURL = value
        }
    }
    func userAvatarLocalPath(value:NSString){
        let realm = try! Realm()
        try! realm.write {
            self.userAvatarLocalPath = value
        }
    }
    func userNameAs(value:NSString){
        let realm = try! Realm()
        try! realm.write {
            self.userNameAs = value
        }
    }
    func userEmail(value:NSString){
        let realm = try! Realm()
        try! realm.write {
            self.userEmail = value
        }
    }
    func userFullName(value:NSString){
        let realm = try! Realm()
        try! realm.write {
            self.userFullName = value
        }
    }
    func userType(value:QUserType){
        let realm = try! Realm()
        try! realm.write {
            self.userTypeRaw = value.rawValue
        }
    }
    func doctorStr(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorStr = value
        }
    }
    func doctorAvailable(value:Bool){
        let realm = try! Realm()
        try! realm.write {
            self.doctorAvailable = value
        }
    }
    func doctorChatRoomId(value:Int){
        let realm = try! Realm()
        try! realm.write {
            self.doctorChatRoomId = value
        }
    }
    func doctorCity(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorCity = value
        }
    }
    func doctorSpeciality(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorSpeciality = value
        }
    }
    func doctorAge(value:Int){
        let realm = try! Realm()
        try! realm.write {
            self.doctorAge = value
        }
    }
    func doctorLocation(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorLocation = value
        }
    }
    func doctorPhoneNumber(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorPhoneNumber = value
        }
    }
    func doctorPracticeName(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorPracticeName = value
        }
    }
    func doctorPracticeLocName(value:String){
        let realm = try! Realm()
        try! realm.write {
            self.doctorPracticeLocName = value
        }
    }
    
    // MARK: - Getter Methode
    func getLastId() -> Int{
        let realm = try! Realm()
        let RetNext = realm.objects(QUser).sorted("localId")
        
        if RetNext.count > 0 {
            let last = RetNext.last!
            return last.localId
        } else {
            return 0
        }
    }
    func updateUsernameAs(nameAs: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", self.userEmail)
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if(userData.count == 0){
            self.userNameAs = nameAs
        }else{
            let user = userData.first!
            try! realm.write {
                user.userNameAs = nameAs
            }
        }
    }
    func getAllUser()->[QUser]?{
        let realm = try! Realm()
        let userData = realm.objects(QUser)
        var users = [QUser]()
        if(userData.count == 0){
            return nil
        }else{
            for user in userData{
                users.append(user)
            }
            return users
        }
    }
    func getUserWithEmail(email:NSString)->QUser?{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", email)
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if(userData.count == 0){
            return nil
        }else{
            return userData.first!
        }
    }
    func updateDoctorChatRoomId(roomId:Int){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", self.userEmail)
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if(userData.count == 0){
            self.doctorChatRoomId = roomId
        }else{
            let user = userData.first!
            try! realm.write {
                user.doctorChatRoomId = roomId
            }
        }
    }
    func updateUserFullName(fullName: String){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", self.userEmail)
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if(userData.count == 0){
            self.userFullName = fullName
        }else{
            let user = userData.first!
            try! realm.write {
                user.userFullName = fullName
            }
        }
    }
    func updateUserAvatarLocalPath(){
        Alamofire.request(.GET, self.userAvatarURL as String, parameters: nil, encoding: ParameterEncoding.URL)
            .responseImage { response in
                if let image:UIImage = response.result.value {
                    let thumbImage:UIImage = QCommentFile().createThumbImage(image, size: 100)
                    let contentType:String = response.response?.allHeaderFields["Content-Type"] as! String
                    let contentTypeArray = contentType.characters.split("/")
                    
                    var timetokenString = "\(Double(NSDate().timeIntervalSince1970))"
                    timetokenString = timetokenString.stringByReplacingOccurrencesOfString(".", withString: "")
                    
                    let ext = String(contentTypeArray.last!).lowercaseString as NSString
                    
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    if !self.invalidated{
                        let path = "\(documentsPath)/avatar_\(self.userId).\(ext)"
                        
                        if (ext.isEqualToString("png")||ext.isEqualToString("png_")) {
                            UIImagePNGRepresentation(thumbImage)!.writeToFile(path, atomically: true)
                        }else if(ext.isEqualToString("jpg")||ext.isEqualToString("jpg_")){
                            UIImageJPEGRepresentation(thumbImage, 1.0)!.writeToFile(path, atomically: true)
                        }else{
                            response.data?.writeToFile(path, atomically: true)
                        }
                        if(!self.userAvatarLocalPath.isEqualToString("")){
                            let manager = NSFileManager.defaultManager()
                            do {
                                if (manager.fileExistsAtPath(self.userAvatarLocalPath as String))
                                {
                                    try manager.removeItemAtPath(self.userAvatarLocalPath as String)
                                }
                            } catch {
                                print(self.userAvatarLocalPath)
                            }
                        }
                        let realm = try! Realm()
                        try! realm.write {
                            self.userAvatarLocalPath = path
                        }
                    }
                }
            }
    }
    func getUserFromRoomJSON(json:JSON, type:QUserType)->QUser{
        var user = QUser()
        user.userId = json["id"].intValue
        user.userAvatarURL = json["image"].stringValue
        user.userAvatarLocalPath = ""
        user.userEmail = json["email"].stringValue
        user.userFullName = json["fullname"].stringValue
        user.userTypeRaw = type.rawValue
        
        if let speciality = json["specialist"].string {
            user.doctorSpeciality = speciality
        }
        if let age = json["age"].int{
            user.doctorAge = age
        }
        if let city = json["city"].string {
            user.doctorCity = city
        }
        if let chatRoom = json["chat_room_id"].int{
            user.doctorChatRoomId = chatRoom
        }
        if let str = json["str"].string{
            user.doctorStr = str
        }
        if let available = json["available"].bool{
            user.doctorAvailable = available
        }
        if let phoneNumber = json["phone_number"].string{
            user.doctorPhoneNumber = phoneNumber
        }
        if let practices = json["practice"].array{
            if practices.count > 0 {
                let practice = practices[0]
                if let practiceName = practice["name"].string {
                    user.doctorPracticeName = practiceName
                }
                if let practiceLocName = practice["location"].string {
                    user.doctorPracticeLocName = practiceLocName
                }
            }
        }
        user = user.saveUser()

        return user
    }
    func saveUser()->QUser{
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "userEmail == %@", self.userEmail)
        let userData = realm.objects(QUser).filter(searchQuery)

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
            if(!user.userAvatarURL.isEqualToString(self.userAvatarURL as String) ){
                try! realm.write {
                    user.userAvatarURL = self.userAvatarURL
                    //user.updateUserAvatarLocalPath()
                }
            }
            try! realm.write {
                user.userId = self.userId
                user.userNameAs = self.userNameAs
                user.userFullName = self.userFullName
                user.userTypeRaw = self.userTypeRaw
                
                user.doctorStr = self.doctorStr
                user.doctorAvailable = self.doctorAvailable
                user.doctorChatRoomId = self.doctorChatRoomId
                user.doctorCity = self.doctorCity
                user.doctorSpeciality = self.doctorSpeciality
                user.doctorAge = self.doctorAge
                user.doctorLocation = self.doctorLocation
                user.doctorPhoneNumber = self.doctorPhoneNumber
                user.doctorRate = self.doctorRate
            }
            return user
        }
    }
    private func getFileName() ->String{
        let mediaURL:NSURL = NSURL(string: self.userAvatarURL as String)!
        let fileName = mediaURL.lastPathComponent?.stringByReplacingOccurrencesOfString("%20", withString: "_")
        return fileName!
    }
    
    class func getDoctorWithChatRoomId(roomId:Int)->QUser?{
        let realm = try! Realm()
        let email = Qiscus.sharedInstance.config.USER_EMAIL
        let searchQuery:NSPredicate = NSPredicate(format: "doctorChatRoomId == %d AND userEmail != %@", roomId, email)
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if userData.count > 0{
            return userData.first!
        }else{
            return nil
        }
        
    }
    class func setUnavailableAll(){
        let realm = try! Realm()
        
        let searchQuery:NSPredicate = NSPredicate(format: "doctorAvailable == true")
        let userData = realm.objects(QUser).filter(searchQuery)
        
        if userData.count > 0{
            for user in userData{
                user.doctorAvailable = false
            }
        }
    }
}
