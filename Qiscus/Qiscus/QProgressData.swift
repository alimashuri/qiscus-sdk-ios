//
//  QProgressData.swift
//  LinkDokter
//
//  Created by Qiscus on 2/29/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

open class QProgressData: NSObject {
    open var indexPath:IndexPath = IndexPath(row: 0, section: 0)
    open var progress:CGFloat = 0
    open var localImage:UIImage = UIImage()
    open var url:String = ""
    open var comment:QiscusComment = QiscusComment()
    open var file:QiscusFile = QiscusFile()
    open var isVideoFile:Bool = false
}
