//
//  ChatTapRecognizer.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

class ChatTapRecognizer: UITapGestureRecognizer {
    var fileLocalPath: String = ""
    var fileName:String = ""
    var fileType:QFileType = .Media
    var fileURL:String = ""
}
