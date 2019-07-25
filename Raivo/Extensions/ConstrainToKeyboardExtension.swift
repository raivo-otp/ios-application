//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import UIKit

extension UIViewController {
    
    internal func adjustViewToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        for constraint in view.constraints {
            if constraint.identifier == "KeyboardConstraint" {
                return constraint
            }
        }
        
        for element in view.subviews {
            for constraint in element.constraints {
                if constraint.identifier == "KeyboardConstraint" {
                    return constraint
                }
            }
        }
        
        return nil
    }
        
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            var keyboardHeight = keyboardRectangle.height
            
            if #available(iOS 11.0, *) {
                let bottomInset = view.safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            
            getConstraintToAdjustToKeyboard()!.constant = keyboardHeight
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        getConstraintToAdjustToKeyboard()!.constant = CGFloat(0)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension UIView {
    
    @objc public func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.identifier == "KeyboardConstraint" {
                return constraint
            }
        }
        
        return nil
    }
    
    public func adjustConstraintToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            var keyboardHeight = keyboardRectangle.height
            
            if #available(iOS 11.0, *) {
                let bottomInset = safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            
            getConstraintToAdjustToKeyboard()!.constant = keyboardHeight
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
            self.getConstraintToAdjustToKeyboard()!.constant = CGFloat(0)
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}
