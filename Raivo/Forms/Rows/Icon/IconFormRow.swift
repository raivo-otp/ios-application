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
import Eureka
import SwiftUI

final class IconFormRow: _ActionSheetRow<IconFormRowCell>, RowType {
    
    public var iconType: String? = nil
    
    public var iconValue: String? = nil {
        willSet {
            if newValue?.count ?? 0 > 0 {
                options = PasswordIconTypeFormOption.options_including_clear
            } else {
                options = PasswordIconTypeFormOption.options
            }
        }
    }
    
    convenience init(tag: String?, controller: UIViewController, _ initializer: (IconFormRow) -> Void = { _ in }) {
        self.init(tag: tag)
        initializer(self)
        
        cellProvider = CellProvider<IconFormRowCell>(nibName: "IconFormRowCell", bundle: Bundle.main)
        
        onChange { (row) in
            let value = row.value
            row.value = nil // Ensure that onchange triggers the next time
            
            switch value {
            case PasswordIconTypeFormOption.OPTION_CLEAR:
                self.clearSelector(controller, row)
            case PasswordIconTypeFormOption.OPTION_RAIVO_REPOSITORY:
                self.raivoRepositorySelector(controller, row)
            default:
                return
            }
        }
        
    }
    
    private func clearSelector(_ sender: UIViewController, _ row: IconFormRow) {
        row.iconType = nil
        row.iconValue = nil
        
        row.reload()
    }

    private func raivoRepositorySelector(_ sender: UIViewController, _ row: IconFormRow) {
        let controller = IconFormRaivoRepositorySelectorViewController()
        controller.set(iconFormRow: row)

        controller.set(dismissCallback: {
            row.reload()
        })

        sender.navigationController?.pushViewController(controller, animated: true)
    }
    
}
