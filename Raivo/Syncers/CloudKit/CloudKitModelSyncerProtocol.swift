//
//  CloudKitModelSyncerProtocol.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitModelSyncerProtocol: BaseClass {
    
    func enable() -> Void
    
    func disable() -> Void
    
    func resync(_ record: CKRecord.ID) -> Void
    
    func resyncAll(_ predicate: NSPredicate?) -> Void
    
    func notify(_ notification: CKQueryNotification?) -> Void
    
    func flushAllData(success: @escaping (() -> Void), error: @escaping ((Error) -> Void)) -> Void
    
}
