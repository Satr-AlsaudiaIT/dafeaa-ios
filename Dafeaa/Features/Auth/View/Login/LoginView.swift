//
//  LoginView.swift
//  Dafeaa
//
//  Created by M.Magdy on 06/10/2024.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isShowStep1 : Bool = false
    @State private var selectedCountryCode: String = ""
    @State private var showForgetPassword : Bool = false
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?
    var body: some View {
        NavigationStack {
            
            ZStack{
                VStack {
                    
                    Image(.topImageLogin)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width)
                        .aspectRatio(contentMode: .fit)
                    
                    
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(spacing: 12) {
                            VStack(spacing: 5) {
                                Text("loginWelcome".localized())
                                    .textModifier(.plain, 19, .black222222)
                                    .frame(maxWidth:.infinity,alignment: .leading)
                                Text("loginWelcomeSubtitle".localized())
                                    .textModifier(.plain, 15, .grayAAAAAA)
                                    .frame(maxWidth:.infinity,alignment: .leading)
                            }
                            
                            // Phone Number Field
                            PhoneNumberField(
                                phoneNumber: $phoneNumber,
                                selectedCountryCode: $selectedCountryCode,
                                image: .mobile)
                            .focused($focusedField, equals: .phone)
                            CustomPasswordField(password: $password, isPasswordVisible: $isPasswordVisible)
                                .focused($focusedField, equals: .password)
                            
                            ReusableButton(buttonText: "login".localized()) {
                                viewModel.validateLogin(phone: phoneNumber, password: password)
                            } .padding(.top, 4)
                            
                            Button(action: {
                                // Handle forgot password action
                                showForgetPassword = true
                            }) {
                                Text("forgetPassword".localized())
                                    .textModifier(.plain, 15, .gray)
                                    .frame(maxWidth:.infinity,alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 15)
                        
                        .navigationDestination(isPresented: $showForgetPassword) {
                            ForgotPasswordView()
                        }
                        Spacer()
                    }
                        HStack {
                            Text("haventAccount".localized())
                                .textModifier(.plain, 16, .black222222)
                            Button(action: {
                                isShowStep1 = true
                            }) {
                                Text("openAccount".localized())
                                    .textModifier(.plain, 16, Color(.primary))
                            }
                        }
                        .padding(.bottom, 20)
                    
                }
                .navigationDestination(isPresented: $viewModel._isSendCodeSuccess) {
                    OTPConfirmationView(phone: phoneNumber)
                }
                .navigationDestination(isPresented: $viewModel._hasUnCompletedData) {
                    
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
            .edgesIgnoringSafeArea(.top )
            .navigationDestination(isPresented: $isShowStep1)  {
                SignUpStep1View()
            }.navigationBarHidden(true)
                .toastView(toast: $viewModel.toast)
        }
    }
    
    func showNextTextField(){
        switch focusedField {
        case .phone:
            focusedField = .password
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .password:
            focusedField = .phone
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case phone,password
    }
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
}
//iPhoneNumberField("(000) 000-0000", text: $text, isEditing: $isEditing)
//           .flagHidden(false)
//           .flagSelectable(true)
//           .font(UIFont(size: 30, weight: .light, design: .monospaced))
//           .maximumDigits(10)
//           .foregroundColor(Color.pink)
//           .clearButtonMode(.whileEditing)
//           .onClear { _ in isEditing.toggle() }
//           .accentColor(Color.orange)
//           .padding()
//           .background(Color.white)
//           .cornerRadius(10)
//           .shadow(color: isEditing ? .lightGray : .white, radius: 10)
//           .padding()
