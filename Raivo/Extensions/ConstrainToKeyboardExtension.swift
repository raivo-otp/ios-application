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
    
    internal func attachKeyboardConstraint() {
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillShowNotification, distinctBy: id(self)) { notification in
            self.keyboardNotification(notification: notification)
        }
        
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillHideNotification, distinctBy: id(self)) { notification in
            self.keyboardNotification(notification: notification)
        }
    }
    
    internal func detachKeyboardConstraint() {
        NotificationHelper.shared.discard(UIResponder.keyboardWillShowNotification, byDistinctName: id(self))
        NotificationHelper.shared.discard(UIResponder.keyboardWillHideNotification, byDistinctName: id(self))
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
    
    @objc private func keyboardNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
           return
        }
        
        guard var keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        
        guard let keyboardDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        
        guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) else {
            return
        }
        
        if #available(iOS 11.0, *) {
            keyboardHeight -= view.safeAreaInsets.bottom
        }
        
        if let tabBarHeight = tabBarController?.tabBar.frame.size.height {
            keyboardHeight += tabBarHeight
        }
        
        let show = notification.name == UIResponder.keyboardWillShowNotification
        let height = show ? keyboardHeight : 0
        
        getConstraintToAdjustToKeyboard()!.constant = height
        
        UIView.animate(
            withDuration: keyboardDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue),
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
}

extension UIView {
    
    public func attachKeyboardConstraint() {
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillShowNotification, distinctBy: id(self)) { notification in
            self.keyboardNotification(notification: notification)
        }
        
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillHideNotification, distinctBy: id(self)) { notification in
            self.keyboardNotification(notification: notification)
        }
    }
    
    internal func detachKeyboardConstraint() {
        NotificationHelper.shared.discard(UIResponder.keyboardWillShowNotification, byDistinctName: id(self))
        NotificationHelper.shared.discard(UIResponder.keyboardWillHideNotification, byDistinctName: id(self))
    }
    
    @objc public func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.identifier == "KeyboardConstraint" {
                return constraint
            }
        }
        
        return nil
    }
    
    @objc private func keyboardNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
           return
        }
        
        guard var keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        
        guard let keyboardDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        
        guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) else {
            return
        }
        
        if #available(iOS 11.0, *) {
            keyboardHeight -= safeAreaInsets.bottom
        }
        
        let show = notification.name == UIResponder.keyboardWillShowNotification
        let height = show ? keyboardHeight : 0
        
        getConstraintToAdjustToKeyboard()!.constant = height
        
        UIView.animate(
            withDuration: keyboardDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue),
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
}
