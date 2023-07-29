//
//  BarcodeScannerView.swift
//  UIKitToSwiftScanner


import AVFoundation
import UIKit
import SwiftUI

class BarcodeScannerUIView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onDetected: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        startScanning()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startScanning() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession!.canAddInput(videoInput) else { return }
        
        captureSession!.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession!.canAddOutput(metadataOutput) {
            captureSession!.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer!.frame = self.layer.bounds
        previewLayer!.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer!)
        
        captureSession!.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        captureSession = nil
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            DispatchQueue.main.async {
                self.onDetected?(stringValue)
            }
        }
    }
}

struct BarcodeScannerView: UIViewRepresentable {
    
    var onDetected: (String) -> Void
    
    func makeUIView(context: Context) -> BarcodeScannerUIView {
        let view = BarcodeScannerUIView(frame: .zero)
        view.backgroundColor = .black
        view.onDetected = onDetected  // Set the callback for detected barcodes

        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    view.startScanning()
                }
            } else {
                // Handle the case where access was not granted
                print("Camera permission was not granted")
            }
        }

        return view
    }
    
    private func setupCaptureSession(in view: BarcodeScannerUIView, context: Context, metadataObjectTypes: [AVMetadataObject.ObjectType]) {
        let captureSession = AVCaptureSession()
        view.captureSession = captureSession

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(view, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataObjectTypes
        } else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    
    func updateUIView(_ uiView: BarcodeScannerUIView, context: Context) {
        uiView.previewLayer?.frame = uiView.bounds
    }
}
