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
import LocalAuthentication

/// A helper class for determining the biometric authentication type
class BiometricHelper {
    
    /// The singleton instance for the BiometricHelper
    public static let shared = BiometricHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// The possible return types to determine which biometric authentication can be used
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    /// Determine which biometric authentication type can be used, in the following order: FaceID, TouchID, none.
    ///
    /// - Returns: The available preferred biometric type
    public func type() -> BiometricType {
        let authContext = LAContext()
        
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .faceID:
                return .face
            case .touchID:
                return .touch
            default:
                return .none
            }
        }
        
        return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
    }
    
    /// Check if at least one of the types is available (and therefore if biometric unlock is available)
    ///
    /// - Returns: Positive if biometric unlock is available
    public func biometricsAvailable() -> Bool {
        return type() != .none
    }
    
}
