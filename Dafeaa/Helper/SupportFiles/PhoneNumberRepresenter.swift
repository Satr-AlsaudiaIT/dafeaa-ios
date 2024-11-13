//
//  PhoneNumberRepresenter.swift
//  Dafeaa
//
//  Created by AMNY on 06/10/2024.
//

import SwiftUI
import FlagPhoneNumber

struct CustomPasswordField: View {
    
    @Binding var password: String
    @State var isPasswordVisible: Bool = false
    var placeholder: String = "password"
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(.securitySafe)
                .foregroundColor(Color.yellow)
                .frame(width: 20, height: 20)
            
            // Password TextField with Eye Toggle
            if isPasswordVisible {
                TextField(placeholder.localized(), text: $password)
                    .textModifier(.plain, 15, .grayB5B5B5)
                    .focused($isFocused)
                    
            } else {
                SecureField(placeholder.localized(), text: $password)
                    .textModifier(.plain, 15, .grayB5B5B5)
                    .focused($isFocused)
            }
            
            // Eye Icon for showing/hiding password
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(isPasswordVisible ? .eyeSlash : .eye)
                    
            }
        }
        .frame(height: 48)
        .padding(.horizontal,20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true // Set focus when the field is tapped
        }
    }
}


struct PhoneNumberField: View {
    @Binding var phoneNumber: String
    @Binding var selectedCountryCode: String
    var placeholder: String = "phoneNumber"
    var image: UIImage
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            // Icon on the left
            Image(uiImage: image)
                .foregroundColor(Color.yellow)
                .frame(width: 20, height: 20)
            
            // Phone number text field
            TextField(placeholder.localized(), text: $phoneNumber)
                .textModifier(.plain, 15, .grayB5B5B5)
                .keyboardType(.numberPad)
                .focused($isFocused) // Track the focus state
            
            // Country code icon or additional UI on the right
            Image(.phoneCountryCode)
                .resizable()
                .frame(width: 91, height: 48)
        }
        .frame(height: 48)
        .padding(.leading, 20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true // Set focus when the field is tapped
        }
    }
}

struct CustomMainTextField: View {
    @Binding var text: String
    @State var placeHolder: String
    @State var image: ImageResource?
    @FocusState private var isFocused: Bool
    @State var keyBoardType: UIKeyboardType = .default
    @State var fieldType: FieldType = .none
    
    var body: some View {
        HStack {
            if let image = image {
                Image(image)
                    .foregroundColor(Color.yellow)
                    .frame(width: 20, height: 20)
            }
            ZStack {
                TextField(placeHolder.localized(), text: $text)
                    .textModifier(.plain, 15, .grayB5B5B5)
                    .focused($isFocused) // Track whether the text field is focused
                    .keyboardType(keyBoardType)
                    .onChange(of: text) { newValue,oldValue in
                        if fieldType == .arabicOnly || fieldType == .englishOnly {
                            validateInput(for: fieldType)
                        }
                    }
                
                if fieldType == .price || fieldType == .percentage {
                    HStack {
                        Spacer()
                        Text(fieldType == .price ? "rs".localized() : "%")
                            .padding(.trailing, 10)
                    }
                }
                
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true // Set the focus when the user taps on the text field
        }
    }
    private func validateInput(for fieldType: FieldType) {
            switch fieldType {
            case .arabicOnly:
                // Allow only Arabic characters
                text = text.filter { $0.isArabic }
            case .englishOnly:
                // Allow only English characters
                text = text.filter { $0.isEnglish }
            default:
                break
            }
        }
}
extension Character {
    var isArabic: Bool {
        return self >= "\u{0600}" && self <= "\u{06FF}"
    }
    
    var isEnglish: Bool {
        return self.isASCII && self.isLetter && (self.isLowercase || self.isUppercase)
    }
}
struct ButtonWithImageView: View {
    var imageName: ImageResource
    var trailingImageName: ImageResource?
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .frame(width: 20, height: 20)
                
                Text(text)
                    .textModifier(.plain, 14, .black292D32)
                Spacer()
                if let trailingImageName  {
                    Image(trailingImageName)
                    .frame(width: 16, height: 16)
                }
            }
            .frame(height: 56)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .background(Color(.grayF6F6F6))
            .cornerRadius(5)
        }
    }
}




//MARK: -Notuse
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
        textField.flagButton.isHidden = true
        // Force country code to be aligned on the left (LTR) even in RTL languages
               textField.semanticContentAttribute = .forceLeftToRight
               textField.flagButton.semanticContentAttribute = .forceLeftToRight
               
               // Align text (phone number) to the right in RTL (Arabic), but country code on the left
               textField.textAlignment = .right
        
        textField.flagButtonSize = CGSize(width: 0, height: 0)

        textField.displayMode = .list
//        textField.showCountryCodeInView = false
        return textField
    }

    func updateUIView(_ uiView: FPNTextField, context: Context) {
        uiView.text = selectedCountryCode.replacingOccurrences(of: "+966", with: "")

       }
}
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



enum FieldType{
    case price
    case percentage
    case none
    case arabicOnly
    case englishOnly
}
