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
import SwiftMessages
import Haptica
import SPAlert

class BannerHelper {
    
    private static func defaultConfig(seconds: Double = 1.0) -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        
        config.presentationStyle = .center
        config.duration = .seconds(seconds: TimeInterval(seconds))
        config.dimMode = .color(color: UIColor.clear, interactive: false)
        config.presentationContext = .window(windowLevel: .statusBar)
        
//        if let controller = getAppDelegate().window?.rootViewController {
//            config.presentationContext = .viewController(controller)
//        }
        
        return config
    }
    
    static func error(_ message: String, seconds: Double = 1.8, vibrate: HapticFeedbackType? = HapticFeedbackType.error, icon: String = "😟", callback: (() -> Void)? = nil) {
        error(NSAttributedString(string: message), seconds: seconds, vibrate: vibrate, icon: icon, callback: callback)
    }
    
    private static var keyWindow: UIWindow { return UIApplication.shared.keyWindow ?? UIWindow() }
    
    static func error(_ message: NSAttributedString, seconds: Double = 1.8, vibrate: HapticFeedbackType? = HapticFeedbackType.error, icon: String = "😟", callback: (() -> Void)? = nil) {
        
//        let alertView = SPAlertView(title: "Added to Library", message: nil, preset: .done)
//        alertView.duration = seconds
        
        
//        alertView.present()
//        let con = alertView.bottomAnchor.constraint(equalTo: alertView.superview!.bottomAnchor, constant: 260)
        
//        alertView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
//        alertView.center = CGPoint.init(x: 0, y: 0)
//        alertView.removeConstraints(alertView.constraints)
//        alertView.centerYAnchor.constraint(equalTo: alertView.superview!.centerYAnchor, constant: 400).isActive = true
//        alertView.layoutIfNeeded()
        
        
        
//        alertView.bottomAnchor.constraint(equalTo: alertView.superview!.bottomAnchor, constant: 260).isActive = true
        
        
        if let vibrate = vibrate {
            Haptic.notification(vibrate).generate()
        }

        let config = defaultConfig(seconds: seconds)

        let nib = UINib(nibName: "CenteredBanner", bundle: Bundle.main)
        let view = (nib.instantiate(withOwner: nil, options: nil)[0] as? MessageView)!

        view.iconLabel?.text = icon
        view.titleLabel?.attributedText = message

        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)

        if let dismissing = callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                dismissing()
            }
        }
    }
    
    static func success(_ message: String, seconds: Double = 1.0, vibrate: HapticFeedbackType? = HapticFeedbackType.success, icon: String = "👍") {
        success(NSAttributedString(string: message), seconds: seconds, vibrate: vibrate, icon: icon)
    }
    
    static func success(_ message: NSAttributedString, seconds: Double = 1.0, vibrate: HapticFeedbackType? = HapticFeedbackType.success, icon: String = "👍") {
        if let vibrate = vibrate {
            Haptic.notification(vibrate).generate()
        }
        
        let config = defaultConfig(seconds: seconds)
        
        let nib = UINib(nibName: "CenteredBanner", bundle: Bundle.main)
        let view = (nib.instantiate(withOwner: nil, options: nil)[0] as? MessageView)!
        
        view.iconLabel?.text = icon
        view.titleLabel?.attributedText = message
        
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
    }
    
    static func boldText(_ boldText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 18)
        
        let attributedString = NSMutableAttributedString(string: boldText, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (boldText as NSString).range(of: boldText)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    static func boldText(_ allText: String, boldText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 18)
        
        let attributedString = NSMutableAttributedString(string: allText, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (allText as NSString).range(of: boldText)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
}
