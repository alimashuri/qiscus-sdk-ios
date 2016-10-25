//
//  QiscusRoomDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/23/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public protocol QiscusRoomDelegate {
    func gotNewComment(_ comments:QiscusComment)
}
