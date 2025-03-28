//
//  AddWithdrawButtomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 27/10/2024.
//

import SwiftUI
import LocalAuthentication

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
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 16) {
                
                Text(actionType == .addBalance ? "addWalletBalance".localized() : "withdrawWalletBalance".localized())
                    .textModifier(.plain, 19, .black222222)
                
                //                Spacer(minLength: 10) // Control minimum spacing
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
                TextField("0", text: $amount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textModifier(.plain, 43, .black2B2D33)
                    .frame(minHeight: 50) // Explicit height for text field
                
                Text(actionType == .addBalance ? "noExtraFees".localized() : "weWillContactYou".localized())
                    .textModifier(.plain, 17, actionType == .addBalance ? .gray919191 : Color(.redD73D24))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                //                Spacer(minLength: 10) // Control minimum spacing
                
                ReusableButton(buttonText: actionType == .addBalance ? "addBalance".localized() : "withdrawBalance".localized(), isEnabled: true) {
                    switch actionType {
                    case .addBalance:
//                        actionFinished = true
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        viewModel.addAmount(amount: amountDouble)
                        
                    case .withDraw:
                        authenticate()
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
            .background(Color.white)
            .cornerRadius(24)
            .frame(height: UIScreen.main.bounds.height * 0.6)
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
    

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if device supports authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your passwords."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication Successful
                        print("Authentication Successful")
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        viewModel.validateWithdrawAmount(amount: amountDouble)
                    } else {
                        // Authentication Failed
                        if let error = authenticationError as NSError? {
                            print("Authentication failed with error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            // No Biometrics or Passcode set
            if let error = error {
                print("Authentication not available: \(error.localizedDescription)")
            }
            amountDouble = Double(amount.convertDigitsToEng) ?? 0
            viewModel.validateWithdrawAmount(amount: amountDouble)
        }
    }


}

//#Preview {
//    AddWithdrawBottomSheet(amountDouble: .constant(0))
//}

import SwiftUI
import AVFoundation
import UIKit



struct BuyProductBottomSheet: View {
    @StateObject var viewModel = HomeVM()
    @State private var number: String = ""
    @Binding var isShowClientLinkDetails: Bool
    @Binding var isShowOrderLinkDetails: Bool
    let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
    @Binding var offerData: ShowOfferData?
    @Binding var isSheetPresented: Bool
    @State private var isShowingScanner = false // State to control QR code scanner sheet
    @State private var showImagePhotoLibrary = false
    @State var selectedImage: UIImage?
    @State var toast: FancyToast? = nil

    var body: some View {
        ZStack {
            Color.clear

            VStack {
                Text("search_offer".localized())
                    .textModifier(.semiBold, 19, .gray919191)
                    .padding(.bottom)
                    .padding(.top, 50)
                HStack {
                    Text("search_by_number".localized())
                        .textModifier(.plain, 16, .gray919191)
                }
                .padding(.horizontal)
                Spacer()
                TextField("code".localized(), text: $number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textModifier(.plain, 43, .black2B2D33)
                    .frame(minHeight: 50) // Explicit height for text field
                Spacer()
                HStack {
                    Button {
                        isShowingScanner = true // Show QR code scanner
                    } label: {
                        HStack(alignment: .center,spacing: 5) {
                            Text("search_by_QR_code".localized())
                                .textModifier(.plain, 12, .primaryF9CE29)
                                .underline()
                            //                            .padding(.bottom)
                            Image(.qrPrimary)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .padding(.bottom)
                    }
                    
                    
                    Button {
                        showImagePhotoLibrary = true
                    } label: {
                        HStack(alignment: .center,spacing: 5) {
                            Text("or".localized())
                                .textModifier(.plain, 12, .gray)
                            Text("search_by_Scan_Image_QR_code".localized())
                                .textModifier(.plain, 12, .primaryF9CE29)
                                .underline()
                            //                            .padding(.bottom)
                        }
                        .padding(.bottom)
                    }
                }
                ReusableButton(buttonText: "search", isEnabled: true) {
                    viewModel.handleFindOfferByNum(code: number)
                }
                .padding(.bottom,20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)
            .frame(height: UIScreen.main.bounds.height * 0.45)
            .toastView(toast: $viewModel.toast)
            .onChange(of: viewModel.offerData) { oldValue, newValue in
                self.offerData = newValue
                if newValue?.clientId == userId {
                    isShowOrderLinkDetails = true
                    isSheetPresented = false
                } else {
                    isShowClientLinkDetails = true
                    isSheetPresented = false
                }
            }
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else {
                ProgressView()
                    .hidden()
            }
        }
        .sheet(isPresented: $showImagePhotoLibrary) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .onChange(of: selectedImage, { oldValue, newValue in
            scanQRCode(from: selectedImage ?? UIImage())
        })
        .toastView(toast: $toast)
        .toastView(toast: $viewModel.toast)
        .sheet(isPresented: $isShowingScanner) {
            QRCodeScannerViewHome { code in
                isShowingScanner = false
                 let offerCode = String(code)
                    number = code
                
            }
        }
    }

    private func scanQRCode(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Failed to convert UIImage to CIImage")
            return
        }

        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )

        guard let features = detector?.features(in: ciImage) as? [CIQRCodeFeature], !features.isEmpty else {
//            print("No QR Code detected")
            toast = FancyToast(type: .error, title: "", message: "No QR Code detected")
            return
        }

        for feature in features {
            if let code = feature.messageString {
                DispatchQueue.main.async {
                    self.number = code
                    print("Scanned QR Code: \(code)")
//                    viewModel.handleFindOfferByNum(code: code)
                }
                break
            }
        }
    }
}

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
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: ScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
            captureSession.stopRunning()
            dismiss(animated: true)
        }
    }
}

protocol ScannerViewControllerDelegate {
    func didFindCode(_ code: String)
}





