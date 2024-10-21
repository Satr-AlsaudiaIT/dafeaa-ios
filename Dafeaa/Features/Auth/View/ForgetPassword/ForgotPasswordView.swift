//
//  ForgotPasswordView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var isSendSuccess: Bool = false
    @StateObject var viewModel = AuthVM()

    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "ForgotPasswordNavTitle"){
                    self.presentationMode.wrappedValue.dismiss()
                }

                            
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing: 0){
                        Image(.forgetPassword)
                            .resizable()
                            .frame(width: 144, height: 144)
                        Text("resetPasswordTitle".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.top,24)
                        Text("resetPasswordSubTitle".localized())
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .textModifier(.plain, 15, .gray666666)
                            .padding(.top,5)
                        PhoneNumberField(phoneNumber: $phoneNumber, selectedCountryCode: $selectedCountryCode, placeholder: "phoneNumber".localized(), image: .mobile)
                            .padding(.top,12)
                        
                        ReusableButton(buttonText: "send"){
                            viewModel.validateForgetPasswordPhone(phone:phoneNumber)
                        }.padding(.top,16)
                            .navigationDestination(isPresented: $isSendSuccess) {
                                OTPConfirmationView()
                            }
                        Spacer()
                        
                    }.padding(24)
                }
            }.navigationDestination(isPresented: $viewModel._isSendCodeSuccess) {
                OTPConfirmationView(phone: phoneNumber,isForgetPassword: true)
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

    }
}

#Preview {
    ForgotPasswordView()
}
