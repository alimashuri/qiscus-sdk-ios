//
//  ChatInputText.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

public protocol ChatInputTextDelegate {
    func chatInputTextDidChange(chatInput input:ChatInputText, height: CGFloat)
    func chatInputDidEndEditing(chatInput input:ChatInputText)
    func valueChanged(value:String)
}

open class ChatInputText: UITextView, UITextViewDelegate {
    
    var chatInputDelegate: ChatInputTextDelegate?
    
    var value: String = ""
    var placeHolderColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
    var activeTextColor = UIColor(red: 77/255.0, green: 77/255.0, blue: 77/255.0, alpha: 1.0)
    
    var placeholder: String = ""{
        didSet{
            if placeholder != oldValue && self.value == ""{
                self.text = placeholder
                self.textColor = placeHolderColor
            }
        }
    }
    
    
    override open func draw(_ rect: CGRect) {
        print("from coder")
        super.draw(rect)
        //self.commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit(){
        print("override init textView executed")
        self.delegate = self
        self.placeholder = ""
        if self.value == "" {
            self.textColor = placeHolderColor
            self.text = placeholder
        }
        self.backgroundColor = UIColor.clear
        self.isScrollEnabled = true
    }

    // MARK: - UITextViewDelegate
    open func textViewDidChange(_ textView: UITextView) {
        print("executed textViewDidChange")
        let maxHeight:CGFloat = 85
        let minHeight:CGFloat = 25
        let fixedWidth = textView.frame.width
        
        self.value = textView.text
        self.chatInputDelegate?.valueChanged(value: self.value)
        var newHeight = textView.sizeThatFits(CGSize(width: fixedWidth, height: maxHeight)).height
        
        if newHeight <= 33 {
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        self.chatInputDelegate?.chatInputTextDidChange(chatInput: self, height: newHeight)
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = self.value
        textView.textColor = self.activeTextColor
    }
    open func textViewDidEndEditing(_ textView: UITextView) {
        if value == "" {
            textView.text = self.placeholder
            textView.textColor = self.placeHolderColor
        }
        self.chatInputDelegate?.chatInputDidEndEditing(chatInput: self)
    }
    open func clearValue(){
        self.value = ""
        self.text = placeholder
        self.textColor = placeHolderColor
    }
    
}
