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

final class QuickResponseCodeRow: Row<QuickResponseCodeRowCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<QuickResponseCodeRowCell>(nibName: "QuickResponseCodeRowCell", bundle: Bundle.main)
    }
    
}
