//
//  ChatPreviewDocVC.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/27/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import WebKit

class ChatPreviewDocVC: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    
    var webView = WKWebView()
    var url: String = ""
    var fileName: String = ""
    var progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
    var roomName:String = ""
    
    deinit{
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.setTitleWithSubtitle(title: self.roomName, subtitle: self.fileName)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let backButton = self.backButton(self, action: #selector(ChatPreviewDocVC.goBack(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = backButton
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        
        let constraints = [
            NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0)
            
        ]
        view.addConstraints(constraints)
        view.layoutIfNeeded()
        
        self.webView.backgroundColor = UIColor.redColor()
        let openURL = NSURL(string:  self.url)
        self.webView.loadRequest(NSURLRequest(URL: openURL!))
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.progressView.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - WebView Delegate
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let objectSender = object as? WKWebView {
            if (keyPath! == "estimatedProgress") && (objectSender == self.webView) {
                print("progress webview: \(self.webView.estimatedProgress)")
                progressView.hidden = self.webView.estimatedProgress == 1
                progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            }else{
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }else{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finish navigation")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.progressView.progress = 0.0
        }
    }
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print("fail \(error.localizedDescription)")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.progressView.progress = 0.0
            //self.setupTableMessage(error.localizedDescription)
        }
    }
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let headerFields = navigationAction.request.allHTTPHeaderFields
        let headerIsPresent:Bool = (headerFields?.keys.map({$0}).contains("Authorization"))!
        
        if headerIsPresent {
            decisionHandler(WKNavigationActionPolicy.Allow)
        } else {
            if let headers = QiscusConfig.sharedInstance.requestHeader {
                let req = NSMutableURLRequest(URL: navigationAction.request.URL!)
                
                
                for (key, header) in headers{
                    req.addValue(header, forHTTPHeaderField: key)
                }
                
                webView.loadRequest(req)
                
            }else{
                decisionHandler(WKNavigationActionPolicy.Allow)
            }
            
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.progressView.hidden = true
    }

    // MARK: - Navigation
    func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Custom Component
    func backButton(target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .ScaleAspectFit
        
        let backLabel = UILabel()
        
        backLabel.text = NSLocalizedString("BACK", comment: "Back")
        backLabel.textColor = UIColor.whiteColor()
        backLabel.font = UIFont.systemFontOfSize(12)
        
        let selfBundles = NSBundle.init(forClass: Qiscus.classForCoder())
        let image = UIImage(named: "ic_back", inBundle: selfBundles, compatibleWithTraitCollection: nil)?.localizedImage()
        backIcon.image = image
        
        
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .LeftToRight {
            backIcon.frame = CGRectMake(0,0,10,15)
            backLabel.frame = CGRectMake(15,0,45,15)
        }else{
            backIcon.frame = CGRectMake(50,0,10,15)
            backLabel.frame = CGRectMake(0,0,45,15)
        }
        
        
        let backButton = UIButton(frame:CGRectMake(0,0,60,20))
        backButton.addSubview(backIcon)
        backButton.addSubview(backLabel)
        backButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
}
