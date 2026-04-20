//
//  ReusableTextFields.swift
//  Dafeaa
//
//  Created by AMNY on 15/02/2026.
//


import SwiftUI

struct CustomPasswordField: View {
    @Binding var password: String
    var placeholder: String = "password"
    @State private var isPasswordVisible: Bool = false
    @State private var isFocused: Bool = false
    @Environment(\.layoutDirection) private var layoutDirection
    
    private var isRTL: Bool {
        layoutDirection == .rightToLeft
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Optional header if you want, similar to CustomMainTextField
            // Text(placeholder.localized())
            //     .textModifier(.plain, 14, .black)
            
            HStack {
                Image(.securitySafe)
                    .resizable()
                    .foregroundColor(Color.yellow)
                    .frame(width: 20, height: 20)
                
                ZStack(alignment: isRTL ? .trailing : .leading) {
                    HStack {
                        AdvancedTextField(
                            text: $password,
                            placeholder: placeholder.localized(),
                            isRTL: isRTL,
                            keyboardType: .default,
                            fieldType: .none,
                            isSecure: !isPasswordVisible,
                            onFocusChange: { focused in
                                isFocused = focused
                            }
                        )
                        .frame(maxWidth: .infinity)
                        Spacer()
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(isPasswordVisible ? .eyeSlash : .eye)
                        }
                    }
                    .allowsHitTesting(true)
                    
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
        }
    }
}


struct AdvancedTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isRTL: Bool
    let keyboardType: UIKeyboardType
    let fieldType: FieldType
    var maxLength: Int? = nil
    var isSecure: Bool = false
    var onFocusChange: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.textAlignment = isRTL ? .right : .left
        field.keyboardType = keyboardType
        field.font = .systemFont(ofSize: 15)
        field.textColor = UIColor(resource: .black222222)
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(resource: .grayB5B5B5)]
        )
        field.delegate = context.coordinator
        field.backgroundColor = .clear
        field.isSecureTextEntry = isSecure    // secure/plain [web:19][web:21]
        
        field.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textFieldDidChange),
            for: .editingChanged
        )
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
         field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return field
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text && !uiView.isFirstResponder {
            uiView.text = text
        }
        uiView.textAlignment = isRTL ? .right : .left
        if uiView.isSecureTextEntry != isSecure {
               uiView.isSecureTextEntry = isSecure
               let currentText = uiView.text
               uiView.text = ""
               uiView.text = currentText
           }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AdvancedTextField
        
        init(_ parent: AdvancedTextField) {
            self.parent = parent
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            var newText = textField.text ?? ""
            
            switch parent.fieldType {
            case .arabicOnly:
                newText = String(newText.filter { $0.isArabic })
            case .englishOnly:
                newText = String(newText.filter { $0.isEnglish })
            default:
                break
            }
            
            if let max = parent.maxLength, newText.count > max {
                   newText = String(newText.prefix(max))
               }
            
            if newText != textField.text {
                textField.text = newText
            }
            
            parent.text = newText
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFocusChange?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFocusChange?(false)
        }
    }
}

struct CustomMainTextField: View {
    @Binding var text: String
    @State var placeHolder: String
    @State var image: ImageResource?
    @State private var isFocused: Bool = false
    @State var keyBoardType: UIKeyboardType = .default
    @State var fieldType: FieldType = .none
    @State var showHeader: Bool = false
    var maxLength: Int? = nil
    @Environment(\.layoutDirection) private var layoutDirection
    
    private var isRTL: Bool {
        layoutDirection == .rightToLeft
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showHeader == true {
                Text(placeHolder.localized())
                    .textModifier(.plain, 14, .black)
            }
            
            HStack {
                if let image = image {
                    Image(image)
                        .resizable()
                        .foregroundColor(Color.yellow)
                        .frame(width: 20, height: 20)
                }
                
                ZStack(alignment: isRTL ? .trailing : .leading) {
                    AdvancedTextField(
                        text: $text,
                        placeholder: placeHolder.localized(),
                        isRTL: isRTL,
                        keyboardType: keyBoardType,
                        fieldType: fieldType,
                        maxLength: maxLength,
                        onFocusChange: { focused in
                            isFocused = focused
                        }
                    )
                    
                    HStack {

                        Spacer()
                        Group {
                            switch fieldType {
                            case .price:
                                Image(.riyal)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray8B8C86)
                                    .frame(width: 15)
                            case .percentage:
                                Text("%")
                                    .textModifier(.plain, 13, .gray616161)
                            case .optional:
                                Text("optional".localized())
                                    .textModifier(.plain, 13, .gray616161)
                            case .dimensional:
                                Text("cm".localized())
                                    .textModifier(.plain, 13, .gray616161)
                            case .weight:
                                Text("kg".localized())
                                    .textModifier(.plain, 13, .gray616161)
                            case .daysNumber:
                                Text("days".localized())
                                    .textModifier(.plain, 13, .gray616161)
                            default:
                                EmptyView()
                            }
                        }
                        
                       
                    }
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 48)
            .padding(.horizontal, 20)
            .background(Color(.grayF6F6F6))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct MaskedTextField: View {
    @Binding var text: String
    let placeHolder: String
    let maxLength: Int

    @State private var isFocused: Bool = false
    @Environment(\.layoutDirection) private var layoutDirection

    private var isRTL: Bool {
        layoutDirection == .rightToLeft
    }
    
    var body: some View {
        AdvancedTextField(
            text: $text,
            placeholder: placeHolder,
            isRTL: isRTL,
            keyboardType: .numberPad,
            fieldType: .none,
            isSecure: true,
            onFocusChange: { focused in
                isFocused = focused
            }
        )
        .frame(maxWidth: .infinity)
        .onChange(of: text) { _, newValue in
            let filtered = newValue.filter { $0.isNumber }
            let clamped = filtered.count > maxLength
                ? String(filtered.prefix(maxLength))
                : filtered
            if clamped != text { text = clamped }
        }
        .frame(height: 48)
        .padding(.horizontal, 20)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
    }
}


struct PhoneNumberField: View {
    @Binding var phoneNumber: String
    @Binding var selectedCountryCode: String
    var placeholder: String = "phoneNumber"
    var image: UIImage
    @FocusState private var isFocused: Bool
    @Environment(\.layoutDirection) private var layoutDirection
    
    private var isRTL: Bool {
        layoutDirection == .rightToLeft
    }

    var body: some View {
        HStack(spacing: 12) {
            if isRTL {
                Image(uiImage: image)
                    .foregroundColor(Color.yellow)
                    .frame(width: 20, height: 20)
            } else {
                Image(.phoneCountryCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 91, height: 48)
            }
            
            SimpleTextField(text: $phoneNumber,
                          placeholder: placeholder.localized(),
                          isRTL: isRTL,
                          isFocused: _isFocused)
            .frame(maxWidth: .infinity)
            if isRTL {
                Image(.phoneCountryCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 91, height: 48)
            } else {
                Image(uiImage: image)
                    .foregroundColor(Color.yellow)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(isRTL ? .leading:.trailing, 20)
        .frame(height: 48)
        .background(Color(.grayF6F6F6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

struct SimpleTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isRTL: Bool
    @FocusState var isFocused: Bool
    
    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.textAlignment = isRTL ? .right : .left
        field.keyboardType = .numberPad
        field.font = .systemFont(ofSize: 15)
        field.textColor = UIColor(resource: .black222222)
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(resource:.grayB5B5B5) ]
        )
        field.delegate = context.coordinator
        field.backgroundColor = .clear
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return field
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textAlignment = isRTL ? .right : .left
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SimpleTextField
        
        init(_ parent: SimpleTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            textField.textAlignment = parent.isRTL ? .right : .left
        }
    }
}

enum FieldType{
    case price
    case percentage
    case none
    case arabicOnly
    case englishOnly
    case optional
    case dimensional
    case daysNumber
    case weight
}
