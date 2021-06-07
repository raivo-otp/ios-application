//
//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import Foundation
import Combine

final class MainDataExportViewObservable: ObservableObject {
    
    @Published var busy = false
    
    @Published var present = false
    
    @Published var archive: URL? = nil

    func export() {
        ui { self.busy = true }
        
        // Run in the background and fake a delay so the user can read the banner
        DispatchQueue.global(qos: .background).async {
            let dataExport = DataExportFeature()

            let status = autoreleasepool { () -> DataExportFeature.Result in
                let password = StorageHelper.shared.getEncryptionPassword()
                return dataExport.generateArchive(protectedWith: password!)
            }
            
            guard case let DataExportFeature.Result.success(archive) = status else {
                log.error("Archive generation failed!")
                return
            }
            
            ui {
                self.archive = archive
                self.present = true
            }
        }
    }
}
