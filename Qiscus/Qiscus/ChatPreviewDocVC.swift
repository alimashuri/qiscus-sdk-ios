//
//  ChatPreviewDocVC.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/27/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit
import WebKit

open class ChatPreviewDocVC: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    
    var webView = WKWebView()
    var url: String = ""
    var fileName: String = ""
    var progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
    var roomName:String = ""
    
    deinit{
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    // MARK: - UI Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.setTitleWithSubtitle(title: self.roomName, subtitle: self.fileName)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let backButton = self.backButton(self, action: #selector(ChatPreviewDocVC.goBack(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = backButton
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        
        let constraints = [
            NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            
        ]
        view.addConstraints(constraints)
        view.layoutIfNeeded()
        
        self.webView.backgroundColor = UIColor.red
        let openURL = URL(string:  self.url)
        self.webView.load(URLRequest(url: openURL!))
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        self.progressView.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - WebView Delegate
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectSender = object as? WKWebView {
            if (keyPath! == "estimatedProgress") && (objectSender == self.webView) {
                print("progress webview: \(self.webView.estimatedProgress)")
                progressView.isHidden = self.webView.estimatedProgress == 1
                progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            }else{
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish navigation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
        }
    }
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("fail \(error.localizedDescription)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
            //self.setupTableMessage(error.localizedDescription)
        }
    }
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let headerFields = navigationAction.request.allHTTPHeaderFields
        let headerIsPresent:Bool = (headerFields?.keys.map({$0}).contains("Authorization"))!
        
        if headerIsPresent {
            decisionHandler(WKNavigationActionPolicy.allow)
        } else {
            if let headers = QiscusConfig.sharedInstance.requestHeader {
                let req = NSMutableURLRequest(url: navigationAction.request.url!)
                
                
                for (key, header) in headers{
                    req.addValue(header, forHTTPHeaderField: key)
                }
                
                webView.load(req as URLRequest)
                
            }else{
                decisionHandler(WKNavigationActionPolicy.allow)
            }
            
        }
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressView.isHidden = true
    }

    // MARK: - Navigation
    open func goBack(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Custom Component
    open func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let backLabel = UILabel()
        
        backLabel.text = NSLocalizedString("BACK", comment: "Back")
        backLabel.textColor = UIColor.white
        backLabel.font = UIFont.systemFont(ofSize: 12)
        
        let image = UIImage(named: "ic_back", in: Qiscus.bundle, compatibleWith: nil)?.localizedImage()
        backIcon.image = image
        
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 0,width: 10,height: 15)
            backLabel.frame = CGRect(x: 15,y: 0,width: 45,height: 15)
        }else{
            backIcon.frame = CGRect(x: 50,y: 0,width: 10,height: 15)
            backLabel.frame = CGRect(x: 0,y: 0,width: 45,height: 15)
        }
        
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 60,height: 20))
        backButton.addSubview(backIcon)
        backButton.addSubview(backLabel)
        backButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
}
