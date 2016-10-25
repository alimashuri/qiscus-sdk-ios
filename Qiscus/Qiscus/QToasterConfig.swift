//
//  QToasterConfig.swift
//  this class is default configuration and helper class and helper for QToasterSwift
//  QToasterSwift
//
//  Created by Ahmad Athaullah on 7/4/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class QToasterConfig: NSObject {
    
    class var textFont:UIFont{
        get{
            return UIFont.systemFont(ofSize: 11.0)
        }
    }
    class var titleFont:UIFont{
        get{
            return UIFont.systemFont(ofSize: 11.0, weight: 0.8)
        }
    }
    
    class var backgroundColor:UIColor{
        get{
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        }
    }
    class var textColor:UIColor{
        get{
            return UIColor.white
        }
    }
    class var iconBackgroundColor:UIColor{
        get{
            return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
    
    class var animateDuration:TimeInterval{
        get{
            return 0.2
        }
    }
    class var delayDuration:TimeInterval{
        get{
            return 3.0
        }
    }
    
    class var iconSquareSize:CGFloat{
        get{
            return 35.0
        }
    }
    class var iconCornerRadius:CGFloat{
        get{
            return 3.0
        }
    }
    class var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    class var statusBarHeight:CGFloat{
        get{
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    class func textSize(text: NSString, font: UIFont, maxWidth: CGFloat)->CGSize{
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil) as CGRect
        return rect.size
    }
    
    //  func imageForUrl
    //  taken from : ImageLoader.swift
    //  extension
    //
    //  Created by Nate Lyman on 7/5/14.
    //  git: https://github.com/natelyman/SwiftImageLoader
    //  Copyright (c) 2014 NateLyman.com. All rights reserved.
    //
    class func imageForUrl(urlString: String, header: [String : String] = [String : String](), completionHandler:@escaping (_ image: UIImage?, _ url: String) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            let cache = NSCache<AnyObject,AnyObject>()
            let data: Data? = cache.object(forKey: urlString as AnyObject) as? Data
            
            if let goodData = data {
                let image = UIImage(data: goodData)
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler(image, urlString)
                })
                return
            }
            
            if header.count > 0 {
                let url = URL(string: urlString)
                var request = URLRequest(url: url!)
                
                for (key,value) in header {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                let downloadTask:URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if (error != nil) {
                        completionHandler(nil, urlString)
                        return
                    }
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
                        DispatchQueue.main.async(execute: { () -> Void in
                            completionHandler(image, urlString)
                        })
                        return
                    }
                })
                downloadTask.resume()
            }else{
                let downloadTask:URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler:  {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if (error != nil) {
                        completionHandler(nil, urlString)
                        return
                    }
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
                        DispatchQueue.main.async(execute: { () -> Void in
                            completionHandler(image, urlString)
                        })
                        return
                    }
                })
                downloadTask.resume()
            }
        }
    }
}
