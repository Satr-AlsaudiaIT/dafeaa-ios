//
//  OTPConfirmationView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

struct OTPConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FocusState private var focusedField: Int?
    @State var phone: String  = ""
    @State var password: String  = ""
    @State var isChangePhone: Bool = false
    @State var isForgetPassword: Bool = false
    @State var isLogoutFromDevices: Bool = false
    @State var code: String = ""
    // NEW: login OTP params
    var isLoginOTP: Bool = false
    @StateObject var viewModel = AuthVM()
    @State private var pins: [PinInfo] = [
        PinInfo(pin: "", focus: .pinOne),
        PinInfo(pin: "", focus: .pinTwo),
        PinInfo(pin: "", focus: .pinThree),
        PinInfo(pin: "", focus: .pinFour)
    ]
    @State private var timer: Timer?
    @State private var secondsRemaining = 60 // in seconds
    @State private var showResendButton = false
    @State private var goToQuickPasscode = false
    @State private var showSecuritySetupSheet = false
    @State private var goToPasscodeSetupFromSheet = false
    @FocusState private var pinFocusState: FocusPin?
    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "ConfirmPhoneNavTitle"){
                    NavigationUtil.popToRootView()
                }
                
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing: 0) {
                        Image(.otp)
                            .resizable()
                            .frame(width: 144, height: 144)
                        
                        Text("confirmPhone".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 24)
                        
                        Text("confirmPhoneSubTitle".localized())
                            .textModifier(.plain, 15, .gray666666)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)

                        
                            HStack(spacing: 16) {
                                ForEach(0..<4) { index in
                                    TextField("0", text: $pins[index].pin)
                                        .frame(width: 65, height: 65, alignment: .center)
                                        .multilineTextAlignment(.center)
                                        .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 30)).minimumScaleFactor(0.7)
                                        .modifier(OtpModifier(pinInfo: $pins[index]))
                                        .onChange(of: pins[index].pin) { _, newVal in
                                            if newVal == " " {
                                                pins[index].pin = ""
                                                pinFocusState = pins[index].focus
                                            } else if newVal.count > 1 {
                                                // Keep only the last typed digit, overwrite any existing value
                                                pins[index].pin = String(newVal.last!)
                                                if index != 3 {
                                                    pinFocusState = pins[min(index + 1, pins.count - 1)].focus
                                                } else {
                                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                }
                                            } else if newVal.count == 1 && index != 3 {
                                                let nextIndex = min(index + 1, pins.count - 1)
                                                pinFocusState = pins[nextIndex].focus
                                            } else if newVal.count == 1 && index == 3 {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            } else if newVal.count == 0 {
                                                let previousIndex = max(index - 1, 0)
                                                pinFocusState = pins[previousIndex].focus
                                                pins[index].pin = ""
                                            }
                                        }
                                        .focused($pinFocusState, equals: pins[index].focus)
                                }
                            }
                            .environment(\.layoutDirection, .leftToRight)
                        .padding(.top, 12)
                        
                        if isChangePhone {
                            HStack(alignment: .top, spacing: 10) {
                                // Checkbox
                                Button(action: {
                                    isLogoutFromDevices.toggle()
                                }) {
                                    Image(systemName: isLogoutFromDevices ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isLogoutFromDevices ? Color(.primary) : .gray)
                                        .font(.system(size: 24))
                                }
                                
                                // Text with attributed clickable parts
                                Text("logOutFromDevicesMessage".localized())
                                    .textModifier(.plain, 15, .gray666666)
                                Spacer()
                            }
                            .padding(.top)
                           
                        }
                            
                        ReusableButton(buttonText: "confirm") {
                            code = ""
                            for index in (0..<4) {
                                code += "\(pins[index].pin)"
                            }
                            print("OTP Code: \(code)")
                            
                            if isLoginOTP {
                                // NEW: login OTP → uses same verify API, then profile → home
                                viewModel.validateLoginOTP(phone: phone.normalizePhoneNumber, code: code)
                            } else if isChangePhone {
                                viewModel.validateChangePhoneCode(phone: phone.normalizePhoneNumber, password: password, code: code, expireAuth: isLogoutFromDevices ?  1 : 0)
                            } else {
                                viewModel.validateVerify(phone: phone.normalizePhoneNumber, code: code, isForgetPassword: isForgetPassword)
                            }
                        }
                        .padding(.top, 16)
                        .navigationDestination(isPresented: $viewModel._isVerifyCodeSuccess) {
                            ResetPasswordView(phone: phone.normalizePhoneNumber, code: code)
                        }
                        .navigationDestination(isPresented: $viewModel._hasUnCompletedData) {
                            CompleteDataView(phone: phone.normalizePhoneNumber)
                        }
                        .navigationDestination(isPresented: $goToPasscodeSetupFromSheet) {
                            QuickPasscodeView(phone: phone, activeVM: viewModel)
                        }
                        
                        if showResendButton {
                            HStack {
                                Text("didn'tReceiveCode?".localized())
                                    .textModifier(.plain, 16, .black222222)
                                Button(action: {
                                    if isLoginOTP {
                                        viewModel.sendCode(for: ["phone": phone, "usage": "verify"])
                                    } else {
                                        viewModel.sendCode(for: ["phone":phone,"usage":isForgetPassword ?"forget_password":"verify"])
                                    }
                                    startTimer()
                                }) {
                                    Text("resendCode".localized())
                                        .textModifier(.plain, 16, Color(.primary))
                                }
                            }
                            .padding(.top, 24)
                        } else {
                            Text("resendIn".localized() + " " + formattedTime)
                                .textModifier(.plain, 16, .gray666666)
                                .padding(.top, 24)
                        }
                        
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar{
                ToolbarItemGroup(placement: .keyboard){
                    Button("Done".localized()){
                        hideKeyboard()
                    }
                    Spacer()
                }
            }

            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)
        .onChange(of: viewModel._isLoginOTPVerified) { _, success in
            if success && isLoginOTP {
                viewModel._isLoginOTPVerified = false
                if viewModel.isFirstLogin {
                    showSecuritySetupSheet = true
                } else {
                    viewModel.profile()
                }
            }
        }
        .customBottomSheet(
            isPresented: $showSecuritySetupSheet,
            detents: [.height(340)],
            isDismissOnBackgroundTap: false
        ) {
            SecuritySetupBottomSheet(
                phone: phone,
                activeVM: viewModel,
                isPresented: $showSecuritySetupSheet
            ) { passcodeSelected in
                if passcodeSelected {
                    goToPasscodeSetupFromSheet = true
                } else {
                    viewModel.profile()
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate(); timer = nil }
    }
    
    // MARK: - Timer
    private var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        showResendButton = false
        secondsRemaining = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer?.invalidate()
                timer = nil
                showResendButton = true
            }
        }
    }
}

#Preview {
    OTPConfirmationView()
}
struct PinInfo {
    var pin: String
    var focus: FocusPin
}

enum FocusPin {
    case pinOne, pinTwo, pinThree, pinFour
}

struct OtpModifier: ViewModifier {
    @Binding var pinInfo: PinInfo
    
    func body(content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .frame(width: 65, height: 65)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.grayE7E7E7)))
    }
}
