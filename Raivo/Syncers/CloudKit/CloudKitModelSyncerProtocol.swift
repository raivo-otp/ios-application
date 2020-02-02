//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import CloudKit

protocol CloudKitModelSyncerProtocol {
    
    func enable() -> Void
    
    func disable() -> Void
    
    func resync(_ record: CKRecord.ID) -> Void
    
    func resyncAll(_ predicate: NSPredicate?) -> Void
    
    func notify(_ notification: CKQueryNotification?) -> Void
    
    func flushAllData(success: @escaping (() -> Void), error: @escaping ((Error) -> Void)) -> Void
    
}
