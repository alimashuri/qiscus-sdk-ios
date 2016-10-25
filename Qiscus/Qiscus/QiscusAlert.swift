//
//  QAlert.swift
//  LinkDokter
//
//  Created by QiscusDev on 11/25/15.
//  Copyright © 2015 qiscus. All rights reserved.
//  Inspire by Jay Stakelon / https://github.com/stakes and
//  by Victor Radchenko https://github.com/vikmeup/SCLAlertView-Swift
//

import UIKit

class QiscusAlert: UIViewController, UIGestureRecognizerDelegate {
    //var helper = HDViewHelper()
    var containerView:UIView!
    var alertBackgroundView:UIView!
    
    var target:UIViewController?
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
    var dismissButton:UIButton!
    var cancelButton:UIButton!
    
    var inputTextField:UITextField!
    var inputTextFieldValue:String!
    
    var titleLabel:UILabel!
    var textView:UITextView!
    var buttonLabel:UILabel!
    var cancelButtonLabel:UILabel!
    
    var iconImageView:UIImageView!
    var iconImage:UIImage!
    var imagePath:URL?
    var isInputfieldEnable: Bool = false
    
    weak var rootViewController:UIViewController!
    
    enum FontType {
        case title, text, button
    }
    var titleFont = "Lato-Bold"
    var textFont = "Lato-Regular"
    var buttonFont = "Lato-Bold"
    
    var listTextView: [UITextView]!
    
    enum TextColorTheme {
        case dark, light, lightWithDarkButton
    }
//    
//    var defaultColor = UIColor.hexColor(0xF2F4F4, alpha: 1)
//    var darkTextColor = UIColor.hexColor(0x000000,alpha: 0.75)
//    var lightTextColor = UIColor.hexColor(0xffffff, alpha: 0.9)
    
    var defaultColor = UIColor(red: 242/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
    var darkTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
    var lightTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)

    
    var closeAction:((String)->Void)!
    var imageAction:((UIImage?,String,URL?,Data?)->Void)?
    var imageName:String = ""
    var cancelAction:(()->Void)!
    var imageData:Data?
    
    enum ActionType {
        case close, cancel
    }
    var isAlertOpen:Bool = false
    
    let baseHeight:CGFloat = 160.0
    var alertWidth:CGFloat = 270.0
    let buttonHeight:CGFloat = 40.0
    let padding:CGFloat = 30.0
    
    // Allow alerts to be closed/renamed in a chainable manner
    class JSSAlertViewResponder {
        let alertview: QiscusAlert
        var target: UIViewController?
        
        init(alertview: QiscusAlert) {
            self.alertview = alertview
        }
        
        func addAction(_ action: @escaping (String)->Void) {
            self.alertview.addAction(action)
        }
        
        func addImageAction(_ action: @escaping (UIImage?,String,URL?,Data?)->Void){
            self.alertview.addImageAction(action)
        }
        
        func addCancelAction(_ action: @escaping ()->Void) {
            self.alertview.addCancelAction(action)
        }
        
        func setTitleFont(_ fontStr: String) {
            self.alertview.setFont(fontStr, type: .title)
        }
        
        func setTextFont(_ fontStr: String) {
            self.alertview.setFont(fontStr, type: .text)
        }
        
        func setButtonFont(_ fontStr: String) {
            self.alertview.setFont(fontStr, type: .button)
        }
        
        func setTextTheme(_ theme: TextColorTheme) {
            self.alertview.setTextTheme(theme)
        }
        func setDismissButtonColor(_ color: UIColor){
            self.alertview.setDismissButtonColor(color)
        }
        func listTextViewArray(_ listText: [UITextView]){
            self.alertview.listTextView(listText)
        }
        @objc func close() {
            self.alertview.closeView(false)
        }
    }
    
    func setFont(_ fontStr: String, type: FontType) {
        switch type {
        case .title:
            self.titleFont = fontStr
            if let font = UIFont(name: self.titleFont, size: 24) {
                self.titleLabel.font = font
            } else {
                self.titleLabel.font = UIFont.systemFont(ofSize: 24)
            }
        case .text:
            if self.textView != nil {
                self.textFont = fontStr
                if let font = UIFont(name: self.textFont, size: 16) {
                    self.textView.font = font
                } else {
                    self.textView.font = UIFont.systemFont(ofSize: 16)
                }
            }
        case .button:
            self.buttonFont = fontStr
            if let font = UIFont(name: self.buttonFont, size: 24) {
                self.buttonLabel.font = font
            } else {
                self.buttonLabel.font = UIFont.systemFont(ofSize: 24)
            }
        }
        // relayout to account for size changes
        self.viewDidLayoutSubviews()
    }
    
    func setTextTheme(_ theme: TextColorTheme) {
        switch theme {
        case .light:
            recolorText(lightTextColor)
        case .dark:
            recolorText(darkTextColor)
        case .lightWithDarkButton:
            recolorContainerOnly(darkTextColor)
        }
        
    }
    func setDismissButtonColor(_ color: UIColor){
        dismissButton.backgroundColor = color
    }
    func recolorContainerOnly(_ color: UIColor) {
        titleLabel.textColor = color
        if textView != nil {
            textView.textColor = color
        }

    }
    
    func recolorText(_ color: UIColor) {
        titleLabel.textColor = color
        if textView != nil {
            textView.textColor = color
        }
        buttonLabel.textColor = color
        if cancelButtonLabel != nil {
            cancelButtonLabel.textColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = self.screenSize()
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        var yPos:CGFloat = 0.0
        let contentWidth:CGFloat = self.alertWidth - (self.padding*2)
        
        // position the title
        let titleString = titleLabel.text! as NSString
        let titleAttr = [NSFontAttributeName:titleLabel.font]
        let titleSize = CGSize(width: contentWidth, height: 40)
        let titleRect = titleString.boundingRect(with: titleSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: titleAttr, context: nil)
        yPos += padding
        self.titleLabel.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: ceil(titleRect.size.height))
        yPos += ceil(titleRect.size.height) + padding
        
        // position the icon image view, if there is one
        if self.iconImageView != nil {
            self.iconImageView.frame.size = CGSize(width: self.containerView.frame.width/2, height: self.containerView.frame.width/2)
            let centerX = (self.alertWidth-self.iconImageView.frame.width)/2
            self.iconImageView.frame.origin = CGPoint(x: centerX, y: yPos)
            yPos += iconImageView.frame.height + padding
        }
        
        // position text
        if self.textView != nil {
            let textString = textView.text! as NSString
            let textAttr = [NSFontAttributeName:textView.font as AnyObject]
            let realSize = textView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
            let textSize = CGSize(width: contentWidth, height: CGFloat(fmaxf(Float(90.0), Float(realSize.height))))
            let textRect = textString.boundingRect(with: textSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textAttr, context: nil)
            self.textView.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: ceil(textRect.size.height)*2 + 20)
            yPos += ceil(textRect.size.height) + padding
        }
        
        if inputTextField != nil {
            
            self.inputTextField.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: 40)
            
            yPos += 40
        }
        
        // position the buttons
        yPos += self.padding
        
        var buttonWidth = self.alertWidth
        if self.cancelButton != nil {
            buttonWidth = self.alertWidth/2
            self.cancelButton.frame = CGRect(x: 0, y: yPos, width: buttonWidth-0.5, height: self.buttonHeight)
            if self.cancelButtonLabel != nil {
                self.cancelButtonLabel.frame = CGRect(x: self.padding, y: (self.buttonHeight/2) - 15, width: buttonWidth - (self.padding*2), height: 30)
            }
        }
        
        let buttonX = buttonWidth == self.alertWidth ? 0 : buttonWidth
        self.dismissButton.frame = CGRect(x: buttonX, y: yPos, width: buttonWidth, height: self.buttonHeight)
        if self.buttonLabel != nil {
            self.buttonLabel.frame = CGRect(x: self.padding, y: (self.buttonHeight/2) - 15, width: buttonWidth - (self.padding*2), height: 30)
        }
        
        // set button fonts
        if self.buttonLabel != nil {
            buttonLabel.font = UIFont(name: self.buttonFont, size: 15)
        }
        if self.cancelButtonLabel != nil {
            cancelButtonLabel.font = UIFont(name: self.buttonFont, size: 15)
        }
        
        yPos += self.buttonHeight
        
        // size the background view
        self.alertBackgroundView.frame = CGRect(x: 0, y: 0, width: self.alertWidth, height: yPos)
        
        // size the container that holds everything together
        self.containerView.frame = CGRect(x: (self.viewWidth!-self.alertWidth)/2, y: (self.viewHeight! - yPos)/2, width: self.alertWidth, height: yPos)
        
        //        let tap = UITapGestureRecognizer(target: self, action: Selector("cancelButtonTap"))
        //        tap.delegate = self
        //
        //        self.view.addGestureRecognizer(tap)
    }
    
    func info(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        let alertview = self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: QiscusUIConfiguration.sharedInstance.baseColor)
        alertview.setTextTheme(.light)
        alertview.target = viewController;
        return alertview
    }
    
    func success(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        let alertview = self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: QiscusColorConfiguration.sharedInstance.cancelButtonColor)
        alertview.setTextTheme(.lightWithDarkButton)
        alertview.target = viewController;
        alertview.setDismissButtonColor(QiscusUIConfiguration.sharedInstance.baseColor)
        return alertview
    }
    
    func warning(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: UIColor.white)
    }
    
    func danger(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        let alertview = self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: QiscusColorConfiguration.sharedInstance.cancelButtonColor)
        alertview.setTextTheme(.lightWithDarkButton)
        alertview.setDismissButtonColor(QiscusColorConfiguration.sharedInstance.baseColor)
        alertview.target = viewController;
        return alertview
    }
    
    func show(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil, color: UIColor?=nil, iconImage: UIImage?=nil, inputText: String?=nil, imagePath:URL? = nil) -> JSSAlertViewResponder {
        self.target = viewController
        self.rootViewController = viewController.view.window!.rootViewController
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.view.layer.zPosition = 100
        var baseColor:UIColor?
        if let customColor = color {
            baseColor = customColor
        } else {
            baseColor = self.defaultColor
        }
        
        let sz = self.screenSize()
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        self.view.frame.size = sz
        
        // Container for the entire alert modal contents
        self.containerView = UIView()
        self.view.addSubview(self.containerView!)
        
        // Background view/main color
        self.alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = baseColor
        alertBackgroundView.layer.cornerRadius = 4
        alertBackgroundView.layer.masksToBounds = true
        self.containerView.addSubview(alertBackgroundView!)
        
        // Icon
        self.iconImage = iconImage
        if self.iconImage != nil {
            self.iconImageView = UIImageView(image: self.iconImage)
            self.containerView.addSubview(iconImageView)
        }
        self.imagePath = imagePath
        // Title
        self.titleLabel = UILabel()
        titleLabel.textColor = UIColor.darkText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.text = title
        self.containerView.addSubview(titleLabel)
        
        // View text
        if let text = text {
            self.textView = UITextView()
            self.textView.isUserInteractionEnabled = false
            textView.isEditable = false
            textView.textColor = UIColor.darkText
            textView.textAlignment = .center
            textView.font = UIFont.systemFont(ofSize: 13)
            textView.backgroundColor = UIColor.clear
            textView.text = text
            self.containerView.addSubview(textView)
        }
        
        if let inputText = inputText {
            self.isInputfieldEnable = true
            self.inputTextField = UITextField()
            self.inputTextField.layer.borderWidth = 0.7
            self.inputTextField.layer.borderColor = QiscusColorConfiguration.sharedInstance.alertTextColor.cgColor
            self.inputTextField.backgroundColor = QiscusColorConfiguration.sharedInstance.cancelButtonColor
            self.inputTextField.placeholder = inputText
            self.inputTextField.isSecureTextEntry = true
            self.inputTextField.layer.cornerRadius = 3
            self.inputTextField.textAlignment = NSTextAlignment.center
            self.containerView.addSubview(self.inputTextField)
            
            var inputTextFieldFrame = self.inputTextField.frame
            inputTextFieldFrame.origin.x = 13
            inputTextFieldFrame.size.width = self.containerView.frame.size.width - 26
            inputTextFieldFrame.size.height = 40
            
            self.inputTextField.frame = inputTextFieldFrame
        }
        
        // Button
        self.dismissButton = UIButton()
        dismissButton.backgroundColor = QiscusUIConfiguration.sharedInstance.baseColor
        dismissButton.addTarget(self, action: #selector(QiscusAlert.buttonTap), for: .touchUpInside)
        alertBackgroundView!.addSubview(dismissButton)
        // Button text
        self.buttonLabel = UILabel()
        buttonLabel.textColor = UIColor.white
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .center
        if let text = buttonText {
            buttonLabel.text = text
        } else {
            buttonLabel.text = "OK"
            buttonLabel.textColor = UIColor.white
            dismissButton.tintColor = UIColor.white
        }
        dismissButton.addSubview(buttonLabel)
        
        // Second cancel button
        if (cancelButtonText != nil) {
            self.cancelButton = UIButton()
            cancelButton.backgroundColor = UIColor.white
            cancelButton.addTarget(self, action: #selector(QiscusAlert.cancelButtonTap), for: .touchUpInside)
            alertBackgroundView!.addSubview(cancelButton)
            // Button text
            self.cancelButtonLabel = UILabel()
            cancelButtonLabel.alpha = 0.7
            cancelButtonLabel.textColor = UIColor.darkGray
            cancelButtonLabel.numberOfLines = 1
            cancelButtonLabel.textAlignment = .center
            if let text = cancelButtonText {
                cancelButtonLabel.text = text
            } else {
                cancelButtonLabel.text = "CANCEL"
            }
            
            cancelButton.addSubview(cancelButtonLabel)
        }
        
        // Animate it in
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.view.center.x
        self.containerView.center.y = -500
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center = self.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return JSSAlertViewResponder(alertview: self)
    }
    
    func showImage(_ viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil, color: UIColor?=nil, btnOkColor: UIColor?=nil, iconImage: UIImage?=nil, imageName: String?=nil, imagePath:URL? = nil, imageData:Data? = nil) -> JSSAlertViewResponder {
        print("isi ciew ctrl \(viewController.view.window)")
        if(viewController.view.window == nil){
            //If the rootViewController is the controller itself
            self.rootViewController = viewController
        }else{
            self.rootViewController = viewController.view.window!.rootViewController
        }
        self.rootViewController.addChildViewController(self)
        view.layer.zPosition = 100
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        let sz = self.screenSize()
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        self.view.frame.size = sz
        
        // Container for the entire alert modal contents
        self.containerView = UIView()
        self.view.addSubview(self.containerView!)
        
        // Background view/main color
        self.alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = UIColor.white
        alertBackgroundView.layer.cornerRadius = 4
        alertBackgroundView.layer.masksToBounds = true
        self.containerView.addSubview(alertBackgroundView!)
        
        // Icon
        self.iconImage = iconImage
        if self.iconImage != nil {
            self.iconImageView = UIImageView(image: self.iconImage)
            self.iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            self.containerView.addSubview(iconImageView)
        }
        self.imagePath = imagePath
        self.imageData = imageData
        // Title
        self.titleLabel = UILabel()
        titleLabel.textColor = UIColor.darkText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.text = title
        self.containerView.addSubview(titleLabel)
        
        // View text
        if let text = text {
            self.textView = UITextView()
            self.textView.isUserInteractionEnabled = false
            textView.isEditable = false
            textView.textColor = UIColor.darkText
            textView.textAlignment = .center
            textView.font = UIFont.systemFont(ofSize: 13)
            textView.backgroundColor = UIColor.clear
            textView.text = text
            self.containerView.addSubview(textView)
        }
        self.imageName = imageName!
        
        
        // Button
        self.dismissButton = UIButton()
        
        if btnOkColor != nil {
            dismissButton.backgroundColor = btnOkColor
        }else {
            dismissButton.backgroundColor = QiscusUIConfiguration.sharedInstance.baseColor
        }
        dismissButton.addTarget(self, action: #selector(QiscusAlert.buttonTap), for: .touchUpInside)
        alertBackgroundView!.addSubview(dismissButton)
        // Button text
        self.buttonLabel = UILabel()
        buttonLabel.textColor = UIColor.white
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .center
        if let text = buttonText {
            buttonLabel.text = text
        } else {
            buttonLabel.text = "OK"
        }
        dismissButton.addSubview(buttonLabel)
        
        // Second cancel button
        if cancelButtonText != nil {
            self.cancelButton = UIButton()
            cancelButton.backgroundColor = UIColor.white
            cancelButton.addTarget(self, action: #selector(QiscusAlert.cancelButtonTap), for: .touchUpInside)
            alertBackgroundView!.addSubview(cancelButton)
            // Button text
            self.cancelButtonLabel = UILabel()
            cancelButtonLabel.alpha = 0.7
            cancelButtonLabel.textColor = UIColor.darkGray
            cancelButtonLabel.numberOfLines = 1
            cancelButtonLabel.textAlignment = .center
            if let text = cancelButtonText {
                cancelButtonLabel.text = text
            } else {
                cancelButtonLabel.text = "CANCEL"
            }
            
            cancelButton.addSubview(cancelButtonLabel)
        }
        
        // Animate it in
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.view.center.x
        self.containerView.center.y = -500
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center = self.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return JSSAlertViewResponder(alertview: self)
    }

    
    func showList(_ viewController: UIViewController, title: String, text: [String:String]?=[:], buttonText: String?=nil, cancelButtonText: String?=nil, color: UIColor?=nil, iconImage: UIImage?=nil, inputText: String?=nil) -> JSSAlertViewResponder {
//        self.target = viewController
//        self.rootViewController = viewController.view.window!.rootViewController
        if(viewController.view.window == nil){
            //If the rootViewController is the controller itself
            self.rootViewController = viewController
        }else{
            self.rootViewController = viewController.view.window!.rootViewController
        }
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.view.layer.zPosition = 100
        var baseColor:UIColor?
        if let customColor = color {
            baseColor = customColor
        } else {
            baseColor = self.defaultColor
        }
        
        let sz = self.screenSize()
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        self.view.frame.size = sz
        
        // Container for the entire alert modal contents
        self.containerView = UIView()
        self.view.addSubview(self.containerView!)
        
        // Background view/main color
        self.alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = baseColor
        alertBackgroundView.layer.cornerRadius = 4
        alertBackgroundView.layer.masksToBounds = true
        self.containerView.addSubview(alertBackgroundView!)
        
        // Icon
        self.iconImage = iconImage
        if self.iconImage != nil {
            self.iconImageView = UIImageView(image: self.iconImage)
            self.containerView.addSubview(iconImageView)
        }
        
        // Title
        self.titleLabel = UILabel()
        titleLabel.textColor = UIColor.darkText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = title
        self.containerView.addSubview(titleLabel)
        
//        let textView = UITextView()
        let stringTextList = NSMutableAttributedString()
        
        self.textView = UITextView()
        self.textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.textColor = UIColor.gray
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(
            string: text!["call_duration_text"]!
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.gray,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["call_duration_text"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["call_duration_text"]!).length
            )
        )
        stringTextList.append(myMutableString)
                
        myMutableString = NSMutableAttributedString(
            string: text!["call_duration_time"]! + "\n"
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: QiscusUIConfiguration.sharedInstance.baseColor,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["call_duration_time"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["call_duration_time"]!).length
            )
        )
        stringTextList.append(myMutableString)
        
        //=====================================================================
        
        myMutableString = NSMutableAttributedString(
            string: text!["total_expense_text"]!
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.gray,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["total_expense_text"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["total_expense_text"]!).length
            )
        )
        
        stringTextList.append(myMutableString)
        
        //=====================================================================
        
        myMutableString = NSMutableAttributedString(
            string: text!["total_expense_time"]! + "\n"
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: QiscusUIConfiguration.sharedInstance.baseColor,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["total_expense_time"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["total_expense_time"]!).length
            )
        )
        stringTextList.append(myMutableString)
        
        //=====================================================================
        
        myMutableString = NSMutableAttributedString(
            string: text!["current_balance_text"]!
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.gray,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["current_balance_text"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["current_balance_text"]!).length
            )
        )
        
        stringTextList.append(myMutableString)
        
        //=====================================================================
        
        myMutableString = NSMutableAttributedString(
            string: text!["current_balance_time"]! + "\n \n"
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value:QiscusUIConfiguration.sharedInstance.baseColor,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["current_balance_time"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["current_balance_time"]!).length
            )
        )
        stringTextList.append(myMutableString)
        
        //=====================================================================
        
        
        myMutableString = NSMutableAttributedString(
            string: text!["footer"]!
        )
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: UIColor.gray,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["footer"]!).length)
        )
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Lato-Bold", size: 14)!,
            range: NSRange(
                location: 0,
                length: NSString(string: text!["footer"]!).length
            )
        )
        
        stringTextList.append(myMutableString)
        
//        stringTextList += text!["total_expense_text"]!
//        stringTextList += text!["total_expense_time"]!
//        stringTextList += text!["current_balance_text"]!
//        stringTextList += text!["current_balance_time"]!
//        stringTextList += text!["footer"]!
        
//        textView.text = stringTextList
        textView.attributedText = stringTextList
        textView.textAlignment = .center
        
        self.containerView.addSubview(textView)
        
        if let inputText = inputText {
            self.isInputfieldEnable = true
            self.inputTextField = UITextField()
            self.inputTextField.layer.borderWidth = 0.7
            self.inputTextField.layer.borderColor = QiscusColorConfiguration.sharedInstance.alertTextColor.cgColor
            self.inputTextField.backgroundColor = QiscusColorConfiguration.sharedInstance.cancelButtonColor
            self.inputTextField.placeholder = inputText
            self.inputTextField.isSecureTextEntry = true
            self.inputTextField.layer.cornerRadius = 3
            self.inputTextField.textAlignment = NSTextAlignment.center
            self.containerView.addSubview(self.inputTextField)
            
            var inputTextFieldFrame = self.inputTextField.frame
            inputTextFieldFrame.origin.x = 13
            inputTextFieldFrame.size.width = self.containerView.frame.size.width - 26
            inputTextFieldFrame.size.height = 40
            
            self.inputTextField.frame = inputTextFieldFrame
        }
        
        // Button
        self.dismissButton = UIButton()
        dismissButton.backgroundColor = QiscusUIConfiguration.sharedInstance.baseColor
        dismissButton.addTarget(self, action: #selector(QiscusAlert.buttonTap), for: .touchUpInside)
        alertBackgroundView!.addSubview(dismissButton)
        // Button text
        self.buttonLabel = UILabel()
        buttonLabel.textColor = UIColor.white
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .center
        if let text = buttonText {
            buttonLabel.text = text
        } else {
            buttonLabel.text = "OK"
            buttonLabel.textColor = UIColor.white
            dismissButton.tintColor = UIColor.white
        }
        dismissButton.addSubview(buttonLabel)
        
        // Second cancel button
        if (cancelButtonText != nil) {
            self.cancelButton = UIButton()
            cancelButton.backgroundColor = UIColor.white
            cancelButton.addTarget(self, action: #selector(QiscusAlert.cancelButtonTap), for: .touchUpInside)
            alertBackgroundView!.addSubview(cancelButton)
            // Button text
            self.cancelButtonLabel = UILabel()
            cancelButtonLabel.alpha = 0.7
            cancelButtonLabel.textColor = UIColor.darkGray
            cancelButtonLabel.numberOfLines = 1
            cancelButtonLabel.textAlignment = .center
            if let text = cancelButtonText {
                cancelButtonLabel.text = text
            } else {
                cancelButtonLabel.text = "CANCEL"
            }
            
            cancelButton.addSubview(cancelButtonLabel)
        }
        
        // Animate it in
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.view.center.x
        self.containerView.center.y = -500
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center = self.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return JSSAlertViewResponder(alertview: self)
    }
    
    func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func listTextView(_ listText: [UITextView]){
         self.listTextView = listText
    }
    
    func addAction(_ action: @escaping (String)->Void) {
        self.closeAction = action
    }
    
    func addImageAction(_ action: @escaping (UIImage?,String,URL?,Data?)->Void){
        self.imageAction = action
    }
    
    func buttonTap() {
        closeView(true, source: .close);
        
    }
    
    func addCancelAction(_ action: @escaping ()->Void) {
        self.cancelAction = action
    }
    
    func cancelButtonTap() {
        closeView(true, source: .cancel);
    }
    
    func closeView(_ withCallback:Bool, source:ActionType = .close) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center.y = self.view.center.y + self.viewHeight!
            }, completion: { finished in
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.alpha = 0
                    }, completion: { finished in
                        if withCallback {
                            if let action = self.closeAction , source == .close {
                                //MARK TODO - action not always with parameter
                                if self.isInputfieldEnable {
                                    action(self.inputTextField.text!)
                                }else{
                                    action("hello")
                                }
                            }
                            else if let action = self.imageAction , source == .close {
                                //MARK TODO - action not always with parameter
                                if self.isInputfieldEnable {
                                    action(self.iconImage,self.imageName,self.imagePath,self.imageData)
                                }else{
                                    action(self.iconImage,self.imageName,self.imagePath,self.imageData)
                                }
                            }
                            else if let action = self.cancelAction , source == .cancel {
                                action()
                            }
                        }
                        self.removeView()
                })
                
        })
    }
    
    func removeView() {
        isAlertOpen = false
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    
    func screenSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            return CGSize(width: screenSize.height, height: screenSize.width)
        }
        return screenSize
    }
}

//MARK: - Extention

// Extend UIImage with a method to create
// a UIImage from a solid color
//
// See: http://stackoverflow.com/questions/20300766/how-to-change-the-highlighted-color-of-a-uibutton
extension UIImage {
    class func withColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

// For any UIColor and brightness value where darker <1
// and lighter (>1) return an altered UIColor.
//
// See: http://a2apps.com.au/lighten-or-darken-a-uicolor/
func adjustBrightness(_ color:UIColor, amount:CGFloat) -> UIColor {
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var alpha:CGFloat = 0
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        brightness += (amount-1.0)
        brightness = max(min(brightness, 1.0), 0.0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    return color
}
