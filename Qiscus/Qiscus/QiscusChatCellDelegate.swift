//
//  QiscusChatCellDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/21/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

@objc public protocol QiscusChatCellDelegate {
    func didTapMediaCell(mediaLocalPath:NSURL, mediaName:String)
    optional func didTapTextCell(message:String)
    optional func didTapDocumentFile(fileURL:NSURL, fileName:String)
}
