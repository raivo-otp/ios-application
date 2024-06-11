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
import CloudKit

protocol CloudKitModelSyncerProtocol {
    
    func enable() -> Void
    
    func disable() -> Void
    
    func resync(_ record: CKRecord.ID) -> Void
    
    func resyncAll(_ predicate: NSPredicate?) -> Void
    
    func notify(_ notification: CKQueryNotification?) -> Void
    
    func flushAllData(success: @escaping (() -> Void), error: @escaping ((Error) -> Void)) -> Void
    
}
