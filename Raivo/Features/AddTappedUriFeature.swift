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
import MessageUI
import OneTimePassword

class AddTappedUriFeature {
    
    /// The singleton instance for the AddTappedUriFeature
    public static let shared = AddTappedUriFeature()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// If this singleton instance is currently busy with running the feature
    private var alertIsActive: Bool = false

    /// The alert that will be shown to the user
    private var alert: UIAlertController? = nil
    
    /// The actual token that could be added
    private var tappedToken: Token? = nil
    
    /// Notify the user about the tapped `otpauth` URI and ask if it may be added
    ///
    /// - Parameter sender: The sending controller that triggered this feature
    public func notify(on sender: UITabBarController) {
        // Only one alert at a time
        guard !alertIsActive else {
            return
        }
        
        // Make sure there actually is a URI that was tapped
        guard let uri = getAppDelegate().tappedLaunchUri else {
            getAppDelegate().tappedLaunchUri = nil
            return
        }
        
        // If this is an empty URI, just return and show the main screen
        if uri.absoluteString == "otpauth://" {
            getAppDelegate().tappedLaunchUri = nil
            return
        }
        
        tappedToken = TokenHelper.shared.getTokenFromUri(uri)
        
        // Check if the URI is a valid `otpauth` URI
        guard tappedToken != nil else {
            getAppDelegate().tappedLaunchUri = nil
            return BannerHelper.shared.error("Format invalid", "The link is not a valid one-time password", duration: 3.0)
        }
        
        alertIsActive = true
        
        alert = UIAlertController(title: "Tippy taps!", message: "Do you want to add \(tappedToken!.issuer)?", preferredStyle: UIAlertController.Style.alert)
        alert!.addAction(UIAlertAction(title: "Add", style: .default, handler: onAdd))
        alert!.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: onDismiss))
        sender.present(alert!, animated: true, completion: nil)
    }
    
    /// Triggers when a user taps 'add' on the alert
    ///
    /// - Parameter action: The action that was tapped
    func onAdd(action: UIAlertAction) {
        let password = TokenHelper.shared.getPasswordFromToken(token: tappedToken!)
        
        autoreleasepool {
            if let realm = RealmHelper.shared.getRealm() {
                try! realm.write {
                    realm.add(password, update: .modified)
                }
            }
        }
        
        BannerHelper.shared.done("Created", "The one-time password was added", duration: 3.0)
        
        getAppDelegate().tappedLaunchUri = nil
        tappedToken = nil
        alertIsActive = false
    }
    
    /// Triggers when a user taps 'dismiss' on the alert
    ///
    /// - Parameter action: The action that was tapped
    func onDismiss(action: UIAlertAction) {
        alert?.dismiss(animated: true, completion: nil)
        getAppDelegate().tappedLaunchUri = nil
        
        alertIsActive = false
    }
    
}
