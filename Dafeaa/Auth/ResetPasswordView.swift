//
//  ResetPasswordView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            NavigationBarView(title: "resetPasswordNavTitle".localized()){
                self.presentationMode.wrappedValue.dismiss()
            }
            
            VStack(spacing: 0){
                Image(.resetPassword)
                    .resizable()
                    .frame(width: 144, height: 144)
                Text("resetPassword".localized())
                    .textModifier(.plain, 19, .blackTitles)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.top,24)
                
            
            
            Text("resetPasswordSubTitle".localized())
                    .textModifier(.plain, 15, .gray666666)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.top,5)
            
                CustomPasswordField(password: $password, isPasswordVisible: $isPasswordVisible)
                    .padding(.top,12)
                CustomPasswordField(password: $confirmPassword, isPasswordVisible: $isConfirmPasswordVisible)
                    .padding(.top,8)

            ReusableButton(buttonText: "saveBtn".localized()){
                
            } .padding(.top,16)
                
                Spacer()
            }.padding(24)
        }.navigationBarHidden(true)
        
    }
}

#Preview {
    ResetPasswordView()
}
