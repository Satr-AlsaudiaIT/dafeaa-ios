//
//  ProfileCompletionGuard.swift
//  Dafeaa
//
//  Created by AMNY on 27/04/2026.
//

import SwiftUI

// MARK: - Profile Incomplete Popup View
struct ProfileIncompletePopup: View {
    @Binding var isPresented: Bool
    var onCompleteProfile: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                    Text("account_not_verified_title".localized())
                        .textModifier(.bold, 21, .black222222)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)

                    Text("account_not_verified_body".localized())
                        .textModifier(.plain, 14, .black222222)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)

                    ReusableButton(buttonText: "complete_data_button".localized()) {
                        isPresented = false
                        onCompleteProfile()
                    }
                    .frame(width: UIScreen.main.bounds.width / 2.5, height: 46)
                    .padding(.top, 32)

                    Button {
                        isPresented = false
                    } label: {
                        Text("later_button".localized())
                            .textModifier(.plain, 14, .black000000).underline()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
    }
}

// MARK: - View Modifier for easy usage anywhere
struct ProfileIncompletePopupModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onCompleteProfile: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                ProfileIncompletePopup(
                    isPresented: $isPresented,
                    onCompleteProfile: onCompleteProfile
                )
            }
    }
}

extension View {
    func profileIncompletePopup(
        isPresented: Binding<Bool>,
        onCompleteProfile: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ProfileIncompletePopupModifier(
                isPresented: isPresented,
                onCompleteProfile: onCompleteProfile
            )
        )
    }
}
