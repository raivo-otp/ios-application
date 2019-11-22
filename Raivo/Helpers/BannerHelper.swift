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
import SPAlert
import Haptica

/// A helper class for managing banners/alerts
class BannerHelper {
    
    /// The singleton instance for the BannerHelper
    public static let shared = BannerHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Show an alert popup and use the haptic feedback of the device accordingly
    ///
    /// - Parameter alert: The SPAlert UIView to use
    /// - Parameter duration: How long the alert will show
    /// - Parameter haptics: The type of haptic feedback to trigger
    /// - Parameter wrapper: The UIView to center this alert in
    /// - Parameter callback: Called after the given duration.
    ///
    /// - ToDo: Figure out why we can only specify the center after calling "layoutIfNeeded"
    private func show(_ alert: SPAlertView, duration: Double, haptics: HapticFeedbackType? = nil, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
        alert.duration = duration
        alert.haptic = .none
        
        if let haptics = haptics {
            Haptic.notification(haptics).generate()
        }
        
        alert.present()
        
        if let wrapper = wrapper {
            alert.layoutIfNeeded()
            alert.center.y -= ((wrapper.safeAreaInsets.bottom - wrapper.safeAreaInsets.top) / 2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            callback?()
        }
    }
    
    /// Show an alert with a checkmark animation
    ///
    /// - Parameter title: The title of the alert
    /// - Parameter message: The subtitle/message of the alert
    /// - Parameter duration: How long the alert will show
    /// - Parameter wrapper: The UIView to center this alert in
    /// - Parameter callback: Called after the given duration.
    public func done(_ title: String, _ message: String, duration: Double = 2.0, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
        let alert = SPAlertView(title: title, message: message, preset: .done)
        show(alert, duration: duration, haptics: .success, wrapper: wrapper, callback: callback)
    }
    
    /// Show an alert with a heart animation
    ///
    /// - Parameter title: The title of the alert
    /// - Parameter message: The subtitle/message of the alert
    /// - Parameter duration: How long the alert will show
    /// - Parameter wrapper: The UIView to center this alert in
    /// - Parameter callback: Called after the given duration.
    public func heart(_ title: String, _ message: String, duration: Double = 2.0, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
        let alert = SPAlertView(title: title, message: message, preset: .heart)
        show(alert, duration: duration, haptics: .success, wrapper: wrapper, callback: callback)
    }
    
    /// Show an alert with an error/cross animation
    ///
    /// - Parameter title: The title of the alert
    /// - Parameter message: The subtitle/message of the alert
    /// - Parameter duration: How long the alert will show
    /// - Parameter wrapper: The UIView to center this alert in
    /// - Parameter callback: Called after the given duration.
    public func error(_ title: String, _ message: String, duration: Double = 2.0, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
        let alert = SPAlertView(title: title, message: message, preset: .error)
        show(alert, duration: duration, haptics: .success, wrapper: wrapper, callback: callback)
    }
    
    /// Show an alert without any icon, just the message
    ///
    /// - Parameter message: The subtitle/message of the alert
    /// - Parameter duration: How long the alert will show
    /// - Parameter wrapper: The UIView to center this alert in
    /// - Parameter callback: Called after the given duration.
    public func message(_ message: String, duration: Double = 2.0, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
        let alert = SPAlertView(message: message)
        show(alert, duration: duration, haptics: .success, wrapper: wrapper, callback: callback)
    }

}
