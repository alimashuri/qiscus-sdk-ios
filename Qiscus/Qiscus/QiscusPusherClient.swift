//
//  QiscusPusherClient.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/23/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import SwiftyJSON
import PusherSwift
//import QToasterSwift

open class QiscusPusherClient: NSObject {
    static let sharedInstance = QiscusPusherClient()
    
    var pusher:Pusher!
    var pusherChannels:[PusherSubscriber] = [PusherSubscriber]()
    //let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var isConnected:Bool = false
    
    fileprivate override init(){}
    
    func PusherSubscribe() {
        let authToken         = QiscusConfig.sharedInstance.USER_TOKEN
        
        self.pusher = Pusher(key: QiscusConfig.sharedInstance.PUSHER_KEY)
        self.pusher.connect()
        
        // Set Channels
        let newMessagePusher = PusherSubscriber.createNew("newmessage", channel: authToken)
        SubscribeNewChannelEvent(newMessagePusher)

    }
    func unsubscribeAllPusher() {
        for pusher in self.pusherChannels {
            self.pusher?.unsubscribe(pusher.channel)
        }
        self.pusherChannels.removeAll()
    }
    
    func SubscribeNewChannelEvent(_ event:PusherSubscriber){
        //if !isListentToEvent(event){
        self.pusherChannels.append(event)
        let subscribe = self.pusher!.subscribe(event.channel)
        
        print("Qiscus listen to event: \(event.event) on channel: \(event.channel)")
        let _ = subscribe.bind(eventName: event.event, callback: { (data: Any?) -> Void in
            switch event.event{
            case "newmessage":
                if let result = data as? Dictionary<String, AnyObject> {
                    let result = JSON(result)
                    QiscusPusherClient.processDataFromPusher(json: result)
                }
                break
            default: break
            }
        })
    }
    open class func processDataFromPusher(json: JSON){
        if json != nil {
            let notifTopicId = QiscusComment.getCommentTopicIdFromJSON(json)
            let commentBeforeId = QiscusComment.getCommentBeforeIdFromJSON(json)
            let commentId = QiscusComment.getCommentIdFromJSON(json)
            let qiscusService = QiscusCommentClient.sharedInstance
            let senderAvatarURL = json["user_avatar"]["avatar"]["url"].stringValue
            let senderName = json["username"].stringValue
            let isSaved = QiscusComment.getCommentFromJSON(json, topicId: notifTopicId, saved: true)
            
            if isSaved {
                let newMessage = QiscusComment.getCommentById(commentId)
                if !QiscusComment.isValidCommentIdExist(commentBeforeId) {
                    qiscusService.syncMessage(notifTopicId)
                }else{
                    newMessage?.updateCommentIsSync(true)
                }
                if qiscusService.commentDelegate != nil{
                    qiscusService.commentDelegate?.gotNewComment([newMessage!])
                }
                if qiscusService.roomDelegate != nil{
                    qiscusService.roomDelegate?.gotNewComment(newMessage!)
                }
                var showToast = true
                if QiscusChatVC.sharedInstance.isPresence && QiscusChatVC.sharedInstance.topicId == notifTopicId {
                    showToast = false
                }

                if showToast && Qiscus.sharedInstance.inAppNotif {
                    if let window = UIApplication.shared.keyWindow{
                        if let currenRootView = window.rootViewController as? UINavigationController{
                            let viewController = currenRootView.viewControllers[currenRootView.viewControllers.count - 1]
                            
                            QToasterSwift.toast(target: viewController, text: newMessage!.commentText, title:senderName, iconURL:senderAvatarURL, iconPlaceHolder:Qiscus.image(named:"avatar"), onTouch: {
                                    Qiscus.chat(withTopicId: notifTopicId, target: viewController)
                                
                                }
                            )
                            
                        }
                    }
                }
            }
        }
    }

}

class PusherSubscriber: NSObject {
    var event:String = ""
    var channel:String = ""
    var type:Bool = true
    
    class func createNew(_ event:String, channel:String, type:Bool = true)->PusherSubscriber{
        let subscribe = PusherSubscriber()
        subscribe.event = event
        subscribe.channel = channel
        subscribe.type = type
        
        return subscribe
    }
}
