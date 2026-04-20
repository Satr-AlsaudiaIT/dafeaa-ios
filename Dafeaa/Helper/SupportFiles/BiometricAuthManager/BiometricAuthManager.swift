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
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            performPasscodeAuthentication(message: message)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason:"authenticate_to_continue".localized()
        ) { success, error in
            DispatchQueue.main.async {
                let wasCancelled = (error as? LAError)?.code == .userCancel
                self.finishAuthentication(success: success, wasCancelled: wasCancelled, message: message)
            }
        }
    }

    private func performPasscodeAuthentication(message: String) {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "authenticate_to_continue".localized() 
        ) { success, error in
            DispatchQueue.main.async {
                let wasCancelled = (error as? LAError)?.code == .userCancel
                self.finishAuthentication(success: success, wasCancelled: wasCancelled, message: message)
            }
        }
    }

    private func finishAuthentication(success: Bool, wasCancelled: Bool, message: String) {
        isAuthenticating = false
        let completions = pendingCompletions
        pendingCompletions = []
        completions.forEach { $0(success, wasCancelled) }
    }
}
