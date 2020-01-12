//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import UIKit

/// An input field for passcodes
@IBDesignable
class UIPasscodeField: UIView, UITextFieldDelegate {
    
    /// The amount of digits to enter
    @IBInspectable
    public var length: Int = 6
    
    /// The width of the digit wrapper (this allows spacing between different UIDigitFields)
    @IBInspectable
    public var digitWrapperWidth: CGFloat = 40
    
    /// The width of the actual UIDigitFields
    @IBInspectable
    public var digitWidth: CGFloat = 20
    
    /// The delegate that allows you to bind to e.g. the on completion listener
    public var delegate: UIPasscodeFieldDelegate? = nil
    
    /// A shadow/mirror (hidden) text field that the user is actually typing into
    private var shadow: UITextField? = nil
    
    /// If positive, no edits will be allowed in the shadow/mirror field (but it will stay the first responder)
    public var completed: Bool = false
    
    /// Always set to the latest passcode that was entered by the user (possibly incomplete)
    public private(set) var current: String = ""
    
    /// The UIDigitFields that are added on initialization
    private var digits: [Int: UIDigitField] = [:]
    
    /// The `shadowAccessibilityIdentifier` is linked to the `accessibilityIdentifier` of the shadow field
    public var shadowAccessibilityIdentifier: String? {
        get {
            return shadow?.accessibilityIdentifier
        }
        set {
            shadow?.accessibilityIdentifier = newValue
        }
    }
    
    /// Initialize the current UIView using a frame
    ///
    /// - Parameter frame: The frame to use
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Initialzie the current UIView using a coder
    ///
    /// - Parameter aDecoder: The coder to use
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// A function that is ran by all public initializers
    private func commonInit() {
        addShadow()
        addDigits()
    }
    
    /// Reset the passcode view to its initial state (revert any text that was entered)
    public func reset() {
        for position in 1...length {
            digits[position]?.value = nil
        }
        
        shadow?.text = ""
        completed = false
    }
    
    /// Adjust all of the subviews to the new parent dimensions
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        for position in 1...length {
            digits[position]?.frame = getRectAtPosition(position)
            digits[position]?.layoutIfNeeded()
        }
    }
    
    /// If the UIPasscodeField has to become the first responder, we actually want to focus on the shadow UITextField.
    ///
    /// - Returns: Positive if this object is now the first-responder or negative if it is not
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return shadow!.becomeFirstResponder()
    }
    
    /// If the UIPasscodeField has to resign as the first responder, we actually want to resign the shadow UITextField.
    ///
    /// - Returns: Positive if this object resigned as the first-responder or negative if it did not
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return shadow!.resignFirstResponder()
    }
    
    /// Add all the UIDigitFields to the subview
    private func addDigits() {
        for position in 1...length {
            let digit = UIDigitField(size: digitWidth)
            
            digit.frame = getRectAtPosition(position)
            digits[position] = digit
            
            addSubview(digit)
        }
    }
    
    /// Calculate the position of a certain UIDigitField and return its frame
    ///
    /// - Parameter position: The position of the digit (e.g. 1...6)
    /// - Returns: The frame to use so that it is shown on the correct position in the view
    private func getRectAtPosition(_ position: Int) -> CGRect {
        let parentWidth = layer.bounds.size.width
        let parentHeight = layer.bounds.size.height
                
        let totalWidth = digitWrapperWidth * CGFloat(length)
        let horizontalPadding = (parentWidth - totalWidth) / 2
        
        let horizontalOffset = horizontalPadding + (CGFloat(position - 1) * digitWrapperWidth)
        
        return CGRect(
            x: horizontalOffset,
            y: 0.0,
            width: digitWrapperWidth,
            height: parentHeight
        )
    }
    
    /// Add the shadow/mirror UITextField to enable user input
    ///
    /// - Note: For UITests, the `CGRect` must be at least 1x1 in order to simulate `typeText`.
    private func addShadow() {
        let invisibleFrame = CGRect(x: -10.0, y: -10.0, width: 1.0, height: 1.0)
        
        shadow = UIPasscodeShadowField(frame: invisibleFrame)
        shadow!.delegate = self
        
        addSubview(shadow!)
    }
    
    /// Check if a certain character is a backspace character
    ///
    /// - Parameter string: The character to check
    /// - Returns: Positive if it is a backspace
    private func isBackspace(_ string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let charachterNumber = strcmp(char, "\\b")
            if (charachterNumber == -92) {
                return true
            }
        }
        
        return false
    }
    
    /// Triggers when the user inputs a character in the shadow/mirror UITextField
    ///
    /// - Parameter textField: The shadow UITextField
    /// - Parameter range: The range of the character that changed
    /// - Parameter string: The new character
    /// - Returns: Positive if it's allowed to change/continue
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldLength = (textField.text?.count ?? 0)
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        let oldText: NSString = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        let isAddition = !isBackspace(string) && newLength >= oldLength
        
        // Passcode was already entered
        guard !completed else {
            return false
        }
        
        // The addition was not a number
        guard !isAddition || Int(string) != nil else {
            return false
        }
        
        // Can't add number, already entered all digits
        guard !isAddition || newLength <= length else {
            return false
        }
        
        if isAddition {
            digits[newLength]?.value = Int(string)
        } else {
            digits[oldLength]?.value = nil
        }
        
        current = newText
        delegate?.onPasscodeChange(passcode: newText)
        
        if newLength == length {
            completed = true
            delegate?.onPasscodeComplete(passcode: newText)
            return false
        }
        
        return true
    }
    
}
