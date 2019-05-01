//
//  KeyboardConstraintViewExtension.swift
//  Raivo
//
//  Created by Tijme Gommers on 01/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    @objc public func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
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
