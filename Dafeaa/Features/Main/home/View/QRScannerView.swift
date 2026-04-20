//
//  QRScannerView.swift
//  Dafeaa
//
//  Created by AMNY on 08/04/2026.
//

import SwiftUI
import AVFoundation

// MARK: - QR Scanner View
struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var scannedCode: String = ""
    @State private var isScanning: Bool = true

    var body: some View {
        ZStack {
            QRCameraView(scannedCode: $scannedCode, isScanning: $isScanning)
                .ignoresSafeArea()

            VStack {
                NavigationBarView(title: "quick_payment".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                .background(Color.black.opacity(0.5))

                Spacer()

                // Scanning frame overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primaryF9CE29, lineWidth: 3)
                        .frame(width: 220, height: 220)

                    VStack {
                        Spacer()
                        Text("scan_qr_desc".localized())
                            .textModifier(.plain, 14, .white)
                            .padding(.top, 130)
                    }
                    .frame(width: 220, height: 220)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onChange(of: scannedCode) { _, newValue in
            if !newValue.isEmpty {
                isScanning = false
                // Handle scanned QR code here
                print("Scanned: \(newValue)")
            }
        }
    }
}

// MARK: - QR Camera View
struct QRCameraView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return controller
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = UIScreen.main.bounds
        preview.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(preview)

        context.coordinator.session = session
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if !isScanning {
            context.coordinator.session?.stopRunning()
        }
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCameraView
        var session: AVCaptureSession?

        init(_ parent: QRCameraView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let code = object.stringValue,
                  parent.isScanning else { return }
            parent.scannedCode = code
        }
    }
}
