//
//  QRPaymentBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 08/04/2026.
//

import SwiftUI

enum QRPaymentState {
    case enterAmount
    case scanning
    case expired
}

struct QRPaymentBottomSheet: View {

    @Binding var isPresented: Bool
    var onNavigateToWallet: (() -> Void)? = nil
    @StateObject var viewModel = HomeVM()
    @State private var amountText: String = ""
    @State private var qrState: QRPaymentState = .enterAmount
    @State private var qrImage: UIImage? = nil
    @State private var currentQRCode: String = ""
    @State private var checkStatusQRCode: String = ""
    @State private var pollingTimer: Timer? = nil
    @State private var showQRSuccess: Bool = false
    @State private var showQRFailure: Bool = false
    @State private var toast: FancyToast? = nil
    @StateObject private var timerManager = QRTimerManager()
    @State private var remainingSecondsTemp: Int = 120

    @State private var selectedReason: TransferReason? = nil
    @State private var isReasonDropDownOpen: Bool? = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
            Text("quick_payment".localized())
                .textModifier(.bold, 24, .black222222)
            
            Text(subtitleText)
                .textModifier(.plain, 16, .black222222)
                .padding(.top, 6)
                .padding(.bottom, 32)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .fill(.grayF3F3F6)
                    .frame(width: 256, height: 256)
                
                qrBoxContent
            }
            .frame(width: 256, height: 256)
            .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                TransferReasonDropdown(
                    selectedReason: $selectedReason,
                    isOpen: $isReasonDropDownOpen
                )                    .padding(.top, 30)
                
                amountField
                
                    .padding(.top, 25)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 26)
            
            actionButton
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }.padding(.top,20)
    }
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .onDisappear { stopAllTimers() }
        .onChange(of: viewModel.isQRGenerated) { _, generated in
            guard generated else { return }
            viewModel.isQRGenerated = false
            guard let data = viewModel.qrCodeData else { return }
            currentQRCode     = "https://dafea.com.sa/payments/" + (data.qrCode ?? "")
            checkStatusQRCode = data.qrCode ?? ""
            qrImage           = makeQRImage(from: currentQRCode)
            qrState           = .scanning
            let seconds       = data.expiresTime ?? 120
            remainingSecondsTemp = seconds
            startCountdown()
            startPolling()
        }
        .onChange(of: timerManager.remainingSeconds) { _, val in
            if val <= 0 && qrState == .scanning {
                stopAllTimers()
                qrState = .expired
            }
        }
        .onChange(of: viewModel.qrStatusResult) { _, status in
            guard let status = status else { return }
            stopAllTimers()
            showQRSuccess = status == "completed"
            showQRFailure = status != "completed"
            viewModel.qrStatusResult = nil
        }
        .onChange(of: viewModel.isQRCancelled) { _, _ in
            amountText = ""
            self.toast = viewModel.toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isPresented = false
            }
        }
        .toastView(toast: $toast)
        .appBottomSheet(
            isPresented: Binding(
                get: { showQRSuccess || showQRFailure },
                set: { _ in }
            ),
            detents: [.fraction(0.55)]
        ) {
            VStack(spacing: 20) {
                Image(showQRSuccess ? .transferSuccess : .transferFailed)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(.bottom, 8)

                Text(showQRSuccess ? "transfer_success_title".localized() : "transfer_failed_title".localized())
                    .textModifier(.bold, 24, .black222222)

                Text(showQRSuccess ? "transfer_success_body".localized() : "")
                    .textModifier(.plain, 16, .black222222)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Button {
                    UIApplication.shared.dismissAllPresentedViewControllers {
                        if showQRSuccess { onNavigateToWallet?() }
                    }
                } label: {
                    Text("close".localized())
                        .textModifier(.bold, 16, .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.black222222)
                        .cornerRadius(26)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.top, 32)
            .padding(.bottom, 40)
            .interactiveDismissDisabled(true)
        }
    }

    // MARK: - Subtitle

    private var subtitleText: String {
        switch qrState {
        case .enterAmount: return "enter_amount_to_generate_qr".localized()
        case .scanning:    return "scan_with_in".localized() + timerString
        case .expired:     return "qr_code_expired".localized()
        }
    }

    private var timerString: String {
        let m = timerManager.remainingSeconds / 60
        let s = timerManager.remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - QR Box

    @ViewBuilder
    private var qrBoxContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryF9CE29))
                .scaleEffect(1.5)
        } else {
            switch qrState {
            case .enterAmount:
                VStack(spacing: 8) {
                    Image(.quickPayShare)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    Text("wait_enter_amount".localized())
                        .textModifier(.plain, 12, .gray667085)
                }
            case .scanning:
                if !currentQRCode.isEmpty {
                    QRCodeView(text: currentQRCode)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                }
            case .expired:
                Button { generateQRCode() } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 42)
                            .foregroundColor(.gray667085.opacity(0.9))
                        Text("tap_to_reload".localized())
                            .textModifier(.plain, 12, .gray667085)
                    }
                }
            }
        }
    }

    // MARK: - Amount Field

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("enter_amount".localized())
                .textModifier(.plain, 14, .black222222)

            HStack {
                if #available(iOS 26.0, *) {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(strategy: .layoutBased)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textModifier(.bold, 20, .black000000)
                        .disabled(qrState == .scanning)
                } else {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textModifier(.bold, 20, .black000000)
                        .disabled(qrState == .scanning)
                }
                Spacer()
                Image(.riyal).renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black000000)
                    .frame(width: 18, height: 18)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(.grayE7E7E7)
                    .frame(height: 2),
                alignment: .bottom
            )
        }
    }

    // MARK: - Action Button

    private var isActionDisabled: Bool {
        let normalized = amountText.westernDigits
        let hasAmount  = !normalized.isEmpty && (Double(normalized) ?? 0) > 0
        return qrState == .enterAmount && (!hasAmount || selectedReason == nil)
    }

    private var actionButton: some View {
        Button { handleActionButton() } label: {
            Text(actionButtonTitle)
                .textModifier(.bold, 15, actionButtonTitleColor)
                .frame(maxWidth: 200)
                .frame(height: 52)
                .background(actionButtonBackground)
                .cornerRadius(26)
        }
        .disabled(isActionDisabled)
    }

    private var actionButtonTitle: String {
        switch qrState {
        case .enterAmount:        return "enter_amount".localized()
        case .scanning, .expired: return "cancel_process".localized()
        }
    }

    private var actionButtonBackground: Color {
        switch qrState {
        case .enterAmount:        return isActionDisabled ? .gray8B8C86 : Color.primaryF9CE29
        case .scanning, .expired: return Color.black222222
        }
    }

    private var actionButtonTitleColor: Color {
        switch qrState {
        case .enterAmount:        return isActionDisabled ? .white : .black000000
        case .scanning, .expired: return .white
        }
    }

    // MARK: - Actions

    private func handleActionButton() {
        switch qrState {
        case .enterAmount:        generateQRCode()
        case .scanning, .expired: cancelProcess()
        }
    }

    private func generateQRCode() {
        guard let amount = Double(amountText.westernDigits), amount > 0 else { return }
        guard selectedReason != nil else { return }
        stopAllTimers()
        qrImage = nil
        viewModel.generateQR(amount: amountText.westernDigits,
                             reason: selectedReason?.localized ?? "")
    }

    private func cancelProcess() {
        stopAllTimers()
        if !checkStatusQRCode.isEmpty {
            viewModel.cancelQR(qrCode: checkStatusQRCode)
        }
        qrState              = .enterAmount
        qrImage              = nil
        currentQRCode        = ""
        checkStatusQRCode    = ""
        remainingSecondsTemp = 120
        selectedReason       = nil
    }

    // MARK: - Timers

    private func startCountdown() { timerManager.start(seconds: remainingSecondsTemp) }

    private func stopAllTimers() {
        timerManager.stop()
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard !self.checkStatusQRCode.isEmpty else { return }
            self.viewModel.checkQRStatus(qrCode: self.checkStatusQRCode)
        }
    }

    // MARK: - QR Image

    private func makeQRImage(from string: String) -> UIImage? {
        guard !string.isEmpty,
              let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
