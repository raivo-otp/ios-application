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
import MessageUI

class ComposeMailFeature {
    
    public enum Template {
        case dataExport
    }
    
    var attachments: [(URL, String, String)] = []
    
    let template: Template
    
    init(_ template: Template) {
        self.template = template
    }
    
    public func addAttachment(_ data: URL, _ mime: String, _ name: String) {
        attachments.append((data, mime, name))
    }
    
    public func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    public func send<T: UIViewController & MFMailComposeViewControllerDelegate>(popupFrom controller: T, _ callback: @escaping (() -> Void)) {
        let mailComposer = MFMailComposeViewController()
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        mailComposer.mailComposeDelegate = controller
        mailComposer.setSubject("Raivo OTP data export")
        
        let path = Bundle.main.path(forResource: "export-inline", ofType: "html") // file path for file "data.txt"
        let html = try? String(contentsOfFile: path!, encoding: .utf8)
        
        mailComposer.setMessageBody(html!, isHTML: true)
        
        for attachment in attachments {
            if let archiveData = try? Data(contentsOf: attachment.0) {
                mailComposer.addAttachmentData(archiveData, mimeType: attachment.1, fileName: attachment.2)
            }
        }
        
        controller.present(mailComposer, animated: true, completion: callback)
    }
    
}
