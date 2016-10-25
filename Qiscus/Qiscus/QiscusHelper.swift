//
//  QiscusHelper.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/22/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QiscusIndexPathData: NSObject{
    open var row = 0
    open var section = 0
    open var newGroup:Bool = false
}
open class QiscusSearchIndexPathData{
    open var row = 0
    open var section = 0
    open var found:Bool = false
}
open class QCommentIndexPath{
    open var row = 0
    open var section = 0
}
open class QiscusHelper: NSObject {
    open class func properIndexPathOf(comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusIndexPathData{
        
        var i = 0
        let dataIndexPath = QiscusIndexPathData()
        var stopSearch = false
        
        if inGroupedComment.count == 0{
            stopSearch = true
            dataIndexPath.section = 0
            dataIndexPath.row = 0
            dataIndexPath.newGroup = true
        }
        else if comment.commentBeforeId == 0 {
            stopSearch = true
            let firstComment = inGroupedComment[0][0]
            
            if firstComment.commentId > comment.commentId && comment.commentId > 0{
                dataIndexPath.section = 0
                dataIndexPath.row = 0
                if firstComment.commentDate == comment.commentDate {
                    dataIndexPath.newGroup = false
                }else{
                    dataIndexPath.newGroup = true
                }
            }else{
                let prevComment = QiscusHelper.getLastCommentInGroup(groupComment: inGroupedComment)
                
                if comment.commentDate == prevComment.commentDate {
                    dataIndexPath.section = inGroupedComment.count - 1
                    dataIndexPath.row = inGroupedComment[inGroupedComment.count - 1].count
                }else{
                    dataIndexPath.section = inGroupedComment.count
                    dataIndexPath.row = 0
                    dataIndexPath.newGroup = true
                }
            }
        }else{
            
            let firstComment = inGroupedComment[0][0]
            if firstComment.commentId > comment.commentId && comment.commentId > 0{
                dataIndexPath.section = 0
                dataIndexPath.row = 0
                if firstComment.commentDate == comment.commentDate {
                    dataIndexPath.newGroup = false
                }else{
                    dataIndexPath.newGroup = true
                }
                stopSearch = true
            }else{
                groupDataLoop: for commentGroup in inGroupedComment {
                    var j = 0
                    dataLoop: for commentTarget in commentGroup{
                        if(comment.commentBeforeId == commentTarget.commentId ){
                            if comment.commentDate == commentTarget.commentDate {
                                dataIndexPath.section = i
                                dataIndexPath.row = j+1
                                stopSearch = true
                                break dataLoop
                            }else{
                                dataIndexPath.section = i + 1
                                dataIndexPath.row = 0
                                if i == (inGroupedComment.count - 1) && j == (commentGroup.count - 1){
                                    dataIndexPath.newGroup = true
                                    stopSearch = true
                                    break dataLoop
                                }else{
                                    let nextComment = inGroupedComment[i+1][0]
                                    if comment.commentDate != nextComment.commentDate{
                                        dataIndexPath.newGroup = true
                                    }
                                    stopSearch = true
                                    break dataLoop
                                }
                            }
                        }
                        else{
                            if comment.commentId < commentTarget.commentId {
                                if comment.commentDate == commentTarget.commentDate {
                                    dataIndexPath.row = j
                                    dataIndexPath.section = i
                                    dataIndexPath.newGroup = false
                                    stopSearch = true
                                }else{
                                    var prevComment = QiscusComment()
                                    stopSearch = true
                                    if j == 0 {
                                        let lastRowInPreviousComment = inGroupedComment[i-1].count - 1
                                        prevComment = inGroupedComment[i - 1][lastRowInPreviousComment]
                                        if prevComment.commentDate == comment.commentDate {
                                            dataIndexPath.section = i - 1
                                            dataIndexPath.row = lastRowInPreviousComment + 1
                                            dataIndexPath.newGroup = false
                                        }else{
                                            dataIndexPath.section = i - 1
                                            dataIndexPath.row = 0
                                            dataIndexPath.newGroup = true
                                        }
                                        stopSearch = true
                                    }
                                }
                            }
                        }
                        j += 1
                    }
                    if stopSearch {
                        break groupDataLoop
                    }
                    i += 1
                }
            }
        }
        if !stopSearch{
            let prevComment = QiscusHelper.getLastCommentInGroup(groupComment: inGroupedComment)
            if comment.commentDate == prevComment.commentDate {
                dataIndexPath.section = inGroupedComment.count - 1
                dataIndexPath.row = inGroupedComment[inGroupedComment.count - 1].count
            }else{
                dataIndexPath.section = inGroupedComment.count
                dataIndexPath.row = 0
                dataIndexPath.newGroup = true
            }
        }
        return dataIndexPath
    }
    
    open class func getIndexPathOfComment(comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusSearchIndexPathData{
        
        var i = 0
        let dataIndexPath = QiscusSearchIndexPathData()
        groupDataLoop: for commentGroup in inGroupedComment {
            var j = 0
            var stopSearch = false
            dataLoop: for commentTarget in commentGroup{
                if((comment.commentUniqueId != "") && (comment.commentUniqueId == commentTarget.commentUniqueId) ) || comment.commentId == commentTarget.commentId {
                    dataIndexPath.section = i
                    dataIndexPath.row = j
                    dataIndexPath.found = true
                    stopSearch = true
                    break dataLoop
                }
                j += 1
            }
            if stopSearch {
                break groupDataLoop
            }
            i += 1
        }
        return dataIndexPath
    }
    
    open class func getLastCommentInGroup(groupComment:[[QiscusComment]])->QiscusComment{
        var lastGroup = groupComment[groupComment.count - 1]
        let lastComment = lastGroup[lastGroup.count - 1]
        
        return lastComment
    }
    open class func getLastCommentindexPathInGroup(groupComment:[[QiscusComment]])->QCommentIndexPath{
        let indexPath = QCommentIndexPath()
        indexPath.section = groupComment.count - 1
        indexPath.row = groupComment[indexPath.section].count - 1
        
        return indexPath
    }
    open class func getNextIndexPathIn(groupComment:[[QiscusComment]])->QCommentIndexPath{
        var indexPath = QCommentIndexPath()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        let today = dateFormatter.string(from: date)
        
        if groupComment.count != 0 {
            let lastComment = getLastCommentInGroup(groupComment: groupComment)
            if lastComment.commentDate == today {
                indexPath = getLastCommentindexPathInGroup(groupComment: groupComment)
            }else{
                indexPath.section = groupComment.count
            }
        }
        return indexPath
    }
    class func screenWidth()->CGFloat{
        return UIScreen.main.bounds.size.width
    }
    class func screenHeight()->CGFloat{
        return UIScreen.main.bounds.size.height
    }
    class func statusBarSize()->CGRect{
        return UIApplication.shared.statusBarFrame
    }
    class var thisDateString:String{
        get{
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            
            return dateFormatter.string(from: date)
        }
    }
}
