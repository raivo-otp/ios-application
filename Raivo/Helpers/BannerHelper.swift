//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import SPAlert
import Haptica
import UIKit

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
        alert.layout.topSpace = 35
        alert.layout.bottomIconSpace = 35
        alert.layout.iconWidth = 65
        alert.layout.iconHeight = 65
        
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
        let alert = SPAlertView(title: title, message: message, preset: .like)
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
    public func error(_ title: String, _ message: String, duration: Double = 3.0, wrapper: UIView? = nil, callback: (() -> Void)? = nil) {
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
