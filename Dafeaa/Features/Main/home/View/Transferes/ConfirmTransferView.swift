//
//  ConfirmTransferView.swift
//  Dafeaa
//
//  Created by AMNY on 27/04/2025.
//

import SwiftUI
import LocalAuthentication

struct ConfirmTransferView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = HomeVM()

    @State var balance: String = ""
    @State var phoneNumber: String = ""
    @State var amount: String = "0"
    @State var name: String = ""
    @State var fees: String = "0"
    @State var total: Double = 0
    @State var reason: String = ""
    @State private var isTransferSuccess: Bool = false
    @State private var isTransferFailed: Bool = false

    var body: some View {
        ZStack {
            VStack {
                NavigationBarView(title: "confirmTransfer") {
                    presentationMode.wrappedValue.dismiss()
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Available Balance
                        HStack(alignment: .center, spacing: 4) {
                            Text("availableBalance:".localized())
                                .textModifier(.plain, 20, .black000000)
                            HStack {
                                Text("\(balance)")
                                    .textModifier(.plain, 20, .black222222)
                                Image(.riyal)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black222222)
                                    .frame(width: 20)
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }
                        .padding(.bottom, 24)

                        // Recipient Info
                        VStack(spacing: 24) {
                            infoRow(title: "Phone Number", value: phoneNumber)
                            infoRow(title: "Name", value: name)
                            
                            if !reason.isEmpty {
                                infoRow(title: "transfer_reason".localized(), value: reason)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.grayBDBDBD, lineWidth: 1)
                        )
                        .padding(1)
                        .background(Color.white)
                        .cornerRadius(8)

                        // Transaction Details
                        VStack(spacing: 24) {
                            infoRow(
                                title: "amount".localized(),
                                value: "\(String(format: "%.2f", Double(amount) ?? 0))",
                                isPrice: true
                            )
                            infoRow(title: "fees".localized(), value: fees, isPrice: true)
                            infoRow(
                                title: "total".localized(),
                                value: "\(String(format: "%.2f", total))",
                                isPrice: true,
                                color: .black222222
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.grayBDBDBD, lineWidth: 1)
                        )
                        .padding(1)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.top, 8)

                        Spacer()
                    }
                    .padding(24)
                }

                VStack(spacing: 12) {
                    ReusableButton(buttonText: "confirmTransfer") {
                        authenticateWithBiometrics()
                    }

                    ReusableButton(
                        buttonText: "Cancel",
                        isEnabled: true,
                        buttonColor: .transparent,
                        borderColor: .black222222,
                        textColor: .black222222
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)
        .onAppear {
            total = (Double(fees) ?? 0) + (Double(amount) ?? 0)
        }
        .onChange(of: viewModel.isTransferSuccess) { _, newValue in
            if newValue { isTransferSuccess = true }
        }
        .onChange(of: viewModel.isTransferFailed) { _, newValue in
            if newValue { isTransferFailed = true }
        }
        .navigationDestination(isPresented: $isTransferSuccess) {
            SuccessView(
                phoneNumber: phoneNumber,
                date: viewModel.transferData.createdAt ?? "",
                amount: amount,
                name: name,
                referenceNum: viewModel.transferData.transId ?? ""
            )
        }
        .navigationDestination(isPresented: $isTransferFailed) {
            FailedView(
                phoneNumber: phoneNumber,
                date: viewModel.transferData.createdAt ?? "",
                amount: amount,
                name: name,
                referenceNum: viewModel.transferData.transId ?? ""
            )
        }
    }

    // MARK: - Info Row
    private func infoRow(title: String,
                          value: String,
                          isPrice: Bool = false,
                          color: Color = .gray8B8C86) -> some View {
        HStack {
            Text(title.localized())
                .textModifier(.plain, 16, color)
            Spacer()
            HStack {
                Text(value)
                    .textModifier(.plain, 16, color)
                if isPrice {
                    Image(.riyal)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color)
                        .frame(width: 20)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    // MARK: - Biometrics
    private func authenticateWithBiometrics() {
        BiometricAuthManager.shared.authenticateForTransaction(message: "confirm_payment_biometric".localized()) { success in
            if success {
                self.viewModel.confirmTransfer(
                    phone: self.phoneNumber.normalizePhoneNumber,
                    amount: self.total,
                    reason: self.reason
                )
            }
        }
    }
        
        // You can safely delete the old `authenticateWithPasscode()` method in this file.
//    private func authenticateWithBiometrics() {
//        let context = LAContext()
//        var error: NSError?
//        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//            authenticateWithPasscode()
//            return
//        }
//        context.evaluatePolicy(
//            .deviceOwnerAuthenticationWithBiometrics,
//            localizedReason: "confirm_payment_biometric".localized()
//        ) { success, authError in
//            DispatchQueue.main.async {
//                if success {
//                    viewModel.confirmTransfer(
//                        phone: phoneNumber.normalizePhoneNumber,
//                        amount: total,
//                        reason: reason
//                    )
//                } else if let err = authError as? LAError, err.code == .biometryLockout {
//                    authenticateWithPasscode()
//                }
//            }
//        }
//    }
//
//    private func authenticateWithPasscode() {
//        let context = LAContext()
//        context.evaluatePolicy(
//            .deviceOwnerAuthentication,
//            localizedReason: "confirm_payment_biometric".localized()
//        ) { success, _ in
//            DispatchQueue.main.async {
//                if success {
//                    viewModel.confirmTransfer(
//                        phone: phoneNumber.normalizePhoneNumber,
//                        amount: total,
//                        reason: reason
//                    )
//                }
//            }
//        }
//    }
}

#Preview { ConfirmTransferView() }
