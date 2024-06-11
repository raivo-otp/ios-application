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
                self.busy = false
                self.present = true
            }
        }
    }
}
