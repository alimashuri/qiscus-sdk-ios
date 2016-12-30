//
//  QChatCellHelper.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/30/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public enum CellTypePosition {
    case single,first,middle,last
}

open class QChatCellHelper: NSObject {
    open class func getCellPosition(ofIndexPath indexPath:IndexPath, inGroupOfComment comments:[[QiscusComment]])->CellTypePosition{
        var cellPos = CellTypePosition.single
        
        let comment = comments[indexPath.section][indexPath.row]
        
        if comments[(indexPath as NSIndexPath).section].count == 1 {
            cellPos = .single
        }else{
            if indexPath.row == 0 {
                let commentAfter = comments[indexPath.section][indexPath.row + 1]
                if (commentAfter.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                    cellPos = .single
                }else{
                    cellPos = .first
                }
            }else if indexPath.row == (comments[indexPath.section].count - 1){
                let commentBefore = comments[indexPath.section][indexPath.row - 1]
                if (commentBefore.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                    cellPos = .single
                }else{
                    cellPos = .last
                }
            }else{
                let commentBefore = comments[indexPath.section][indexPath.row - 1]
                let commentAfter = comments[indexPath.section][indexPath.row + 1]
                if (commentBefore.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                    if (commentAfter.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                        cellPos = .single
                    }else{
                        cellPos = .first
                    }
                }else if (commentAfter.commentSenderEmail as String) != (comment.commentSenderEmail as String){
                    cellPos = .last
                }else{
                    cellPos = .middle
                }
            }
        }
        return cellPos
    }
}
