//
//  SwiftyTextView.swift
//  SwiftyTextView
//
//  Created by SwiftyKit on 07/06/2018.
//  Copyright © 2018 com.swiftykit.SwiftyTextView. All rights reserved.
//

import UIKit

@IBDesignable
public class SwiftyTextView: UITextView {

    /**
     * UI Customization ------ Start
     */
    
    @IBInspectable open var placeholderColor: UIColor = UIColor.lightGray { // placeholder color
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var placeholder: String = "Please input text..." { // placeholder content
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var minNumberOfWords: Int = 0 {// start from 0 by default
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var maxNumberOfWords: Int = 30 { // max num is 30 by default
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var showTextCountView: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /**
     * UI Customization ------ End
     */

    private var placeHolderTextLayer: CATextLayer!
    private var countdownTextLayer: CATextLayer!
    
    public weak var textDelegate: SwiftyTextViewDelegate?
    
    public override var text: String! {
        // boilerplate code needed to make watchers work properly:
        get {
            return super.text
        }
        set {
            super.text = newValue
            NotificationCenter.default.post(
                name: UITextView.textDidChangeNotification,
                object: self)
        }

    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
    
    public init(frame: CGRect = .zero) {
        super.init(frame: frame, textContainer: nil)
        delegate = self
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let defaultFont = font ?? UIFont.systemFont(ofSize: 17.0)
        
        if placeHolderTextLayer == nil {
            placeHolderTextLayer = CATextLayer()
            placeHolderTextLayer.contentsScale = UIScreen.main.scale
            placeHolderTextLayer.alignmentMode = CATextLayerAlignmentMode.left
            placeHolderTextLayer.backgroundColor = UIColor.clear.cgColor
            placeHolderTextLayer.foregroundColor = placeholderColor.cgColor
            placeHolderTextLayer.font = defaultFont
            placeHolderTextLayer.fontSize = defaultFont.pointSize
            
            placeHolderTextLayer.string = placeholder
            placeHolderTextLayer.frame = CGRect(origin: CGPoint(x: 5, y: bounds.minY + 8), size: bounds.size)
            layer.insertSublayer(placeHolderTextLayer, at: 0)
        }
        
        if showTextCountView {
            if countdownTextLayer == nil {
                countdownTextLayer = CATextLayer()
                countdownTextLayer.contentsScale = UIScreen.main.scale
                countdownTextLayer.alignmentMode = CATextLayerAlignmentMode.right
                countdownTextLayer.backgroundColor = UIColor.clear.cgColor
                countdownTextLayer.foregroundColor = placeholderColor.cgColor
                countdownTextLayer.font = defaultFont
                countdownTextLayer.fontSize = defaultFont.pointSize
                
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
        delegate?.textViewDidChange?(self)
    }
}

extension SwiftyTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        placeHolderTextLayer.isHidden = text.count > 0
 
        if showTextCountView {
            countdownTextLayer.string = "\(text.count)/\(maxNumberOfWords)"
        }
        
        textDelegate?.textViewDidChange?(textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var result: Bool = true
        let oldText = textView.text as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        if let delegate = textDelegate, delegate.responds(to: #selector(SwiftyTextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))) {
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
     
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textDelegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textDelegate?.textViewDidEndEditing?(textView)
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return textDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return textDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        placeHolderTextLayer.isHidden = text.count > 0
        textDelegate?.textViewDidChangeSelection?(textView)
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return textDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
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

