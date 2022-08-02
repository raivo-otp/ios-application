//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit

extension UIViewController {
    
    struct KeyboardStates {
        static var visible: [String: Bool] = [:]
        static var inset: CGFloat? = nil
    }
    
    internal func attachKeyboardConstraint(_ sender: UIViewController) {
        let identifier = id(sender)
        
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillShowNotification, distinctBy: id(self)) { notification in
            self.keyboardWillShow(notification: notification, identifier: identifier)
        }
        
        NotificationHelper.shared.listen(to: UIResponder.keyboardWillHideNotification, distinctBy: id(self)) { notification in
            self.keyboardWillHide(notification: notification, identifier: identifier)
        }
    }
    
    internal func detachKeyboardConstraint(_ sender: UIViewController) {
        NotificationHelper.shared.discard(UIResponder.keyboardWillShowNotification, byDistinctName: id(self))
        NotificationHelper.shared.discard(UIResponder.keyboardWillHideNotification, byDistinctName: id(self))

        keyboardWillHide(notification: nil, identifier: id(sender))
    }
    
    @objc private func keyboardWillShow(notification: Notification, identifier: String) {
        KeyboardStates.visible[identifier] = true
      
        guard let userInfo = notification.userInfo else {
           return
        }
        
        guard var height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        
        guard let keyboardDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        
        guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) else {
            return
        }
        
        if #available(iOS 11.0, *) {
            if KeyboardStates.inset == nil {
                KeyboardStates.inset = view.safeAreaInsets.bottom
            }
            
            height -= KeyboardStates.inset!
        }
        
        additionalSafeAreaInsets.bottom = height
        
        ui {
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
    
    @objc private func keyboardWillHide(notification: Notification?, identifier: String) {
        let currentlyVisible = KeyboardStates.visible[identifier] ?? false
        KeyboardStates.visible[identifier] = false
        KeyboardStates.inset = nil

        guard currentlyVisible != false else {
            // Notification is same as previous one
            return
        }
        
        let keyboardDuration = (notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.6
        
        var options: UIView.AnimationOptions = []
        
        if let keyboardAnimationCurve = (notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue)
        }
        
        additionalSafeAreaInsets.bottom = CGFloat(0)
        
        ui {
            UIView.animate(
                withDuration: keyboardDuration,
                delay: 0,
                options: options,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
    
}
