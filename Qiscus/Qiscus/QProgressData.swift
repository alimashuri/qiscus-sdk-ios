//
//  QProgressData.swift
//  LinkDokter
//
//  Created by Qiscus on 2/29/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public class QProgressData: NSObject {
    var indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var progress:CGFloat = 0
    var localImage:UIImage = UIImage()
    var url:String = ""
    var comment:QiscusComment = QiscusComment()
    var file:QiscusFile = QiscusFile()
    var isVideoFile:Bool = false
}
