//
//  LoginSheetView.swift
//  Dafeaa
//
//  Created by AMNY on 03/03/2026.
//

import SwiftUI



struct LoginSheetView: View {
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var showForgetPassword: Bool = false
    @State private var isShowStep1: Bool = false
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?

    var onLoginSuccess: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12) {

                    VStack(spacing: 5) {
                        HStack {
                            Text("loginWelcome".localized())
                                .textModifier(.plain, 19, .black222222)
                            Spacer(minLength: 0)
                        }
                        HStack {
                            Text("loginWelcomeSubtitle".localized())
                                .textModifier(.plain, 15, .grayAAAAAA)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.top, 24)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            PhoneNumberField(
                                phoneNumber: $phoneNumber,
                                selectedCountryCode: $selectedCountryCode,
                                image: .mobile)
                            .focused($focusedField, equals: .phone)

                            CustomPasswordField(password: $password)
                                .focused($focusedField, equals: .password)

                            ReusableButton(buttonText: "login") {
                                viewModel.validateLogin(
                                    phone: phoneNumber.normalizePhoneNumber,
                                    password: password,
                                    isFromGuestMode: true)
                            }
                            .padding(.top, 4)

                            // ── Forgot Password ──
                            Button {
                                showForgetPassword = true
                            } label: {
                                Text("forgetPassword".localized())
                                    .textModifier(.plain, 15, .gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // ── Sign Up ──
                    HStack {
                        Text("haventAccount".localized())
                            .textModifier(.plain, 16, .black222222)
                        Button {
                            isShowStep1 = true
                        } label: {
                            Text("openAccount".localized())
                                .textModifier(.plain, 16, Color(.primary))
                        }
                    }
                    .padding(.bottom, 20)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Done".localized()) { hideKeyboard() }
                        Spacer()
                        Button { focusedField = .phone } label: {
                            Image(systemName: "chevron.up").foregroundColor(.blue)
                        }
                        Button { focusedField = .password } label: {
                            Image(systemName: "chevron.down").foregroundColor(.blue)
                        }
                    }
                }

                // ── Navigation Destinations ──
                .navigationDestination(isPresented: $showForgetPassword) {
                    ForgotPasswordView()
                }
                .navigationDestination(isPresented: $isShowStep1) {
                    SignUpStep2View()
                }
                .navigationDestination(isPresented: $viewModel._isSendCodeSuccess) {
                    OTPConfirmationView(phone: phoneNumber.normalizePhoneNumber)
                }
                .navigationDestination(isPresented: $viewModel._hasUnCompletedData) {
                    CompleteDataView(phone: phoneNumber.normalizePhoneNumber)
                }
                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView().hidden()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                phoneNumber = ""
                password = ""
            }
            .onChange(of: viewModel.isLoginSuccess) { _, success in
                if success { onLoginSuccess() }
            }
            .toastView(toast: $viewModel.toast)
        }
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large])
        .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    enum FormField { case phone, password }
}
