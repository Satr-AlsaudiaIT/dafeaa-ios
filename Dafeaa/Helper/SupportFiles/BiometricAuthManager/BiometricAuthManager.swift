//
//  BiometricAuthManager.swift
//  Dafeaa
//
//  Created by AMNY on 20/04/2026.
//

import LocalAuthentication

class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    private var isAuthenticating = false
    private var pendingCompletions: [(Bool, Bool) -> Void] = []

    /// Check if device has biometric capability (Face ID or Touch ID)
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Returns "Face ID" or "Touch ID" based on device
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

    func authenticate(message: String = "", completion: @escaping (Bool, Bool) -> Void) {
        DispatchQueue.main.async {
            if self.isAuthenticating {
                self.pendingCompletions.append(completion)
                return
            }
            self.isAuthenticating = true
            self.pendingCompletions.append(completion)
            self.performAuthentication(message: message)
        }
    }

    private func performAuthentication(message: String) {
        let context = LAContext()
        
        // No fallback to device passcode — biometric only
        context.localizedFallbackTitle = ""
        
        let reason = message.isEmpty ? "authenticate_to_continue".localized() : message
        
        // .deviceOwnerAuthenticationWithBiometrics = biometric ONLY (no device passcode)
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                let wasCancelled = (error as? LAError)?.code == .userCancel
                self.finishAuthentication(success: success, wasCancelled: wasCancelled)
            }
        }
    }

    private func finishAuthentication(success: Bool, wasCancelled: Bool) {
        isAuthenticating = false
        let completions = pendingCompletions
        pendingCompletions = []
        completions.forEach { $0(success, wasCancelled) }
    }
}
