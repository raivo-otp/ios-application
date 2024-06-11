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
import Eureka
import ViewRow
import EFQRCode
import UIKit

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
            cell.backgroundColor = UIColor.getBackgroundOpaque()
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
            for: try! password.getToken().toCompatibleURL().absoluteString + "&secret=" + password.secret,
            size: EFIntSize(width: 400, height: 400),
            backgroundColor: UIColor.getBackgroundOpaque().cgColor,
            foregroundColor: UIColor.getLabel().cgColor
        )
    }
}
