//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import UIKit
import RealmSwift
import CloudKit
import Eureka
import SwiftMonkeyPaws

/// UI events that were launched from the ApplicationPrincipal
class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    /// Reference to the UIWindow, which is used to set the current controller
    public var window: UIWindow?
    
    /// The name of the current/active storyboard
    public var currentStoryboardName: String? = nil
    
    /// The name of the storyboard that was active before the current one became active
    public var previousStoryboardName: String? = nil
    
    /// Indicating of the application passed the `Load` app state
    public var applicationIsLoaded: Bool = false
    
    /// The last known syncer account identifier (used to check of account changes)
    public var syncerAccountIdentifier: String? = nil
    
    /// Tapped 'otpauth://' URI that launched the application. Temporarily stored because the app is most likely locked.
    public var tappedLaunchUri: URL? = nil
    
    /// The currently active encryption key (available when the app is unlocked)
    private var encryptionKey: Data?
    
    /// The icons effect is cached throughout the runtime to prevent rendering issues
    private var iconsEffect: String? = nil
    
    /// An instance of the monkey testing paws
    private var paws: MonkeyPaws?
    
    /// When the application finished launching
    ///
    /// - Parameter application: The application as passed to `UIApplicationDelegate`
    /// - Parameter launchOptions: The launchOptions as passed to `UIApplicationDelegate`
    /// - Returns: Positive if the url contained in the `launchOptions` was intended for Raivo
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if AppHelper.argumentMonkeyPaws {
            paws = MonkeyPaws(view: window!)
        }
        
        if AppHelper.argumentResetState {
            StateHelper.shared.reset()
        }
        
        setCorrectStoryboard()
        setCorrectTintColor()
                
        // We accept all launch options
        return true
    }
    
    /// Trigger when a user taps a 'otpauth://' URI.
    ///
    /// - Parameter application: The application as passed to `UIApplicationDelegate`
    /// - Parameter url: The URL resource to open. Probably an 'otpauth://' URI.
    /// - Parameter options: A dictionary of URL handling options.
    /// - Returns: If the URI was succesfully handled or not.
    /// - Note We always accept all URLs. They will be validated in a later stage and the user will receive feedback if the link is incorrect.
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        tappedLaunchUri = url
        return true
    }
    
    /// Set the encryption key and update the default realm configuration
    ///
    /// - Parameter encryptionKey: The new encryption key (password + passcode)
    public func updateEncryptionKey(_ encryptionKey: Data?) {
        self.encryptionKey = encryptionKey
        RealmHelper.shared.initDefaultRealmConfiguration(encryptionKey: encryptionKey)
    }
    
    /// Get the currently active encryption key
    ///
    /// - Returns: The active encryption key
    public func getEncryptionKey() -> Data? {
        return encryptionKey
    }
    
    /// Retrieve the cached icons effect that is currently in use. This variable is cached
    /// throughout the entire runtime of the application to prevent rendering issues.
    ///
    /// - Returns: The icons effect
    public func getIconEffect() -> String {
        guard iconsEffect == nil else {
            return iconsEffect!
        }
        
        let userIconsEffect = StorageHelper.shared.getIconsEffect()
        let defaultIconsEffect = MiscellaneousIconsEffectFormOption.OPTION_DEFAULT.value
        
        iconsEffect = userIconsEffect ?? defaultIconsEffect
        
        return getIconEffect()
    }
    
    /// Run functionality that is required before a storyboard change
    ///
    /// - Parameter storyboard: The upcoming storyboard
    private func beforeStoryboardChange(_ storyboard: String) {
        switch storyboard {
        case StateHelper.Storyboard.MAIN:
            // Enable lockscreen timer
            (ApplicationPrincipal.shared as! ApplicationPrincipal).enableInactivityTimer()
            
            // Enable syncer notifications
            SyncerHelper.shared.getSyncer().enable()
            SyncerHelper.shared.getSyncer().resyncModel(id(Password.self))
            UIApplication.shared.registerForRemoteNotifications()
        case StateHelper.Storyboard.LOAD, StateHelper.Storyboard.AUTH:
            // Disable lockscreen timer
            (ApplicationPrincipal.shared as! ApplicationPrincipal).disableInactivityTimer()
            
            // Disable syncer notifications
            UIApplication.shared.unregisterForRemoteNotifications()
        case StateHelper.Storyboard.SETUP:
            // Disable lockscreen timer
            (ApplicationPrincipal.shared as! ApplicationPrincipal).disableInactivityTimer()
            
            // Disable syncer notifications and preload the encryption challenge
            SyncerHelper.shared.getSyncer().preloadChallenge()
            UIApplication.shared.unregisterForRemoteNotifications()
            SyncerHelper.shared.getSyncer().disable()
        case StateHelper.Storyboard.ERROR:
            // Disable lockscreen timer
            (ApplicationPrincipal.shared as! ApplicationPrincipal).disableInactivityTimer()
            
            // Disable syncer notifications
            UIApplication.shared.unregisterForRemoteNotifications()
            SyncerHelper.shared.getSyncer().disable()
        default:
            fatalError("Unknown storyboard!")
        }
    }
    
    /// Update the storyboard to comply with the current state of the application.
    private func setCorrectStoryboard() {
        let storyboardName = StateHelper.shared.getCurrentStoryboard()
        let controllerName = StateHelper.shared.getCurrentStoryboardController()
        
        self.beforeStoryboardChange(storyboardName)
        
        if let current = self.currentStoryboardName {
            self.previousStoryboardName = current
        }
        
        self.currentStoryboardName = storyboardName
        
        log.verbose("Changing Storyboard: " + storyboardName)
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerName)
        self.window?.rootViewController = controller
    }
    
    /// Update the storyboard to comply with the current state of the application, using a transition.
    ///
    /// - Parameter options: The transition/animation options
    public func updateStoryboard(_ options: UIView.AnimationOptions = .transitionFlipFromLeft) {
        DispatchQueue.main.async {
            self.setCorrectStoryboard()
            
            UIView.transition(
                with: UIApplication.shared.keyWindow!,
                duration: 0.5,
                options: options,
                animations: nil,
                completion: nil
            )
        }
    }
    
    /// Set the global tint color of this application's window and accessory view (e.g. the keyboard)
    private func setCorrectTintColor() {
        NavigationAccessoryView.appearance().tintColor = UIColor.getTintRed()
        self.window?.tintColor = UIColor.getTintRed()
    }
    
    /// Called when your app has received a remote notification.
    ///
    /// - Parameter application: The singleton app object.
    /// - Parameter userInfo: A dictionary that contains information related to the remote notification.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        log.verbose("Received a remote notification")
        SyncerHelper.shared.getSyncer().notify(userInfo)
    }
    
    /// Tells the delegate that the app is about to become inactive.
    ///
    /// - Parameter application: The singleton app object.
    func applicationWillResignActive(_ application: UIApplication) {
        // Not implemented
    }

    /// Tells the delegate that the app is now in the background.
    ///
    /// - Parameter application: The singleton app object.
    func applicationDidEnterBackground(_ application: UIApplication) {
        previousStoryboardName = nil
    }

    /// Tells the delegate that the app is about to enter the foreground.
    ///
    /// - Parameter application: The singleton app object.
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Not implemented
    }

    /// Tells the delegate that the app has become active.
    ///
    /// - Parameter application: The singleton app object.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Not implemented
    }

    /// Tells the delegate when the app is about to terminate.
    ///
    /// - Parameter application: The singleton app object.
    func applicationWillTerminate(_ application: UIApplication) {
        // Not implemented
    }
    
    /// Asks the delegate to grant permission to use app extensions that are based on a specified extension point identifier.
    ///
    /// - Parameter application: The singleton app object.
    /// - Parameter extensionPointIdentifier: A constant identifying an extension point.
    /// - Returns false to disallow use of a specified app extension type, or true to allow use of the type.
    /// - Note This disables third party keyboards throughout the entire application.
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return extensionPointIdentifier != .keyboard
    }
    
}
