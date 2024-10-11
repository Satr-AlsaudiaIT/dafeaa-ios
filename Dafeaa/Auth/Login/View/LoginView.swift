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

    var body: some View {
        NavigationStack {
            
            VStack {
                
                Image(.topImageLogin)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width)
                    .aspectRatio(contentMode: .fit)
                    
                
                VStack(spacing: 12) {
                    VStack(spacing: 5) {
                        Text("loginWelcome".localized())
                            .textModifier(.plain, 19, .blackTitles)
                            .frame(maxWidth:.infinity,alignment: .leading)
                        Text("loginWelcomeSubtitle".localized())
                            .textModifier(.plain, 15, .grayAAAAAA)
                            .frame(maxWidth:.infinity,alignment: .leading)
                    }
                    
                    // Phone Number Field
                    PhoneNumberField(
                                   phoneNumber: $phoneNumber,
                                   selectedCountryCode: $selectedCountryCode,
                                   placeholder: "Enter your phone number",
                                   image: .mobile
                               )
                    
                    CustomPasswordField(password: $password, isPasswordVisible: $isPasswordVisible)
                    
                    
                    ReusableButton(buttonText: "login".localized()) {
                                            
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
                
                HStack {
                    Text("haventAccount".localized())
                        .textModifier(.plain, 16, .blackTitles)
                    Button(action: {
                        isShowStep1 = true
                    }) {
                        Text("openAccount".localized())
                            .textModifier(.plain, 16, Color(.primary))
                    }
                }
                .padding(.bottom, 20)
            }
            .edgesIgnoringSafeArea(.top )
            .navigationDestination(isPresented: $isShowStep1)  {
                SignUpStep1View()
            }.navigationBarHidden(true)
            
        }
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
