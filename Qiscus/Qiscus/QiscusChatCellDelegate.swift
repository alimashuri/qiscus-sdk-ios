//
//  QiscusChatCellDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/21/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

@objc public protocol QiscusChatCellDelegate {
    func didTapMediaCell(_ mediaLocalPath:URL, mediaName:String)
    @objc optional func didTapTextCell(_ message:String)
    @objc optional func didTapDocumentFile(_ fileURL:URL, fileName:String)
}
