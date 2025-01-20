//
//  ChangePasswordView.swift
//  Dafeaa
//
//  Created by AMNY on 19/10/2024.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var currentPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @StateObject var viewModel = MoreVM()
    @FocusState private var focusedField: FormField?
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "changePassword"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing: 0){
                        CustomPasswordField(password: $currentPassword, placeholder: "currentPassword")
                            .focused($focusedField, equals: .currentPassword)
                        
                        CustomPasswordField(password: $password, placeholder: "newPassword")
                            .padding(.top,12)
                            .focused($focusedField, equals: .password)
                        
                        CustomPasswordField(password: $confirmPassword, placeholder: "confirmNewPassword")
                            .padding(.top,8)
                            .focused($focusedField, equals: .confirmPassword)
                    }
                    
                }.padding(24)
                Spacer()
                ReusableButton(buttonText: "saveBtn"){
                    viewModel.validateChangePassword(currentPassword: currentPassword, password: password, confirmPassword: confirmPassword)
                }.padding(24)
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
        case .currentPassword:
            focusedField = .password
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
        case .password:
            focusedField = .currentPassword
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case currentPassword, password, confirmPassword
    }
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ChangePasswordView()
}
