//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import Foundation
import LocalAuthentication

/// A helper class for determining the biometric authentication type
class BiometricHelper {
    
    /// The singleton instance for the BiometricHelper
    public static let shared = BiometricHelper()
    
    /// Keeps track of observers for notifications that only one observer may listen to
    private var singleInstances: [String: NSObjectProtocol] = [:]
    
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
    
}
