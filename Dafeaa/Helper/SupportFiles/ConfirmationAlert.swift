//
//  ConfirmationAlert.swift
//  Dafeaa
//
//  Created by AMNY on 04/04/2026.
//


// AlertHelper.swift

import SwiftUI

struct ConfirmationAlert {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void
}

extension View {
    func showConfirmationAlert(
        isPresented: Binding<Bool>,
        alert: ConfirmationAlert
    ) -> some View {
        self.onChange(of: isPresented.wrappedValue) { _, newValue in
            if newValue {
                presentAlert(alert: alert) {
                    isPresented.wrappedValue = false
                }
            }
        }
    }
    
    private func presentAlert(alert: ConfirmationAlert, onDismiss: @escaping () -> Void) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            var topViewController = rootViewController
            while let presented = topViewController.presentedViewController {
                topViewController = presented
            }
            
            let alertController = UIAlertController(
                title: alert.title,
                message: alert.message,
                preferredStyle: .alert  
            )
            
            let confirmAction = UIAlertAction(
                title: alert.confirmTitle,
                style: alert.isDestructive ? .destructive : .default
            ) { _ in
                alert.onConfirm()
                onDismiss()
            }
            
            let cancelAction = UIAlertAction(
                title: alert.cancelTitle,
                style: .cancel
            ) { _ in
                onDismiss()
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            topViewController.present(alertController, animated: true)
        }
    }
}
