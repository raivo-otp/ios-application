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
import Eureka

final class IconFormRow: _ActionSheetRow<IconFormRowCell>, RowType {
    
    public var iconType: String? = nil
    public var iconValue: String? = nil

    convenience init(tag: String?, controller: UIViewController, _ initializer: (IconFormRow) -> Void = { _ in }) {
        self.init(tag: tag)
        initializer(self)
        
        cellProvider = CellProvider<IconFormRowCell>(nibName: "IconFormRowCell", bundle: Bundle.main)
        
        onChange { (row) in
            let value = row.value
            row.value = nil // Ensure that onchange triggers the next time
            
            switch value {
            case PasswordIconTypeFormOption.OPTION_RAIVO_REPOSITORY:
                self.raivoRepositorySelector(controller, row)
            default:
                return
            }
        }
        
    }

    private func raivoRepositorySelector(_ sender: UIViewController, _ row: IconFormRow) {
        let controller = IconFormRaivoRepositorySelectorViewController()
        controller.set(iconFormRow: row)
        
        controller.set(dismissCallback: {
            self.cell.update()
        })
        
        sender.navigationController?.pushViewController(controller, animated: true)
    }
    
}
