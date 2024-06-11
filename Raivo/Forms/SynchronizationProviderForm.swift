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
import Eureka
import UIKit

class SynchronizationProviderForm {
    
    private var form: Form
    
    public var providersSection: Section { return form.sectionBy(tag: "providers")! }
    
    public var syncerOfflineRow: ListCheckRow<String> { return form.rowBy(tag: id(OfflineSyncer.self)) as! ListCheckRow<String> }
    public var syncerCloudKitRow: ListCheckRow<String> { return form.rowBy(tag: id(CloudKitSyncer.self)) as! ListCheckRow<String> }
    
    class NoHeader: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: CGRect(x: 0, y: -1, width: 1, height: 1))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    init(_ form: Form) {
        self.form = form
    }
    
    @discardableResult
    public func build() -> Self {
        initProvidersSection()
        
        return self
    }
    
    public func selectFirstSyncer() {
        for row in form.last!.allRows {
            let row = (row as! ListCheckRow<String>)
            if !row.isDisabled {
                row.value = row.tag
                row.updateCell()
                break
            }
        }
    }
    
    public func getSelectedSyncer() -> String? {
        for row in form.last!.allRows {
            let row = (row as! ListCheckRow<String>)
            if row.value != nil {
                return row.tag!
            }
        }
        
        return nil
    }
    
    private func initProvidersSection() {
        form +++ SelectableSection<ListCheckRow<String>>({ section in
            section.tag = "providers"
            section.header = HeaderFooterView<NoHeader>(HeaderFooterProvider.class)
            section.selectionType = .singleSelection(enableDeselection: false)
        })
            
            <<< ListCheckRow<String>(id(OfflineSyncer.self), { row in
                row.selectableValue = id(OfflineSyncer.self)
                row.title = SyncerHelper.shared.getSyncer(id(OfflineSyncer.self)).name
                row.disabled = Condition(booleanLiteral: true)
            })
            
            <<< ListCheckRow<String>(id(CloudKitSyncer.self), { row in
                row.selectableValue = id(CloudKitSyncer.self)
                row.title = SyncerHelper.shared.getSyncer(id(CloudKitSyncer.self)).name
                row.disabled = Condition(booleanLiteral: true)
            })
    }
    
}
