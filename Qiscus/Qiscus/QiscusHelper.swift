//
//  QiscusHelper.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/22/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public class QiscusIndexPathData: NSObject{
    public var row = 0
    public var section = 0
    public var newGroup:Bool = false
}
public class QiscusSearchIndexPathData{
    public var row = 0
    public var section = 0
    public var found:Bool = false
}
public class QCommentIndexPath{
    public var row = 0
    public var section = 0
}
public class QiscusHelper: NSObject {
    public class func properIndexPathOf(comment comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusIndexPathData{
        
        var i = 0
        let dataIndexPath = QiscusIndexPathData()
        var stopSearch = false
        
        if inGroupedComment.count == 0{
            stopSearch = true
            dataIndexPath.section = inGroupedComment.count
            dataIndexPath.row = 0
            dataIndexPath.newGroup = true
        }
        else if comment.commentBeforeId == 0 {
            stopSearch = true
            let prevComment = QiscusHelper.getLastCommentInGroup(groupComment: inGroupedComment)
            if comment.commentDate == prevComment.commentDate {
                dataIndexPath.section = inGroupedComment.count - 1
                dataIndexPath.row = inGroupedComment[inGroupedComment.count - 1].count
            }else{
                dataIndexPath.section = inGroupedComment.count
                dataIndexPath.row = 0
                dataIndexPath.newGroup = true
            }
        }else{
            groupDataLoop: for commentGroup in inGroupedComment {
                var j = 0
                dataLoop: for commentTarget in commentGroup{
                    if(comment.commentBeforeId == commentTarget.commentId ){
                        if comment.commentDate == commentTarget.commentDate {
                            dataIndexPath.section = i
                            dataIndexPath.row = j + 1
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
                    j += 1
                }
                if stopSearch {
                    break groupDataLoop
                }
                i += 1
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
    
    public class func getIndexPathOfComment(comment comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusSearchIndexPathData{
        
        var i = 0
        let dataIndexPath = QiscusSearchIndexPathData()
        groupDataLoop: for commentGroup in inGroupedComment {
            var j = 0
            var stopSearch = false
            dataLoop: for commentTarget in commentGroup{
                if(comment.commentId == commentTarget.commentId || comment.commentUniqueId == commentTarget.commentUniqueId){
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
    
    public class func getLastCommentInGroup(groupComment groupComment:[[QiscusComment]])->QiscusComment{
        var lastGroup = groupComment[groupComment.count - 1]
        let lastComment = lastGroup[lastGroup.count - 1]
        
        return lastComment
    }
    public class func getLastCommentindexPathInGroup(groupComment groupComment:[[QiscusComment]])->QCommentIndexPath{
        let indexPath = QCommentIndexPath()
        indexPath.section = groupComment.count - 1
        indexPath.row = groupComment[indexPath.section].count - 1
        
        return indexPath
    }
    public class func getNextIndexPathIn(groupComment groupComment:[[QiscusComment]])->QCommentIndexPath{
        var indexPath = QCommentIndexPath()
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        let today = dateFormatter.stringFromDate(date)
        
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
}
