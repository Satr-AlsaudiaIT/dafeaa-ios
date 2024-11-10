//
//  ScanQRCodeView.swift
//  Dafeaa
//
//  Created by AMNY on 05/11/2024.
//


import Foundation
import AVFoundation
import CoreNFC
import SwiftUI

struct QRCodeScannerOverlay: View {
    @Binding var isShowing: Bool
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let scanRectWidth: CGFloat = 230
            let scanRectHeight: CGFloat = 220
            
            ZStack {
                Color.gray.opacity(0.5)
                    .frame(width: width, height: height)
                    .mask(
                        Rectangle()
                            .frame(width: width, height: height)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: scanRectWidth, height: scanRectHeight)
                                    .blendMode(.destinationOut)
                            )
                    )
                    .compositingGroup()
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: scanRectWidth, height: scanRectHeight)
                VStack {
                    NavigationBarView(title: "confirmReceivingOrder".localized()) {
                        isShowing = false
                    }
//                    HStack {
//                        Button(action: {
//                            isShowing = false
//                        }, label: {
//                            Image("backArrow")
//                                .resizable()
//                                .frame(width: 10, height: 17)
//                                
//                        })
//                        .padding(.horizontal,24)
//                        .padding(.vertical,20)
//                        Spacer()
//                    }
//                    .background(Color(.primary))
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


//#Preview {
//    QRCodeScannerOverlay()
//}

class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String = ""
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else {
            return
        }
        
        if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           readableObject.type == .qr,
           let stringValue = readableObject.stringValue {
            DispatchQueue.main.async {
                self.scannedCode = stringValue
            }
        }
    }
}


struct QRCodeScannerView: UIViewControllerRepresentable {
    @ObservedObject var scanner: ScannerViewModel
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let viewController = QRCodeScannerViewController()
        viewController.scanner = scanner
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
}

class QRCodeScannerViewController: UIViewController {
    var scanner: ScannerViewModel?
    private var captureSession: AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(scanner, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}
