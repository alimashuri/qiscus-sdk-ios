//
//  ViewController.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/27/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
