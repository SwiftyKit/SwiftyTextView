//
//  NiceTextView.swift
//  NiceTextView
//
//  Created by John on 07/06/2017.
//  Copyright © 2017 com.sherry.NiceTextView. All rights reserved.
//

import UIKit

class SwiftyTextView: UITextView {

    /**
     * 自定义区域 ------ Start
     */
    
    var placeholderColor: UIColor = UIColor.lightGray // placeholder的字体颜色
    
    var placeholder: String = "请输入处理备注" // placeholder的内容
    
    var minNumberOfWords = 0 // 默认从0开始计数
    
    var maxNumberOfWords = 30 // 默认最多输入30个字
    
    var showTextCountView: Bool = true
    
    /**
     * 自定义区域 ------ End
     */
    
    var textLayer: CATextLayer!
    
    var countdownTextLayer: CATextLayer!
    
    weak var swiftyDelegate: SwiftyTextViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if textLayer == nil {
            
            textLayer = CATextLayer()
            
            textLayer.contentsScale = UIScreen.main.scale
            
            textLayer.alignmentMode = kCAAlignmentLeft
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.foregroundColor = placeholderColor.cgColor
            textLayer.font = font
            textLayer.fontSize = font!.pointSize
            
            textLayer.string = placeholder
            textLayer.frame = CGRect(origin: CGPoint(x: 5, y: bounds.minY + 8), size: bounds.size)
            
            layer.insertSublayer(textLayer, at: 0)
        }
        
        if showTextCountView {
        
            if countdownTextLayer == nil {
                
                countdownTextLayer = CATextLayer()
                
                countdownTextLayer.contentsScale = UIScreen.main.scale
                
                countdownTextLayer.alignmentMode = kCAAlignmentRight
                countdownTextLayer.backgroundColor = UIColor.clear.cgColor
                countdownTextLayer.foregroundColor = placeholderColor.cgColor
                countdownTextLayer.font = font
                countdownTextLayer.fontSize = font!.pointSize
                
                
                let tempLabel = UILabel()
                let tempText = "\(maxNumberOfWords)/\(maxNumberOfWords)"
                
                tempLabel.text = tempText
                tempLabel.font = font
                tempLabel.sizeToFit()
                
                countdownTextLayer.frame = tempLabel.frame
                
                countdownTextLayer.string = "\(minNumberOfWords)/\(maxNumberOfWords)"
                
                layer.addSublayer(countdownTextLayer)
            }
            
            countdownTextLayer.frame.origin = CGPoint(x: bounds.size.width - countdownTextLayer.bounds.size.width, y: bounds.size.height - countdownTextLayer.bounds.size.height + contentOffset.y)
        }
        
        delegate!.textViewDidChange!(self)
    }
}

extension SwiftyTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard showTextCountView == true else {
            return
        }
        
        // 因为要处理中文输入，所以这个计数放到textViewDidChange了
        countdownTextLayer.string = "\(text.count)/\(maxNumberOfWords)"
        
        textLayer.isHidden = text.count > 0
        
        if let delegate = swiftyDelegate, delegate.responds(to: #selector(SwiftyTextViewDelegate.textViewDidChange(_:))) {
            delegate.textViewDidChange!(textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var result: Bool = true
        let oldText = textView.text as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        if let delegate = swiftyDelegate, delegate.responds(to: #selector(SwiftyTextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))) {
            result = delegate.textView!(textView, shouldChangeTextIn: range, replacementText: text)
        }

        guard showTextCountView == true else {
            return result
        }
        
        if newText.count > maxNumberOfWords {
            return false
        } else {
            return result
        }

    }
}


//MARK: -
//MARK: delegate


@objc public protocol SwiftyTextViewDelegate: NSObjectProtocol {
    
    
    @objc optional func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
 
    @objc optional func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    
    @objc optional func textViewDidBeginEditing(_ textView: UITextView)
    
    @objc optional func textViewDidEndEditing(_ textView: UITextView)
    
    
    @objc optional func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    
    @objc optional func textViewDidChange(_ textView: UITextView)
    
    @objc optional func textViewDidChangeSelection(_ textView: UITextView)
    
    @objc optional func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool
    
}

