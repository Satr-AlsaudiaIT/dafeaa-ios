//
//  AddWithdrawButtomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 27/10/2024.
//

import SwiftUI
import AVFoundation

enum bottomSheetAction {
    case addBalance
    case withDraw
}

struct AddWithdrawBottomSheet: View {
    @State private var amount: String = ""
    @Binding var actionType: bottomSheetAction?
    @Binding var amountDouble: Double
    @Binding var isSheetPresented: Bool
    @StateObject var viewModel = HomeVM()
    @State var actionFinished: Bool = false
    @State var isUnlocked = false
    @Binding var navigateToWebView : Bool
    @Binding var paymentURL : String
    @Binding var navigateToWithDrawView: Bool
    @Binding var navigateToAddBalance: Bool
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 16) {
                
                Text(actionType == .addBalance ? "addWalletBalance".localized() : "withdrawWalletBalance".localized())
                    .textModifier(.plain, 19, .black222222)
                    .padding(.bottom)
                HStack {
                    Image(.saudiFlag)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Image(.riyal)
                         .resizable()
                         .renderingMode(.template)
                         .foregroundColor(.gray8B8C86)
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 20)
                         .padding(.trailing, 10)
                }
                .padding(.horizontal)
                .environment(\.layoutDirection, .rightToLeft)
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .textModifier(.plain, 43, .black2B2D33)
                    .frame(minHeight: 50) 
                
                Text(actionType == .addBalance ? "" : "")//"noExtraFees".localized()
                    .textModifier(.plain, 17, actionType == .addBalance ? .gray919191 : Color(.redD73D24))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                ReusableButton(buttonText: actionType == .addBalance ? "addBalance".localized() : "withdrawBalance".localized(), isEnabled: true) {
                    switch actionType {
                    case .addBalance:
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        navigateToAddBalance = true
                        isSheetPresented = false
                        
                    case .withDraw:
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        navigateToWithDrawView = true
                        isSheetPresented = false
                    case .none:
                        return
                    }
                }
            }
            .onChange(of: viewModel._isWithdrawSuccess, { _, newValue in
                if newValue {
                    print("Balance withdraw successfully")
                    isSheetPresented = false
                }
            })
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
            else {
                ProgressView().hidden()
            }
        }
        .toastView(toast: $viewModel.toast)
        .onChange(of: viewModel.paymentURL) { _, newValue in
            isSheetPresented = false
            paymentURL = viewModel.paymentURL
            navigateToWebView = true
        }
       
//        .navigationDestination(isPresented: $navigateToWebView) {
//            PaymentWebView(url: viewModel.paymentURL)
//        }
        //        .onTapGesture {
        //            hideKeyboard() // Ensures keyboard is dismissed on any tap outside the TextField
        //        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    

//    func authenticate() {
//        let context = LAContext()
//        var error: NSError?
//
//        // Check if device supports authentication
//        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//            let reason = "We need to unlock your passwords."
//
//            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
//                DispatchQueue.main.async {
//                    if success {
//                        // Authentication Successful
//                        print("Authentication Successful")
//                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
//                        viewModel.validateWithdrawAmount(amount: amountDouble)
//                    } else {
//                        // Authentication Failed
//                        if let error = authenticationError as NSError? {
//                            print("Authentication failed with error: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//        } else {
//            // No Biometrics or Passcode set
//            if let error = error {
//                print("Authentication not available: \(error.localizedDescription)")
//            }
//            amountDouble = Double(amount.convertDigitsToEng) ?? 0
//            viewModel.validateWithdrawAmount(amount: amountDouble)
//        }
//    }


}

//#Preview {
//    AddWithdrawBottomSheet(amountDouble: .constant(0))
//}






// QRCodeScannerView to handle QR code scanning
struct QRCodeScannerViewHome: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var onCodeScanned: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }
        
        func didFindCode(_ code: String) {
            onCodeScanned(code)
        }
    }
}

// ScannerViewController to handle camera and QR code scanning
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var delegate: ScannerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            guard session.canAddInput(videoInput) else { return }
            session.addInput(videoInput)
        } catch { return }

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.layer.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)

        captureSession = session
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "camera_permission_title".localized(),
            message: "camera_permission_message".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "go_to_settings".localized(), style: .default) { [weak self] _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted {
            showPermissionDeniedAlert()
            return
        }
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
            captureSession?.stopRunning()
            dismiss(animated: true)
        }
    }
}

protocol ScannerViewControllerDelegate {
    func didFindCode(_ code: String)
}





