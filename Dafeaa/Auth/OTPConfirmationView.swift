//
//  OTPConfirmationView.swift
//  Dafeaa
//
//  Created by AMNY on 08/10/2024.
//

import SwiftUI

import SwiftUI

struct OTPConfirmationView: View {
    @State private var otpDigits: [String] = Array(repeating: "", count: 4) // Store the OTP digits in an array
    @FocusState private var focusedField: Int? // Keep track of which field is currently focused
    @State private var isConfirmed: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            NavigationBarView(title: "ConfirmPhoneNavTitle".localized()){
                self.presentationMode.wrappedValue.dismiss()
            }
            
            VStack(spacing: 0) {
                Image(.otp)
                    .resizable()
                    .frame(width: 144, height: 144)
                
                Text("confirmPhone".localized())
                    .textModifier(.plain, 19, .blackTitles)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                
                Text("confirmPhoneSubTitle".localized())
                    .textModifier(.plain, 15, .gray666666)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)

                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        TextField("", text: $otpDigits[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 70, height: 48)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.grayE7E7E7)))
                            .focused($focusedField, equals: index)
                            .onChange(of: otpDigits[index]) { newValue,old in
                                // Ensure the field has only one digit at a time
                                if newValue.count == 1 {
                                    otpDigits[index] = String(newValue.prefix(1))
                                }
                                
                                // Automatically move to the next field if a character is entered
                                if newValue.count == 1 && index < 3 {
                                    focusedField = index + 1
                                } else if newValue.isEmpty && index > 0 {
                                    // Move to the previous field if backspace is pressed
                                    focusedField = index - 1
                                }
                                print(otpDigits,otpDigits.joined()) 
                            }
                    }
                }
                .padding(.top, 12)
                
                ReusableButton(buttonText: "confirm".localized()) {
                    // Handle confirm action here
                    isConfirmed = true
                }
                .padding(.top, 16)
                .navigationDestination(isPresented: $isConfirmed) {
                    ResetPasswordView()
                }
                HStack {
                    Text("didn’tReceiveCode?".localized())
                        .textModifier(.plain, 16, .blackTitles)
                    Button(action: {
                        // Handle resend action here
                    }) {
                        Text("resendCode".localized())
                            .textModifier(.plain, 16, Color(.primary))
                    }
                }
                .padding(.top, 24)
                
                Spacer()
            }
            .padding(24)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    OTPConfirmationView()
}
