//
//  SecuritySetupBottomSheet.swift
//  Dafeaa
//

import SwiftUI

struct SecuritySetupBottomSheet: View {
    var phone: String
    @ObservedObject var activeVM: AuthVM
    @Binding var isPresented: Bool
    /// Called after the sheet closes.
    /// - Parameter passcodeSelected: true → caller should navigate to passcode setup
    var onSetupComplete: (_ passcodeSelected: Bool) -> Void

    @State private var biometricSelected: Bool = false
    @State private var passcodeSelected: Bool = false
    @State private var showBiometricNotAvailableAlert: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Title
            Text("securitySetupTitle".localized())
                .textModifier(.semiBold, 20, .black222222)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 28)
                .padding(.bottom, 32)
                .padding(.horizontal, 24)

            // MARK: Biometric option
            optionRow(
                title: "enable_biometric_authentication".localized(),
                icon: AnyView(
                    Image(systemName: "touchid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(.black222222))
                ),
                isSelected: biometricSelected
            ) {
                if biometricSelected {
                    // Deselecting — no auth needed
                    biometricSelected = false
                } else {
                    guard BiometricAuthManager.shared.isBiometricAvailable else {
                        showBiometricNotAvailableAlert = true
                        return
                    }
                    BiometricAuthManager.shared.authenticate { success, _ in
                        if success { biometricSelected = true }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            // MARK: Passcode option
            optionRow(
                title: "enable_quick_passcode".localized(),
                icon: AnyView(
                    Image(.passcodeBottomSheet)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 28)
                        .foregroundColor(Color(.black222222))
                ),
                isSelected: passcodeSelected
            ) {
                passcodeSelected.toggle()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // MARK: Confirm button
            ReusableButton(buttonText: "confirm") {
                handleConfirm()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .alert("biometric_not_available_title".localized(), isPresented: $showBiometricNotAvailableAlert) {
            Button("go_to_settings".localized()) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel".localized(), role: .cancel) {}
        } message: {
            Text("biometric_not_available_message".localized())
        }
    }

    // MARK: - Row builder
    @ViewBuilder
    private func optionRow(
        title: String,
        icon: AnyView,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                icon
                Text(title)
                    .textModifier(.plain, 14, .black292D32)
                    .lineLimit(1)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(.primary) : Color(.gray616161))
            }
            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
        }
        .frame(height: 60)
        .contentShape(Rectangle())
    }

    // MARK: - Logic
    private func handleConfirm() {
        if biometricSelected {
            QuickPasscodeManager.shared.setBiometricEnabled(true, forPhone: phone)
        }
        isPresented = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onSetupComplete(passcodeSelected)
        }
    }
}
