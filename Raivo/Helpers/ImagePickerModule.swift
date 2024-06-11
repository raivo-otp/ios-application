//
// Raivo OTP
//
// Copyright (c) 2024 Mobime. All rights reserved.
//
// View the license that applies to the Raivo OTP source
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit

protocol ImagePickerModuleDelegate: AnyObject {
    func imagePickerModule(_ module: ImagePickerModule, completeWithImage image:UIImage)
	func imagePickerModuleRequestRemovePhoto(_ module: ImagePickerModule)
}

class ImagePickerModule: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var imagePicker = UIImagePickerController()

    weak var viewController: UIViewController!
    weak var delegate: ImagePickerModuleDelegate?
    
    init(_ viewController: UIViewController) {
        super.init()
            
        self.viewController = viewController
    }
    
	func startImagePicking() {
		self.openGallery()
    }
    
    internal func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraDevice = .front
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.viewController.present(imagePicker, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.imagePicker.fixCannotMoveEditingBox()
            }
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.viewController.present(alert, animated: true, completion: nil)
        }
    }

    internal func openGallery() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen

        self.viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
        }
    }

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        //let imagePhoto: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imagePhoto: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
		self.delegate?.imagePickerModule(self, completeWithImage: imagePhoto)
    }
}

extension UIImagePickerController {
    func fixCannotMoveEditingBox() {
        if let cropView = cropView,
           let scrollView = scrollView,
           scrollView.contentOffset.y == 0 {
            
            //let top = cropView.frame.minY + self.view.safeAreaInsets.top
            let top = cropView.frame.minY
            let bottom = scrollView.frame.height - cropView.frame.height - top
            scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
            
            var offset: CGFloat = 0
            if scrollView.contentSize.height > scrollView.contentSize.width {
                offset = 0.5 * (scrollView.contentSize.height - scrollView.contentSize.width)
            }
            scrollView.contentOffset = CGPoint(x: 0, y: -top + offset)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.fixCannotMoveEditingBox()
        }
    }
    
    var cropView: UIView? {
        return findCropView(from: self.view)
    }
    
    var scrollView: UIScrollView? {
        return findScrollView(from: self.view)
    }
    
    func findCropView(from view: UIView) -> UIView? {
        let width = UIScreen.main.bounds.width
        let size = view.bounds.size
        if width == size.height, width == size.height {
            return view
        }
        for view in view.subviews {
            if let cropView = findCropView(from: view) {
                return cropView
            }
        }
        return nil
    }
    
    func findScrollView(from view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for view in view.subviews {
            if let scrollView = findScrollView(from: view) {
                return scrollView
            }
        }
        return nil
    }
}
