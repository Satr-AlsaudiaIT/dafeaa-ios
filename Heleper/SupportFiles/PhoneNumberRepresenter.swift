//
//  PhoneNumberRepresenter.swift
//  Dafeaa
//
//  Created by AMNY on 06/10/2024.
//

import SwiftUI

struct CustomPhoneNumberField: View {
    
    @Binding var phoneNumber: String
    
    var body: some View {
        HStack {
            // Yellow Phone Icon
            Image(systemName: "phone.fill")
                .foregroundColor(Color.yellow)
                .frame(width: 24, height: 24)
                .padding(.leading, 10)
            
            // Country Code + Flag Image
            HStack {
                Image("saudiFlag") // Replace with your image asset name for the flag
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("+966")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
            }
            .padding(.horizontal, 10)
            .frame(width: 100, height: 44)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Phone Number TextField
            TextField("phoneNumber", text: $phoneNumber)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

// Custom Password Field with Yellow Icon
struct CustomPasswordField: View {
    
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        HStack {
            Image(.securitySafe)
                .foregroundColor(Color.yellow)
                .frame(width: 20, height: 20)
            
            // Password TextField with Eye Toggle
            if isPasswordVisible {
                TextField("password", text: $password)
                    .textModifier(.plain, 15, .grayB5B5B5)
                    
            } else {
                SecureField("password", text: $password)
                    .textModifier(.plain, 15, .grayB5B5B5)

            }
            
            // Eye Icon for showing/hiding password
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(isPasswordVisible ? .eyeSlash : .eyeSlash)
                    
            }
        }
        .frame(height: 48)
        .padding(.horizontal,20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
    }
}


// Custom Password Field with Yellow Icon
import SwiftUI
import FlagPhoneNumber

struct PhoneNumberField: View {
    
    @Binding var phoneNumber: String
    @Binding var selectedCountryCode: String
    var placeholder: String
    var image: UIImage
    
    var body: some View {
        HStack {
            // Icon on the left
            Image(uiImage: image)
                .foregroundColor(Color.yellow)
                .frame(width: 20, height: 20)
            // FlagPhoneNumberView wrapped as part of the reusable component
            FlagPhoneNumberView(phoneNumber: $phoneNumber, selectedCountryCode: $selectedCountryCode)
                
        }
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
//        .shadow(radius: 1)
    }
}


struct FlagPhoneNumberView: UIViewRepresentable {
    @Binding var phoneNumber: String
    @Binding var selectedCountryCode: String

    class Coordinator: NSObject, FPNTextFieldDelegate {
        var parent: FlagPhoneNumberView

        init(_ parent: FlagPhoneNumberView) {
            self.parent = parent
        }

        func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
            // Handle country selection
            parent.selectedCountryCode = dialCode
        }

        func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
            if isValid {
                parent.phoneNumber = textField.getFormattedPhoneNumber(format: .E164) ?? ""
            } else {
                parent.phoneNumber = textField.text ?? ""
            }
        }

        func fpnDisplayCountryList() {
            // Open the country list (if needed)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> FPNTextField {
        let textField = FPNTextField()
        textField.displayMode = .list
        textField.delegate = context.coordinator
        textField.setFlag(key: .SA) // Set default country flag, e.g., Saudi Arabia
        textField.keyboardType = .phonePad
        textField.backgroundColor = .clear
        textField.borderStyle = .none

        // Force country code to be aligned on the left (LTR) even in RTL languages
               textField.semanticContentAttribute = .forceLeftToRight
               textField.flagButton.semanticContentAttribute = .forceLeftToRight
               
               // Align text (phone number) to the right in RTL (Arabic), but country code on the left
               textField.textAlignment = .right
        
        
        return textField
    }

    func updateUIView(_ uiView: FPNTextField, context: Context) {
        // Update UI when state changes
        uiView.text = phoneNumber
    }
}

struct CustomMainTextField: View {
    
    @Binding var text: String
    @State var placeHolder: String
    @State var image : ImageResource
    var body: some View {
        HStack {
            Image(image)
                .foregroundColor(Color.yellow)
                .frame(width: 20, height: 20)
            
            
                TextField(placeHolder, text: $text)
                    .textModifier(.plain, 15, .grayB5B5B5)
              
        }
        .frame(height: 48)
        .padding(.horizontal,20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
    }
}
