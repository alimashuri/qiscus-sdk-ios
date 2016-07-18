//
//  QProgressData.swift
//  LinkDokter
//
//  Created by Qiscus on 2/29/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public class QProgressData: NSObject {
    public var indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    public var progress:CGFloat = 0
    public var localImage:UIImage = UIImage()
    public var url:String = ""
    public var comment:QiscusComment = QiscusComment()
    public var file:QiscusFile = QiscusFile()
    public var isVideoFile:Bool = false
}
