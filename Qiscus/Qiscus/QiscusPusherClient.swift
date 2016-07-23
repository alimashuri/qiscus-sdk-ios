//
//  QiscusPusherClient.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/23/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import SwiftyJSON

public class QiscusPusherClient: NSObject {
    
    public class func processDataFromPusher(json json: JSON){
        if json != nil {
            
            let notifTopicId = QiscusComment.getCommentTopicIdFromJSON(json)
            let commentBeforeId = QiscusComment.getCommentBeforeIdFromJSON(json)
            let commentId = QiscusComment.getCommentIdFromJSON(json)
            let qiscusService = QiscusCommentClient.sharedInstance
            
            if QiscusComment.countCommentOntTopic(notifTopicId) > 0{
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
                }
            }
            
        }
    }

}
