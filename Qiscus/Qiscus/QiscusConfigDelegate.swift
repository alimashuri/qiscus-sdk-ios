//
//  QiscusConfigDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/8/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public protocol QiscusConfigDelegate {
    func qiscusFailToConnect(withMessage:String)
    func qiscusConnected()
}
