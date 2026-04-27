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
            // If already authenticating, just add the new request to the queue.
            // This prevents overlapping prompts!
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
        let reason = message.isEmpty ? "authenticate_to_continue".localized() : message
        
        // .deviceOwnerAuthentication automatically handles biometrics AND passcode fallback natively
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
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
        // Fire all queued actions (e.g., both the 401 refresh AND the deeplink logic)
        completions.forEach { $0(success, wasCancelled) }
    }
}
