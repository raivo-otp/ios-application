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

import SwiftyBeaver
import Foundation

/// Global reference to the SwiftyBeaver logging framework
let log = SwiftyBeaver.self
let logFileDestination = FileDestination()
let logConsoleDestination = ConsoleDestination()

/// Get the Application Principal (shared `UIApplication` class).
///
/// - Returns: The application principal singleton instance
func getAppPrincipal() -> ApplicationPrincipal {
    return (ApplicationPrincipal.shared as! ApplicationPrincipal)
}

/// Get the Application Delegate (shared `UIApplicationDelegate` class).
///
/// - Returns: The application delegate singleton instance
func getAppDelegate() -> ApplicationDelegate {
    if Thread.isMainThread {
        return (getAppPrincipal().delegate as! ApplicationDelegate)
    }
    
    var appDelegate: ApplicationDelegate?
    
    DispatchQueue.main.sync {
        appDelegate = (getAppPrincipal().delegate as! ApplicationDelegate)
    }
    
    return appDelegate!
}

/// Add the current console as a SwiftyBeaver logging destination
func initializeConsoleLogging() {
    log.removeDestination(logConsoleDestination)
    
    logConsoleDestination.minLevel = AppHelper.logLevel
    log.addDestination(logConsoleDestination)
    log.verbose("Console log destination initialized")
}

/// Add the debug log file as a SwiftyBeaver logging destination
func initializeFileLogging() {
    log.removeDestination(logFileDestination)
    
    logFileDestination.minLevel = AppHelper.logLevel
    logFileDestination.logFileURL = AppHelper.logFile
    logFileDestination.format = "$Dyyyy-MM-dd HH:mm:ss$d$d $T $N.$F:$l $L: $M"
    log.addDestination(logFileDestination)
    log.verbose("File log destination initialized")
}

/// Return a uniquely identifiable string (ID) for the given class.
///
/// - Parameter reference: The class or object to describe.
/// - Parameter appId: The application identifier (e.g. release or debug).
/// - Returns: A string describing the class (e.g. `com.finnwea.Raivo.Debug.StorageHelper`)
func id(_ reference: Any, _ appId: String = AppHelper.identifier) -> String {
    var identifier = String(describing: type(of: reference))
    
    if identifier.hasSuffix(".Type") {
        let typeIndex = identifier.index(identifier.endIndex, offsetBy: -5)
        identifier = String(identifier.prefix(upTo: typeIndex))
    }
    
    return appId + identifier
}

/// Return a uniquely identifiable string (ID) for the given class (based on the release bundle identifier).
///
/// - Parameter reference: The class or object to describe
/// - Returns: A string describing the class (e.g. `com.finnwea.Raivo.StorageHelper`)
func idr(_ reference: Any) -> String {
    return id(reference, AppHelper.releaseIdentifier)
}

/// A short hand for running the given closure on the main thread
///
/// - Parameter callback: The closure to run on the main thread
func ui(_ callback: @escaping () -> Void) {
    DispatchQueue.main.async {
        callback()
    }
}

/// Get the kernel uptime
///
/// - Returns: The uptime since boot or clock change
/// - Note:
///     Implementation from https://stackoverflow.com/questions/36203662/getting-system-uptime-in-ios-swift
func uptime() -> TimeInterval {
    var uptime = timespec()
    
    if 0 != clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) {
        fatalError("Could not execute clock_gettime, errno: \(errno)")
    }

    return TimeInterval(uptime.tv_sec)
}
