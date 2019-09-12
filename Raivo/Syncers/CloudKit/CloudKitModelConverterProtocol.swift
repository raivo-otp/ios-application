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
import CloudKit

protocol CloudKitModelConverterProtocol {
    
    static func getLocal(_ record: CKRecord) throws -> Password?
    
    static func getLocalCopy(_ record: CKRecord, syncedCorrectly: Bool) throws -> Password
    
    static func getRemote(_ password: Password) -> CKRecord
    
}
