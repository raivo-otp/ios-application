//
//  BannerHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 27/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import SwiftMessages

class BannerHelper {
    
    static func show(_ message: NSAttributedString) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .seconds(seconds: TimeInterval(1))
        config.dimMode = .none
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(backgroundColor: ColorHelper.getLightBackground(), foregroundColor: ColorHelper.getTint(), iconImage: .none, iconText: .none)
        view.bodyLabel?.attributedText = message

        view.titleLabel?.isHidden = true
        view.iconLabel?.isHidden = true
        view.iconImageView?.isHidden = true
        view.button?.isHidden = true
        
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
    }
    
    static func attributedText(_ string: String, _ boldString: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 16)

        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
}
