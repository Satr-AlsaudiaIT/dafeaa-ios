//
//  ChangePhoneView.swift
//  Dafeaa
//
//  Created by AMNY on 20/10/2024.
//

import SwiftUI

struct ChangePhoneView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var isSendSuccess: Bool = false
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?

    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "ChangePhoneNavTitle"){NavigationUtil.popToRootView() }
                            
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing: 0){
                        Image(.forgetPassword)
                            .resizable()
                            .frame(width: 144, height: 144)
                        Text("changePhoneTitle".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.top,24)
                        Text("changePhoneSubTitle".localized())
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .textModifier(.plain, 15, .gray666666)
                            .padding(.top,5)
                        PhoneNumberField(phoneNumber: $phoneNumber, selectedCountryCode: $selectedCountryCode, placeholder: "phoneNumber".localized(), image: .mobile)
                            .padding(.top,12)
                        CustomPasswordField(password: $password)
                            .focused($focusedField, equals: .password)
                            .padding(.top,8)
                        ReusableButton(buttonText: "send"){
                            viewModel.validateChangePhone(password: password, phone: phoneNumber)
                        }.padding(.top,16)
                            .navigationDestination(isPresented: $viewModel._isSendCodeSuccess) {
                                OTPConfirmationView(phone:phoneNumber)
                            }
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
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard){
                Button("Done".localized()){
                    hideKeyboard()
                }
                Spacer()
                Button(action: {
                       showPerviousTextField()
                }, label: {
                    Image(systemName: "chevron.up").foregroundColor(.blue)
                })
                
                Button(action: {
                    showNextTextField()
                }, label: {
                    Image(systemName: "chevron.down").foregroundColor(.blue)
                })
            }
        }

    }
    
    func showNextTextField(){
        switch focusedField {
        case .phone:     focusedField = .password
        default:         focusedField = nil  }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .password:  focusedField = .phone
        default:         focusedField = nil  }
    }
    
    enum FormField {
        case phone, password
    }
   
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ForgotPasswordView()
}
