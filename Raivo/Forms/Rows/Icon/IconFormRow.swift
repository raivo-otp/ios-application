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
import SwiftUI
import Photos

final class IconFormRow: _ActionSheetRow<IconFormRowCell>, RowType, ImagePickerModuleDelegate {

    public var iconType: String? = nil
    
    public var iconValue: String? = nil {
        willSet {
            if newValue?.count ?? 0 > 0 {
				if iconType == PasswordIconTypeFormOption.OPTION_CUSTOM_ICONS.value {
					let filePath = (newValue ?? "").replacingOccurrences(of: "file://", with: "")
					let url = URL(fileURLWithPath: filePath)
					if FileManager.default.fileExists(atPath: url.path) {
						options = PasswordIconTypeFormOption.options_including_clear
					} else {
						options = PasswordIconTypeFormOption.options
					}
				} else {
					options = PasswordIconTypeFormOption.options_including_clear
				}
            } else {
                options = PasswordIconTypeFormOption.options
            }
        }
    }

	var senderRow: IconFormRow?
	var imagePicker: ImagePickerModule?
    
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
			case PasswordIconTypeFormOption.OPTION_CUSTOM_ICONS:
				self.customIconSelector(controller, row)
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
	
	private func customIconSelector(_ sender: UIViewController, _ row: IconFormRow) {
		self.senderRow = row
		
		let status = PHPhotoLibrary.authorizationStatus()
		
		if status == .authorized || status == .limited {
			self.startSelectingImage(sender, row)
		} else if status == .denied {
			self.gotoPhotoLibraryRequestView(sender, row)
		} else {
			self.gotoPhotoLibraryRequestView(sender, row)
		}
	}
	
	func gotoPhotoLibraryRequestView(_ sender: UIViewController, _ row: IconFormRow) {
		let controller = RequestPhotoLibraryViewController()

		controller.sender = sender
		controller.set(dismissCallback: { image in
			//let status = PHPhotoLibrary.authorizationStatus()
			//if status == .authorized || status == .limited {
			//	self.startSelectingImage(sender, row)
			//}
			if let image = image {
				self.setSelectedImage(image)
			}
		})

		controller.modalPresentationStyle = .fullScreen
		
		if let viewController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
			//viewController.present(controller, animated: true)
			viewController.pushViewController(controller, animated: true)
		}
	}
	
	func startSelectingImage(_ sender: UIViewController, _ row: IconFormRow) {
		self.imagePicker = ImagePickerModule(sender)
		self.imagePicker?.delegate = self
		self.imagePicker?.startImagePicking()
	}
	
	func imagePickerModule(_ module: ImagePickerModule, completeWithImage image: UIImage) {
		self.setSelectedImage(image)
	}
	
	func imagePickerModuleRequestRemovePhoto(_ module: ImagePickerModule) {
		
	}
	
	func imagePickerModuleCanceledSeleting(_ module: ImagePickerModule) {
		
	}
	
	func setSelectedImage(_ image: UIImage) {
		if let data = image.jpegData(compressionQuality: 1.0) {
			let fileName = UUID().uuidString
			let filePath = getDocumentsDirectory().appendingPathComponent(fileName + ".jpg")
			try? data.write(to: filePath)
			
			self.senderRow?.iconType = PasswordIconTypeFormOption.OPTION_CUSTOM_ICONS.value
			self.senderRow?.iconValue = filePath.absoluteString

			self.senderRow?.reload()
		}
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
