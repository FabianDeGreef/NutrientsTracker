//
//  QRScannerViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 15/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //MARK Properties
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var qrString:String?
    
    //MARK: ViewController Functions
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true){
            // Stop video output
            captureSession?.stopRunning()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == false){
            // Start video input
            captureSession?.startRunning()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Find and access device back camera and set it media capture type to video
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Error accesing device camera")
            return
            
        }
        do {
            // Get instance from the AVCaptureDeviceInput
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Sets the device on the capture session
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            // Initialize AVCaptureMetaDataOutput and set it to the output device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // Sets the metaDataObject type to QR output
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize video preview layer and add it as a sublayer to the video preview screen
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            view.layer.addSublayer(videoPreviewLayer!)
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

            let videoOrientation: AVCaptureVideoOrientation
            switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                videoOrientation = .portrait
            case .portraitUpsideDown:
                videoOrientation = .portraitUpsideDown
                
            case .landscapeLeft:
                videoOrientation = .landscapeLeft
                
            case .landscapeRight:
                videoOrientation = .landscapeRight
                
            default:
                videoOrientation = .portrait
            }
            videoPreviewLayer!.connection?.videoOrientation = videoOrientation


            // Highlight the QR code
            qrCodeFrameView = UIView()
            // Create and setup a UIView
            if let qrCodeFrameView = qrCodeFrameView {
                // Give the UIView a border color
                qrCodeFrameView.layer.borderColor = UIColor.blue.cgColor
                // Give the UIView a borderwidth
                qrCodeFrameView.layer.borderWidth = 1.5
                // Add the UIView to the main view
                view.addSubview(qrCodeFrameView)
                // Bring the subview to the front
                view.bringSubviewToFront(qrCodeFrameView)
            }
        }catch {
            // If errors occurs
            print(error)
            return
        }
    }
    
    // MARK: AVCaptureMetaDataOutput Delegates
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadata object array is empty
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No qr code was scanned")
            return
        }
        
        // When the metadata object array contains a value get it's metadata Object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr{
            // Check the found metadata if it is equal to the QR code metadata
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            // If the found metadata has a stringvalue that is not nil
            if metadataObj.stringValue != nil {
                // Extract the stringvalue to a variable
                qrString = metadataObj.stringValue
                captureSession?.stopRunning()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .portrait
        }
        videoPreviewLayer!.connection?.videoOrientation = videoOrientation
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width)
    }
    
    // MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Sends the qr string data to the productTableViewController 
        if qrString != nil{
            let productTableVc = segue.destination as! ProductTableViewController
            productTableVc.qrStringProduct = qrString
        }
    }
}
