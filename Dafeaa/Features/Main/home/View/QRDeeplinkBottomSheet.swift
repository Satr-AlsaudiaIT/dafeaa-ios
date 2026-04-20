//
//  QRDeeplinkState.swift
//  Dafeaa
//
//  Created by AMNY on 13/04/2026.
//


import SwiftUI

enum QRDeeplinkState {
    case loading
    case success
    case failure
}

struct QRDeeplinkBottomSheet: View {

    @Binding var isPresented: Bool
    @Binding var qrCode: String
    var onSuccess: (() -> Void)? = nil

    @StateObject private var walletViewModel = WalletVM()
    @State private var state: QRDeeplinkState = .loading
    @State private var hasStarted: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            switch state {

            // MARK: Loading
            case .loading:
                Image(.waitPayment)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .padding(.bottom, 8)

                Text("waiting_payment".localized())
                    .textModifier(.bold, 24, .black222222)

            // MARK: Success
            case .success:
                Image(.transferSuccess)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(.bottom, 8)

                Text("transfer_success_title".localized())
                    .textModifier(.bold, 24, .black222222)

                Text("transfer_success_body_other".localized())
                    .textModifier(.plain, 16, .gray667085)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                closeButton {
                    clearAndDismiss()
                    onSuccess?()
                }

            // MARK: Failure
            case .failure:
                Image(.transferFailed)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(.bottom, 8)

                Text("transfer_failed_title".localized())
                    .textModifier(.bold, 24, .black222222)

                closeButton {
                    clearAndDismiss()
                }
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 40)
        .interactiveDismissDisabled(true)
        .onAppear {
            startIfNeeded(code: qrCode)
        }
        .onChange(of: qrCode) { _, newCode in
            startIfNeeded(code: newCode)
        }
        .onChange(of: walletViewModel.acceptQRResult) { _, result in
            guard let result = result else { return }
            switch result {
            case .success:
                state = .success
            case .failure:
                state = .failure
            }
        }
    }

    // MARK: - Helpers

    private func startIfNeeded(code: String) {
        guard !code.isEmpty, !hasStarted else { return }
        hasStarted = true
        walletViewModel.acceptQR(qrCode: code)
    }

    /// Clears the shared qrCode binding and dismisses — only called on success/failure close
    private func clearAndDismiss() {
        qrCode = ""          // now safe to clear — API is done
        isPresented = false
    }

    // MARK: - Close Button
    @ViewBuilder
    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("close".localized())
                .textModifier(.bold, 15, .white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black222222)
                .cornerRadius(26)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}
