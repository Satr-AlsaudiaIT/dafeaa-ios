//
//  BuyProductBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 26/04/2025.
//
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
