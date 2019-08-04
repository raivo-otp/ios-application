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

class BannerHelper {
    
    private static func defaultConfig(seconds: Double = 1.0) -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .seconds(seconds: TimeInterval(seconds))
        config.dimMode = .gray(interactive: true)
        
        return config
    }
    
    static func error(_ message: String, seconds: Double = 2.0, vibrate: HapticFeedbackType? = HapticFeedbackType.error) {
        error(NSAttributedString(string: message), seconds: seconds, vibrate: vibrate)
    }
    
    static func error(_ message: NSAttributedString, seconds: Double = 2.0, vibrate: HapticFeedbackType? = HapticFeedbackType.error) {
        if let vibrate = vibrate {
            Haptic.notification(vibrate).generate()
        }
        
        let config = defaultConfig(seconds: seconds)
        
        let nib = UINib(nibName: "CenteredBanner", bundle: Bundle.main)
        let view = (nib.instantiate(withOwner: nil, options: nil)[0] as? MessageView)!
        
        view.configureTheme(backgroundColor: UIColor.getBackgroundTransparent(), foregroundColor: UIColor.getTintRed(), iconImage: .none, iconText: .none)
        view.titleLabel?.attributedText = message
        
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
    }
    
    static func success(_ message: String, seconds: Double = 1.0, vibrate: HapticFeedbackType? = HapticFeedbackType.success) {
        success(NSAttributedString(string: message), seconds: seconds, vibrate: vibrate)
    }
    
    static func success(_ message: NSAttributedString, seconds: Double = 1.0, vibrate: HapticFeedbackType? = HapticFeedbackType.success) {
        if let vibrate = vibrate {
            Haptic.notification(vibrate).generate()
        }
        
        let config = defaultConfig(seconds: seconds)
        
        let nib = UINib(nibName: "CenteredBanner", bundle: Bundle.main)
        let view = (nib.instantiate(withOwner: nil, options: nil)[0] as? MessageView)!
        
        view.configureTheme(backgroundColor: UIColor.getBackgroundTransparent(), foregroundColor: UIColor.getTintRed(), iconImage: .none, iconText: .none)
        view.titleLabel?.attributedText = message
        
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
    }
    
    static func boldText(_ boldText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 16)
        
        let attributedString = NSMutableAttributedString(string: boldText, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (boldText as NSString).range(of: boldText)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    static func boldText(_ allText: String, boldText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 16)
        
        let attributedString = NSMutableAttributedString(string: allText, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (allText as NSString).range(of: boldText)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
}
