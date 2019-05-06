//
//  LogoFormRow.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Eureka

final class LogoFormRow: _ActionSheetRow<LogoFormCell>, RowType {
    
    
    public var valueURL: URL? = nil
//    
//    required public init(tag: String?) {
//        super.init(tag: tag)
//    }
//    
    convenience init(tag: String?, controller: UIViewController, _ initializer: (LogoFormRow) -> Void = { _ in }) {
        self.init(tag: tag)
        initializer(self)
        
        cellProvider = CellProvider<LogoFormCell>(nibName: "LogoFormCell", bundle: Bundle.main)
        
        onChange { (row) in
            let value = row.value
            row.value = nil // Ensure that onchange triggers the next time
            
            switch value {
            case PasswordLogoTypeFormOption.OPTION_RAIVO_VECTOR:
                self.selectFromRaivoVectors(controller, row)
            default:
                return
            }
        }
        
    }

    private func selectFromRaivoVectors(_ sender: UIViewController, _ row: LogoFormRow) {
        let controller = LogoFormVectorViewController()
        controller.set(logoFormRow: row)
        
        sender.navigationController?.pushViewController(controller, animated: true)
    }
    
}
