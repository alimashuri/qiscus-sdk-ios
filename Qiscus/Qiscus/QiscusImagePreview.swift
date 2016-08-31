//
//  QiscusImagePreview.swift
//  Example
//
//  Created by Ahmad Athaullah on 8/29/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import QAsyncImageView

public class QiscusImagePreview: UIViewController {

    static let sharedInstance = QiscusImagePreview()
    
    @IBOutlet weak var imageView: UIImageView!
    
    public var imageURL:String = ""
    public var fileName:String = "filename"
    
    private init() {
        super.init(nibName: "QiscusImagePreview", bundle: Qiscus.bundle)
        self.modalPresentationStyle = .OverCurrentContext
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.fileName
        self.navigationController?.hidesBarsOnTap = true
        
        self.imageView.loadAsync(self.imageURL)
        self.imageView.contentMode = .ScaleAspectFit
        //self.navigationController?.
//        self.saveView.layer.cornerRadius = 13
//        self.closeView.layer.cornerRadius = 13
//        self.closeButton.addTarget(self, action: #selector(QiscusImagePreview.close), forControlEvents: .TouchUpInside)
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    public func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
