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

public class QiscusHelper: NSObject {
    public class func properIndexPathOf(comment comment: QiscusComment, inGroupedComment:[[QiscusComment]])-> QiscusIndexPathData{
        
        var i = 0
        let dataIndexPath = QiscusIndexPathData()
        groupDataLoop: for commentGroup in inGroupedComment {
            var j = 0
            var stopSearch = false
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
}
