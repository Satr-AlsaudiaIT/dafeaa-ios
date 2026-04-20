//
//  BiometricAuthManager.swift
//  Dafeaa
//
//  Created by AMNY on 20/04/2026.
//


import LocalAuthentication

class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    func authenticate(message: String = "", completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authenticateWithPasscode(message: message, completion: completion)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "authenticate_to_continue".localized()
        ) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    private func authenticateWithPasscode(message: String = "", completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "authenticate_to_continue".localized()
        ) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
