//
//  PasscodeChallengeViewController.swift
//  Dafeaa
//
//  Created by AMNY on 06/05/2026.
//

import SwiftUI

// MARK: - PasscodeChallengeView
struct PasscodeChallengeView: View {
    var message: String = ""
    var isSessionExpiry: Bool = false
    var onResult: (Bool) -> Void
    
    @State private var enteredCode: String = ""
    @State private var attempts = 0
    @State private var shake = false
    @State private var errorMessage: String? = nil
    
    private let maxAttempts = 4
    private let codeLength = 6
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Cancel (top right)
            HStack {
                Spacer()
                Button {
                    if isSessionExpiry {
                        forceLogout()
                    }
                    onResult(false)
                } label: {
                    Text("cancel".localized())
                        .textModifier(.plain, 16, .redFA4248)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)

            // MARK: - User Image
            if let imageUrl = GenericUserDefault.shared.getValue(Constants.shared.userImage) as? String,
               !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(Color(.gray979797))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.primaryF9CE29), lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(Color(.gray979797))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color(.primaryF9CE29), lineWidth: 2))
            }
            
            // MARK: - Welcome
            let trailingText = message == "authenticate_to_continue".localized() ? " 👋":""
            Text(message + Constants.userName +  trailingText)
                .textModifier(.plain, 19, .black222222)
                .lineLimit(2)
                .padding(.top, 16)
                .padding(.horizontal,24)
            // MARK: - Error
            if let error = errorMessage {
                Text(error)
                    .textModifier(.plain, 13, .redFA4248)
                    .padding(.top, 12)
            }
        
            Spacer().frame(height: 16)
            // MARK: - Dots
            HStack(spacing: 16) {
                ForEach(0..<codeLength, id: \.self) { index in
                    Circle()
                        .fill(index < enteredCode.count ? Color(.primaryF9CE29) : Color(.grayE7E7E7))
                        .frame(width: 16, height: 16)
                }
            }
            .modifier(ShakeEffect(shakes: shake ? 4 : 0))
            .animation(.default, value: shake)
            
            
            // MARK: - Forgot passcode
            Button {
                // Forgot = force logout to login screen
                QuickPasscodeManager.shared.delete()
                forceLogout()
                onResult(false)
            } label: {
                Text("forgotQuickPasscode".localized())
                    .textModifier(.plain, 14, Color(.primaryF9CE29))
            }
            .padding(.top, 20)
            
            Spacer()
            
            // MARK: - Number Pad
            numberPad
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Number Pad
    private var numberPad: some View {
        VStack(spacing: 16) {
            ForEach(0..<4) { row in
                HStack(spacing: 28) {
                    ForEach(0..<3) { col in
                        switch padItem(row: row, col: col) {
                        case .number(let digit):
                            numberButton(digit: digit)
                        case .biometric:
                            biometricButton
                        case .delete:
                            deleteButton
                        case .empty:
                            Color.clear.frame(width: 70, height: 70)
                        }
                    }
                }
            }
        }
    }
    
    private func numberButton(digit: Int) -> some View {
        Button {
            appendDigit(digit)
        } label: {
            Text(String(format: "%d", digit))
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.black222222)
                .frame(width: 70, height: 70)
                .environment(\.locale, Locale(identifier: "en_US"))
        }
    }
    
    private var biometricButton: some View {
        Group {
            let isBiometricOn = UserDefaults.standard.bool(forKey: Constants.shared.biometricKey)
            let isAvailable = BiometricAuthManager.shared.isBiometricAvailable
            
            if isBiometricOn && isAvailable {
                Button {
                    triggerBiometric()
                } label: {
                    Image(systemName: BiometricAuthManager.shared.biometricType == "Face ID" ? "faceid" : "touchid")
                        .font(.system(size: 28))
                        .foregroundColor(.black222222)
                        .frame(width: 70, height: 70)
                }
            } else {
                Color.clear.frame(width: 70, height: 70)
            }
        }
    }
    
    private var deleteButton: some View {
        Button {
            deleteDigit()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 22))
                .foregroundColor(.black222222)
                .frame(width: 70, height: 70)
        }
        .opacity(enteredCode.isEmpty ? 0.3 : 1)
        .disabled(enteredCode.isEmpty)
    }
    
    // MARK: - Pad Layout
    private enum PadItem {
        case number(Int)
        case biometric
        case delete
        case empty
    }
    
    private func padItem(row: Int, col: Int) -> PadItem {
        switch (row, col) {
        case (0, 0): return .number(1)
        case (0, 1): return .number(2)
        case (0, 2): return .number(3)
        case (1, 0): return .number(4)
        case (1, 1): return .number(5)
        case (1, 2): return .number(6)
        case (2, 0): return .number(7)
        case (2, 1): return .number(8)
        case (2, 2): return .number(9)
        case (3, 0): return .biometric
        case (3, 1): return .number(0)
        case (3, 2): return .delete
        default: return .empty
        }
    }
    
    // MARK: - Actions
    private func appendDigit(_ digit: Int) {
        guard enteredCode.count < codeLength else { return }
        enteredCode += "\(digit)"
        errorMessage = nil
        
        // Auto-verify when 6 digits entered
        if enteredCode.count == codeLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                verifyCode()
            }
        }
    }
    
    private func deleteDigit() {
        guard !enteredCode.isEmpty else { return }
        enteredCode.removeLast()
        errorMessage = nil
    }
    
    private func verifyCode() {
        guard let saved = QuickPasscodeManager.shared.load(), enteredCode == saved else {
            attempts += 1
            if attempts >= maxAttempts {
                onResult(false)
                forceLogout()
                MOLH.reset()
                return
            }
            errorMessage = "incorrectPasscode".localized() + " (\(maxAttempts - attempts) " + "attemptsRemaining".localized() + ")"
            shake.toggle()
            enteredCode = ""
            return
        }
        onResult(true)
    }
    
    private func triggerBiometric() {
        BiometricAuthManager.shared.authenticate { success, _ in
            if success {
                onResult(true)
            }
        }
    }
    private func forceLogout() {
        DispatchQueue.main.async {
            GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
            GenericUserDefault.shared.setValue("", Constants.shared.token)
            MOLH.reset()
        }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0))
    }
}

final class PasscodeChallengePresenter {
    static func show(message: String = "", isSessionExpiry: Bool = false, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                completion(false)
                return
            }

            // Declared before challengeView so the closure captures the variable reference,
            // not its nil value — assigned below after hc is created.
            var hostingController: UIHostingController<PasscodeChallengeView>?

            let challengeView = PasscodeChallengeView(message: message, isSessionExpiry: isSessionExpiry, onResult: { success in
                // Dismiss only this passcode VC, not the entire presentation stack from root.
                // Using window.rootViewController?.dismiss would kill any other presented sheet
                // (e.g. QRDeeplinkBottomSheet) that sits beneath this passcode challenge.
                hostingController?.dismiss(animated: true) {
                    completion(success)
                }
            })

            let hc = UIHostingController(rootView: challengeView)
            hc.modalPresentationStyle = .fullScreen
            hostingController = hc

            var topVC = window.rootViewController!
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(hc, animated: true)
        }
    }
}
