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
import ViewRow
import EFQRCode

/// This controller allows users to export a password using a QRCode
class MainQRCodeViewController: FormViewController {
    
    /// The current password to show the QR code for
    public var password: Password?
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always show the password details before the QR code
        form +++ Section("Details", { section in
            section.tag = "details"
        })
            
            <<< LabelRow("issuer", { row in
                row.title = "Title (issuer)"
                row.value = password?.issuer
            })
            
            <<< LabelRow("account", { row in
                row.title = "Username"
                row.value = password?.account
            })
        
        // If the QR code cannot be generated, show an error message.
        if !addQRCode() {
            
            form +++ Section("QR code error", { section in
                section.tag = "export-error"
            })
                
                <<< LabelRow("error", { row in
                    row.title = "The QR code could not be generated."
                    row.cell.textLabel?.numberOfLines = 0
                }).cellUpdate({ cell, row in
                    cell.imageView?.image = UIImage(named: "icon-lightning-tint")
                })
        }
    }

    /// Add a form section and a row that contains the QR code
    ///
    /// - Returns: Positive if the QR code was added. It can be negative when the QR code fails to generate.
    private func addQRCode() -> Bool {
        if let image = generateQRCode() {
            form +++ Section("QR code", { section in
                section.tag = "export"
            })
                
                <<< ViewRow<UIImageView>()
                    .cellSetup { (cell, row) in
                        cell.view = UIImageView()
                        cell.view?.contentMode = .scaleAspectFit
                        cell.contentView.addSubview(cell.view!)
                        
                        let image = UIImage(cgImage: image)
                        cell.view!.image = image
                        
                        cell.viewRightMargin = 0.0
                        cell.viewLeftMargin = 0.0
                        cell.viewTopMargin = 0.0
                        cell.viewBottomMargin = 0.0
                        cell.height = { return 350 }
                    }
            
            return true
        }
        
        log.error("Create QRCode image failed!")
        return false
    }
    
    /// Generate the QR code as an image
    ///
    /// - Returns: The image if the generation was successful   
    private func generateQRCode() -> CGImage? {
        return EFQRCode.generate(
            content: try! password!.getToken().toURL().absoluteString + "&secret=" + password!.secret,
            size: EFIntSize(width: 400, height: 400),
            backgroundColor: UIColor.white.cgColor,
            foregroundColor: UIColor.black.cgColor,
            watermark: UIImage(named: "app-icon")!.toCGImage(),
            watermarkMode: .scaleAspectFit,
            pointShape: .circle,
            foregroundPointOffset: 0.1
        )
    }
    
}
