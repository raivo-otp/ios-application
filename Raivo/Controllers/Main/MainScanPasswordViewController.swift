//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit
import UIKit
import AVFoundation
import OneTimePassword

class MainScanPasswordViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraPreview: UIView!

    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    lazy var captureSession = AVCaptureSession()

    var currentlyCheckingToken: Bool = false

    var lastScannedToken: Token?
    
    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                log.error("Failed to get the camera device; no permissions")
                self.cameraUnavailableView(true)
                self.alertToEncourageCameraAccessInitially()
            }
        }

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            log.error("Failed to get the camera device")
            self.cameraUnavailableView(true)
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            log.error(error)
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = cameraPreview.layer.bounds
        cameraPreview.layer.addSublayer(videoPreviewLayer!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureSessionDidStart),
            name: .AVCaptureSessionDidStartRunning,
            object: self.captureSession
        )
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVCaptureSessionDidStartRunning,
            object: nil
        )
    }
    
    @objc func captureSessionDidStart() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraPreview.alpha = CGFloat(1)
            })
        }
    }
    
    func cameraUnavailableView(_ unavailable: Bool) {
        DispatchQueue.main.async {
            self.cameraUnavailableLabel.isHidden = !unavailable
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentlyCheckingToken = false
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 || currentlyCheckingToken {
            return
        }

        currentlyCheckingToken = true

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.stringValue != nil {
            if SeedValueValidator.isValid(metadataObj.stringValue!) {
                lastScannedToken = Token(url: URL(string: metadataObj.stringValue!)!)
                performSegue(withIdentifier: "CreatePasswordAutomatically", sender: nil)
            } else {
                currentlyCheckingToken = false
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "CreatePasswordManually" {
            let newViewController = segue.destination as! MainCreatePasswordViewController
            newViewController.token = lastScannedToken
            newViewController.navigationItem.title = "Verify Details"
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Missing permissions!",
                message: "Raivo requires camera access to scan OTP QRCodes.",
                preferredStyle: UIAlertController.Style.alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
