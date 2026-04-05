//
//  AppActionSheet.swift
//  Dafeaa
//
//  Created by AMNY on 04/04/2026.
//

import SwiftUI

// MARK: - Action Sheet Case
enum AppActionSheetCase {
    case logOut
    case deleteAccount
    case changeLanguage
    case custom(
        title: String,
        message: String,
        confirmTitle: String,
        isDestructive: Bool
    )

    var title: String {
        switch self {
        case .logOut:                   return "logout".localized()
        case .deleteAccount:            return "deleteAccount".localized()
        case .changeLanguage:           return "languageApp".localized()
        case .custom(let t, _, _, _):   return t
        }
    }

    var message: String {
        switch self {
        case .logOut:                   return "logOutAlert".localized()
        case .deleteAccount:            return "deleteAccountAlert".localized()
        case .changeLanguage:           return "Select your preferred language".localized()
        case .custom(_, let m, _, _):   return m
        }
    }

    var confirmTitle: String {
        switch self {
        case .logOut:                   return "logout".localized()
        case .deleteAccount:            return "deleteAccount".localized()
        case .changeLanguage:           return "" // unused
        case .custom(_, _, let c, _):   return c
        }
    }

    var isDestructive: Bool {
        switch self {
        case .logOut:                   return false
        case .deleteAccount:            return true
        case .changeLanguage:           return false
        case .custom(_, _, _, let d):   return d
        }
    }
}
// MARK: - Sheet View
struct AppActionSheetView: View {
    let sheetCase: AppActionSheetCase
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    var onExtraAction: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                // Title + Message
                VStack(spacing: 8) {
                    Text(sheetCase.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Text(sheetCase.message)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()

                // Buttons based on case
                switch sheetCase {
                case .changeLanguage:
                    // English Button
                    Button(action: { onExtraAction?("en") }) {
                        Text("English")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }

                    Divider()

                    // Arabic Button
                    Button(action: { onExtraAction?("ar") }) {
                        Text("عربي")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }

                default:
                    // Single Confirm Button
                    Button(action: onConfirm) {
                        Text(sheetCase.confirmTitle)
                            .font(.system(size: 20))
                            .foregroundColor(sheetCase.isDestructive ? .red : .blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }

                Divider()

                // Cancel Button
                Button(action: onCancel) {
                    Text(cancelTitle)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(14)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .ignoresSafeArea()
    }
}
// MARK: - Modifier
struct AppActionSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let sheetCase: AppActionSheetCase
    let cancelTitle: String
    let onConfirm: () -> Void
    var onExtraAction: ((String) -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { dismiss() }

                    AppActionSheetView(
                        sheetCase: sheetCase,
                        cancelTitle: cancelTitle,
                        onConfirm: {
                            dismiss()
                            onConfirm()
                        },
                        onCancel: { dismiss() },
                        onExtraAction: { key in
                            dismiss()
                            onExtraAction?(key)
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.25), value: isPresented)
                }
            }
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
    }
}

// MARK: - View Extension
extension View {
    func appActionSheet(
        isPresented: Binding<Bool>,
        case sheetCase: AppActionSheetCase,
        cancelTitle: String = "Cancel".localized(),
        onConfirm: @escaping () -> Void = {},
        onExtraAction: ((String) -> Void)? = nil
    ) -> some View {
        self.modifier(
            AppActionSheetModifier(
                isPresented: isPresented,
                sheetCase: sheetCase,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm,
                onExtraAction: onExtraAction
            )
        )
    }
}
