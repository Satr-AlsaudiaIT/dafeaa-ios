//
//  SignUpStep2View.swift
//  Dafeaa
//
//  Created by M.Magdy on 07/10/2024.
//


import SwiftUI

struct SignUpStep2View: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var name : String =  ""
    @State private var mail:String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var confirmPassword: String = ""
    @State private var isconfirmPasswordVisible: Bool = false
    @State private var isFirstAgreeChecked: Bool = false
    @State private var isSecondAgreeChecked: Bool = false

    var body: some View {
        VStack(alignment: .leading , spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                    self.presentationMode.wrappedValue.dismiss()

                  }
                }) {
                    Image(.arrowLeft)
                        .resizable()
                        .frame(width: 32,height: 32)
                        .foregroundColor(.blackTitles)
                }
                Spacer()
                
            }
            
            HStack{
                RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.primary))
                RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.primary))
            }.frame(maxWidth: .infinity)
                .frame(height: 3)
            VStack(alignment:.leading,spacing:8){
                Text("addSomeData".localized())
                    .textModifier(.plain, 19, .blackTitles)

                // Subtitle
                Text("selectAccountTypeSubtitle".localized())
                    .textModifier(.plain, 15, .gray666666)
                
            }
            ScrollView {
                VStack(alignment:.leading, spacing: 8) {
                    CustomMainTextField(text: $name, placeHolder: "Name".localized(), image: .nameTFIcon)
                    PhoneNumberField(
                        phoneNumber: $phoneNumber,
                        selectedCountryCode: $selectedCountryCode,
                        placeholder: "Enter your phone number",
                        image: .mobile
                    )
                    Text("PhoneIsTheMainActor".localized())
                        .textModifier(.plain, 12, .errorRed)
                    CustomMainTextField(text: $mail, placeHolder: "Email".localized(), image: .mailTFIcon)
                    CustomPasswordField(password: $password, isPasswordVisible: $isPasswordVisible)
                    CustomPasswordField(password: $confirmPassword, isPasswordVisible: $isconfirmPasswordVisible)
                    Spacer()
                    TermsAndConditionsView(isFirstLineChecked: $isFirstAgreeChecked, isAgreeChecked: $isSecondAgreeChecked)
                }
                
                Spacer()
                
            
            }
            
            ReusableButton(buttonText: "createAccount".localized(), isEnabled: true) {
            }
            HStack {
                Text("haveAccount?".localized())
                    .textModifier(.plain, 16, .blackTitles)
                Button(action: {
                    // Handle resend action here
                }) {
                    Text("login".localized())
                        .textModifier(.plain, 16, Color(.primary))
                }
            }
            .padding(.top, 24)
            .padding(.bottom,30)
        }
        .padding(24)
        .navigationBarHidden(true)
    }
}


#Preview {
    SignUpStep2View()
}


import SwiftUI

struct TermsAndConditionsView: View {
    @Binding var isFirstLineChecked: Bool
    @Binding var isAgreeChecked: Bool

    @State private var showTermsAndConditions: Bool = false // To handle navigation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Checkbox
                Button(action: {
                    isFirstLineChecked.toggle()
                }) {
                    Image(systemName: isFirstLineChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(isFirstLineChecked ? Color(.primary) : .gray)
                        .font(.system(size: 24))
                }
                
                // Text with attributed clickable parts
                Text(firstAttributedString())
                    .font(.system(size: 14))
                    .onTapGesture {
                        showTermsAndConditions = true // Handle navigation on click
                    }
               
            }
            .padding(.horizontal)
            HStack(alignment: .top, spacing: 10) {
                // Checkbox
                Button(action: {
                    isAgreeChecked.toggle()
                }) {
                    Image(systemName: isAgreeChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(isAgreeChecked ? Color(.primary) : .gray)
                        .font(.system(size: 24))
                }
                
                // Text with attributed clickable parts
                Text(secondAttributedString())
                    .font(.system(size: 14))
                    .onTapGesture {
                        showTermsAndConditions = true // Handle navigation on click
                    }
               
            }
            .padding(.horizontal)
            
            
        }
        .sheet(isPresented: $showTermsAndConditions) {
            // This is a placeholder for the terms and conditions view
            TermsAndConditionsDetailView()
        }
    }
    
    // Function to create an AttributedString with clickable terms
    private func firstAttributedString() -> AttributedString {
        var attributedString = AttributedString("AgreeToTermsAndConditionsCheckText".localized())
        attributedString.foregroundColor = .gray666666
        // Adding the clickable part "شروط الاستخدام"
        var clickableText = AttributedString("Terms&Conditions".localized())
        clickableText.foregroundColor = Color(.primary)
        clickableText.underlineStyle = .single
        
        // Append the clickable text to the original text
        attributedString.append(clickableText)
        
        return attributedString
    }
    private func secondAttributedString() ->   AttributedString {
        var attributedString = AttributedString("AgreeTo".localized())
        attributedString.foregroundColor = .gray666666
        // Adding the clickable part "شروط الاستخدام"
        var clickableText = AttributedString("Terms&Conditions".localized())
        clickableText.foregroundColor = Color(.primary)
        clickableText.underlineStyle = .single
        
        // Append the clickable text to the original text
        attributedString.append(clickableText)
        
        return attributedString
    }
}

// A placeholder view for the terms and conditions detail view
struct TermsAndConditionsDetailView: View {
    var body: some View {
        VStack {
            Text("Terms and Conditions Details")
                .font(.title)
                .padding()
            
            Button("Close") {
                // Code to close the sheet
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//#Preview {
//    TermsAndConditionsView()
//}
