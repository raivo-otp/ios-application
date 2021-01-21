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
import UIKit

class MainDataExportViewController: UIViewController {
    
}

/*

let barButtonItem = controller.displayNavBarActivity()

BannerHelper.shared.done("Hold tight", "Generation takes a few seconds", wrapper: controller.view)

// Run in the background and fake a delay so the user can read the banner
DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1, execute: {
    let dataExport = DataExportFeature()

    let status = autoreleasepool { () -> DataExportFeature.Result in
        let password = StorageHelper.shared.getEncryptionPassword()
        return dataExport.generateArchive(protectedWith: password!)
    }
    
    guard case let DataExportFeature.Result.success(archive) = status else {
        log.error("Archive generation failed!")
        return
    }
    
    let dataExportMail = ComposeMailFeature(.dataExport)
    
    DispatchQueue.main.async {
        if dataExportMail.canSendMail() {
            dataExportMail.addAttachment(archive, "application/zip", "raivo-otp-export.zip")
            dataExportMail.send(popupFrom: controller) {
                controller.dismissNavBarActivity(barButtonItem)
            }
        } else {
            let activity = UIActivityViewController(activityItems: [archive], applicationActivities: nil)
            controller.present(activity, animated: true, completion: {
                controller.dismissNavBarActivity(barButtonItem)
            })
        }
    }
})

*/
