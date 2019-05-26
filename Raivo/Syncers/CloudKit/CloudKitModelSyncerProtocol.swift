//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
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
