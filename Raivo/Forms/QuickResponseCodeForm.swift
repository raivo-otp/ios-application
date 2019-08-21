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

class QuickResponseCodeForm {
    
    private var form: Form
    
    public var genericSection: Section { return form.sectionBy(tag: "generic")! }
    
    public var errorRow: LabelRow { return form.rowBy(tag: "error") as! LabelRow }
    public var qrcodeRow: ViewRow<UIImageView> { return form.rowBy(tag: "qrcode") as! ViewRow<UIImageView> }
    
    init(_ form: Form) {
        self.form = form
    }
    
    @discardableResult
    public func build(_ password: Password) -> Self {
        let genericSection = buildGenericSection(password)
        
        if let image = generateQuickResponseCode(password) {
            buildQuickResponseCodeRow(genericSection, image)
        } else {
            log.error("Create QR code image failed!")
            buildErrorRow(genericSection, password)
        }
        
        return self
    }
    
    private func buildGenericSection(_ password: Password) -> Section {
        let title = password.issuer + (password.account.count > 0 ? " (" + password.account + ")" : "")
        let genericSection = Section(title, { section in
            section.tag = "generic"
        })
        
        form +++ genericSection
        
        return genericSection
    }
    
    private func buildErrorRow(_ section: Section, _ password: Password) {
        section <<< LabelRow("error", { row in
            row.title = "The QR code could not be generated."
            row.cell.textLabel?.numberOfLines = 0
        }).cellUpdate({ cell, row in
            cell.imageView?.image = UIImage(named: "icon-lightning-tint")
        })
    }
    
    /// Add a form section and a row that contains the QR code
    ///
    /// - Parameter section: The section to add the QR code to
    /// - Parameter image: The QR code image that was generated
    /// - Returns: Positive if the QR code was added. It can be negative when the QR code fails to generate.
    private func buildQuickResponseCodeRow(_ section: Section, _ image: CGImage) {
        section <<< ViewRow<UIImageView>("qrcode").cellSetup({ cell, row in
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
        })
    }
    
    /// Generate the QR code as an image
    ///
    /// - Parameter password: The password the generate the QR code for
    /// - Returns: The image if the generation was successful
    private func generateQuickResponseCode(_ password: Password) -> CGImage? {
        return EFQRCode.generate(
            content: try! password.getToken().toURL().absoluteString + "&secret=" + password.secret,
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
