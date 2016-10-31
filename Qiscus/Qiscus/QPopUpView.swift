//
//  QPopUpView.swift
//  Example
//
//  Created by Ahmad Athaullah on 10/31/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class QPopUpView: UIViewController {

    var sharedInstance = QPopUpView()
    
    var text:String = ""
    var image:UIImage?
    var isVideo:Bool = false
    var attributedText:NSMutableAttributedString?
    
    var firstAction:(()->Void) = {}
    var secondAction:(()->Void) = {}
    var singleAction:(()->Void) = {}
    
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView:UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func firstButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.firstAction()
    }

    @IBAction func secondButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.secondAction()
    }
    @IBAction func singleButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.singleAction()
    }

}
