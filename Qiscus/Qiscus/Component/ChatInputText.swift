//
//  ChatInputText.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

protocol ChatInputTextDelegate {
    func chatInputTextDidChange(chatInput input:ChatInputText, height: CGFloat)
    func valueChanged(value value:String)
}

class ChatInputText: UITextView, UITextViewDelegate {
    
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
    
    
    override func drawRect(rect: CGRect) {
        print("from coder")
        super.drawRect(rect)
        //self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        print("override init textView executed")
        self.delegate = self
        self.placeholder = ""
        if self.value == "" {
            self.textColor = placeHolderColor
            self.text = placeholder
        }
        self.backgroundColor = UIColor.clearColor()
        self.scrollEnabled = true
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = self.value
        textView.textColor = self.activeTextColor
    }
    func textViewDidEndEditing(textView: UITextView) {
        if value == "" {
            textView.text = self.placeholder
            textView.textColor = self.placeHolderColor
            
        }
    }
    func clearValue(){
        self.value = ""
        self.text = placeholder
        self.textColor = placeHolderColor
    }
    
}
