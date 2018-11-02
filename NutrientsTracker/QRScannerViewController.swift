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

    //MARK: Properties
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var qrString:String?
    
    //MARK: ViewController Functions
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Check if the captureSession is running
        if (captureSession?.isRunning == true){
            // If true stop video captureSession
            captureSession?.stopRunning()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Check if the captureSession is running
        if (captureSession?.isRunning == false){
            // If false start video captureSession
            captureSession?.startRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Find and access device back camera, set it's media capture type to video
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        // Check if the device session is valid
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            // DEBUG MESSAGE
            print("Error accessing device back camera")
            return
            
        }
        do {
            // Get an instance from the AVCaptureDeviceInput
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Setup the device capture session
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            // Initialize AVCaptureMetaDataOutput and set it to the output device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // Sets the metaDataObject type to type QR
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize video preview layer and add it as a sublayer to the videoPreview screen
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            // Make the videoPreviewLayer fill the screen
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            // Add the videoPreviewLayer to the sublayer
            view.layer.addSublayer(videoPreviewLayer!)
            // Setup the videoPreviewLayer height and width values
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            // Check the current video orientation mode
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
            // Set the video orientation value
            videoPreviewLayer!.connection?.videoOrientation = videoOrientation
            
            // Create a new UIView
            qrCodeFrameView = UIView()
            // Setup the UIView
            if let qrCodeFrameView = qrCodeFrameView {
                // Setup UIView border color
                qrCodeFrameView.layer.borderColor = UIColor.blue.cgColor
                // Setup UIView borderwidth
                qrCodeFrameView.layer.borderWidth = 1.5
                // Add the UIView to the mainView
                view.addSubview(qrCodeFrameView)
                // Bring the subview to the frontView
                view.bringSubviewToFront(qrCodeFrameView)
            }
        }catch {
            // DEBUG MESSAGE
            print("Error while initializing AVCaptureDeviceInput")
            return
        }
    }
    
    //MARK: AVCaptureMetaDataOutput Delegates
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadata object array is empty
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            // DEBUG MESSAGE
            print("No QR code was scanned")
            return
        }
        
        // When the metadata object array contains a value get it's metadataObject
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Check if the metadataObject type is equal to objectType qr
        if metadataObj.type == AVMetadataObject.ObjectType.qr{
            // Store the  metadata if it is from type qr
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            // Display the Custom UIView covering the QR code on the screen
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            // Check the metadata stringvalue for nil
            if metadataObj.stringValue != nil {
                // If not nil extract the stringvalue to a variable
                qrString = metadataObj.stringValue
                // Turn off the captureSession
                captureSession?.stopRunning()
                // Perform Segue to the ProductTableViewController
                self.performSegue(withIdentifier: "unwindToProductTable", sender: self)
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
        // Set the camera orientation value
        videoPreviewLayer!.connection?.videoOrientation = videoOrientation
        // Setup the videoPreviewLayer width and height values
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width)
    }
    
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if the qrString is nil
        if qrString != nil{
            // Pass the qrString to the DayResultViewController
            let productTableVc = segue.destination as! ProductTableViewController
            productTableVc.qrStringProduct = qrString
        }
    }
}
