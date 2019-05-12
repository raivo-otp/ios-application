//
//  ProvidersForm.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Eureka

class SynchronizationProviderForm: BaseClass {
    
    private var form: Form
    
    public var providersSection: Section { return form.sectionBy(tag: "providers")! }
    
    public var syncerOfflineRow: ListCheckRow<String> { return form.rowBy(tag: OfflineSyncer.UNIQUE_ID) as! ListCheckRow<String> }
    public var syncerCloudKitRow: ListCheckRow<String> { return form.rowBy(tag: CloudKitSyncer.UNIQUE_ID) as! ListCheckRow<String> }
    
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
            
            <<< ListCheckRow<String>(OfflineSyncer.UNIQUE_ID, { row in
                row.selectableValue = OfflineSyncer.UNIQUE_ID
                row.title = "None (offline)"
                row.disabled = Condition(booleanLiteral: true)
            })
            
            <<< ListCheckRow<String>(CloudKitSyncer.UNIQUE_ID, { row in
                row.selectableValue = CloudKitSyncer.UNIQUE_ID
                row.title = "Personal iCloud"
                row.disabled = Condition(booleanLiteral: true)
            })
    }
    
}
