//
//  BiometricAuthManager.swift
//  Dafeaa
//
//  Created by AMNY on 20/04/2026.
//

import LocalAuthentication

class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    private var isChainActive = false
    private var chainQueue: [(Bool) -> Void] = []

    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    // True only when Face ID/Touch ID is locked out after too many failed scans.
    // Used to skip the biometric prompt entirely and fall straight to passcode.
    private var isBiometricLockedOut: Bool {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return (error as? LAError)?.code == .biometryLockout
    }

    var biometricType: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometric"
        }
    }

    var isBiometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: Constants.shared.biometricKey)
    }

    func authenticate(message: String = "", completion: @escaping (Bool, Bool) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        let reason = message.isEmpty ? "authenticate_to_continue".localized() : message
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, (error as? LAError)?.code == .userCancel)
            }
        }
    }

    func authenticateWithFullChain(message: String = "", isSessionExpiry: Bool = false, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            if self.isChainActive {
                self.chainQueue.append(completion)
                return
            }
            self.isChainActive = true
            self.runChain(message: message, isSessionExpiry: isSessionExpiry) { success in
                completion(success)
                self.isChainActive = false
                let waiting = self.chainQueue
                self.chainQueue = []
                waiting.forEach { $0(success) }
            }
        }
    }

    func authenticateForTransaction(message: String = "", completion: @escaping (Bool) -> Void) {
        authenticateWithFullChain(message: message, isSessionExpiry: false, completion: completion)
    }

    private var isPasscodeEnabled: Bool {
        QuickPasscodeManager.shared.isEnabled && QuickPasscodeManager.shared.hasPasscode
    }

    private func runChain(message: String, isSessionExpiry: Bool, completion: @escaping (Bool) -> Void) {
        let biometricOn = isBiometricEnabled && isBiometricAvailable && !isBiometricLockedOut
        let passcodeOn = isPasscodeEnabled

        if biometricOn {
            tryBiometric(message: message, attemptsLeft: 1) {
                if passcodeOn {
                    PasscodeChallengePresenter.show(message: message, isSessionExpiry: isSessionExpiry) { completion($0) }
                } else {
                    if isSessionExpiry { self.forceLogout() }
                    completion(false)
                }
            } completion: { completion(true) }
        } else if passcodeOn {
            PasscodeChallengePresenter.show(message: message, isSessionExpiry: isSessionExpiry) { completion($0) }
        } else {
            if isSessionExpiry { forceLogout() }
            completion(false)
        }
    }

    // Each runChain call gets a fresh 3 cancellation attempts.
    // A failed scan or lockout falls through immediately.
    private func tryBiometric(message: String, attemptsLeft: Int,
                               onExhausted: @escaping () -> Void,
                               completion: @escaping () -> Void) {
        guard attemptsLeft > 0 else { onExhausted(); return }

        authenticate(message: message) { success, userCancelled in
            if success {
                completion()
            } else if userCancelled && attemptsLeft > 1 {
                self.tryBiometric(message: message, attemptsLeft: attemptsLeft - 1,
                                  onExhausted: onExhausted, completion: completion)
            } else {
                onExhausted()
            }
        }
    }

    private func forceLogout() {
        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
        GenericUserDefault.shared.setValue("", Constants.shared.token)
        MOLH.reset()
    }
}
