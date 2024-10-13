//
//  ResetPasswordView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var phone: String = ""
    var code: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "resetPasswordNavTitle".localized()){
                    self.presentationMode.wrappedValue.dismiss()
                }
                ScrollView(.vertical,showsIndicators: false){
                    
                    VStack(spacing: 0){
                        Image(.resetPassword)
                            .resizable()
                            .frame(width: 144, height: 144)
                        Text("resetPassword".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.top,24)
                        
                        Text("resetPasswordSubTitle".localized())
                            .textModifier(.plain, 15, .gray666666)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.top,5)
                        
                        CustomPasswordField(password: $password, isPasswordVisible: $isPasswordVisible)
                            .padding(.top,12)
                            .focused($focusedField, equals: .password)
                        
                        CustomPasswordField(password: $confirmPassword, isPasswordVisible: $isConfirmPasswordVisible)
                            .padding(.top,8)
                            .focused($focusedField, equals: .confirmPassword)
                        
                        ReusableButton(buttonText: "saveBtn".localized()){
                            viewModel.validateForgetPassword(phone: phone, code: code, password: password, confirmPassword: confirmPassword)
                            
                        } .padding(.top,16)
                        
                        Spacer()
                    }.padding(24)
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
        }.navigationBarHidden(true)
            .toastView(toast: $viewModel.toast)
    }
    
    func showNextTextField(){
        switch focusedField {
        case .password:
            focusedField = .confirmPassword
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .confirmPassword:
            focusedField = .password
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case password,confirmPassword
    }
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ResetPasswordView()
}
