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
import CloudKit

protocol CloudKitModelConverterProtocol {
    
    static func getLocal(_ record: CKRecord) throws -> Password?
    
    static func getLocalCopy(_ record: CKRecord, syncedCorrectly: Bool) throws -> Password
    
    static func getRemote(_ password: Password) -> CKRecord
    
}
