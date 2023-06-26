//
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

/// A helper class for managing `UIStoryboard`'s and their corresponding `UIViewController`'s (and their cached variants)
class StoryboardHelper {
    
    /// The singleton instance for the StoryboardHelper
    public static let shared = StoryboardHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Which storyboards should actually be cached.
    ///
    /// - Note: Some should not be cached, as we don't want to remember their state, or in which position of the storyboard the user was (think of e.g. the unlock screen)
    private let storyboardsToCache = [
        StateHelper.Storyboard.MAIN
    ]
    
    /// Which storyboard controllers should actually be cached.
    ///
    /// - Note: Some should not be cached, as we don't want to remember their state, or in which position of the storyboard the user was (think of e.g. the unlock screen)
    /// - Note: Must be the same as `storyboardsToCache`, but with the corresponding controller keys.
    private let storyboardControllersToCache = [
        StateHelper.StoryboardController.MAIN
    ]
    
    /// The actual references to the cached storyboards.
    private var cachedStoryboards: [String: UIStoryboard] = [:]
    
    /// The actual references to the cached controllers.
    private var cachedStoryboardControllers: [String: UIViewController] = [:]
    
    /// Get a cached or uncached instance of a storyboard (depending on if the specific storyboard needs to be cached).
    ///
    /// - Parameter storyboardName: The name of the storyboard to cache.
    /// - Returns: The actual storyboard you can use.
    public func getCachedStoryboard(_ storyboardName: String) -> UIStoryboard {
        guard storyboardsToCache.contains(storyboardName) else {
            return UIStoryboard(name: storyboardName, bundle: nil)
        }
        
        if !cachedStoryboards.keys.contains(storyboardName) {
            cachedStoryboards[storyboardName] = UIStoryboard(name: storyboardName, bundle: nil)
        }
        
        return cachedStoryboards[storyboardName]!
    }
    
    /// Get a cached or uncached instance of a storyboard (depending on if the specific storyboard needs to be cached).
    ///
    /// - Parameter storyboard: The storyboard to initiate the view controller on.
    /// - Parameter controllerName: The name of the storyboard controller to cache.
    /// - Returns: The actual controller you can use.
    public func getCachedStoryboardController(_ storyboard: UIStoryboard, _ controllerName: String) -> UIViewController {
        guard storyboardControllersToCache.contains(controllerName) else {
            return storyboard.instantiateViewController(withIdentifier: controllerName)
        }
                
        if !cachedStoryboardControllers.keys.contains(controllerName) {
            cachedStoryboardControllers[controllerName] = storyboard.instantiateViewController(withIdentifier: controllerName)
        }
        
        return cachedStoryboardControllers[controllerName]!
    }
    
    /// Clear the cached storyboards so they can be initialized again in a later stage.
    ///
    /// - Parameter dueToPasscodeChange: Positive if only certain keychain items should be removed.
    /// - Note The `dueToPasscodeChange` parameter can be set to true on e.g. a passcode change.
    public func clear(dueToPasscodeChange: Bool = false) {
        cachedStoryboards.removeAll()
        cachedStoryboardControllers.removeAll()
    }
    
}
