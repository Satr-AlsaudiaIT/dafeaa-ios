//
//  ForgotPasswordView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var isSendSuccess: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    var body: some View {
        VStack {
            NavigationBarView(title: "ForgotPasswordNavTitle".localized()){
                self.presentationMode.wrappedValue.dismiss()
            }

                        
            VStack(spacing: 0){
                Image(.forgetPassword)
                    .resizable()
                    .frame(width: 144, height: 144)
                Text("resetPasswordTitle".localized())
                    .textModifier(.plain, 19, .blackTitles)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.top,24)
                Text("resetPasswordSubTitle".localized())
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .textModifier(.plain, 15, .gray666666)
                    .padding(.top,5)
                PhoneNumberField(phoneNumber: $phoneNumber, selectedCountryCode: $selectedCountryCode, placeholder: "phoneNumber".localized(), image: .mobile)
                    .padding(.top,12)
                
                ReusableButton(buttonText: "send".localized()){
                    isSendSuccess = true
                }.padding(.top,16)
                    .navigationDestination(isPresented: $isSendSuccess) {
                        OTPConfirmationView()
                    }
                Spacer()
                
            }.padding(24)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ForgotPasswordView()
}
