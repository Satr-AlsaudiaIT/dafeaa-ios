//
//  MainAppTF.swift
//  Proffer
//
//  Created by M.Magdy on 15/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//
import SwiftUI

struct MainAppTF: View {
    @Binding var text: String
    @State var title: String
    @State var placeHolder: String
    @State var validationType: validateFieldType
    @State var submitLabel: SubmitLabel
    @State var keyboardType: UIKeyboardType
    @State var titleSize: CGFloat = 17
    @StateObject private var validateTF = ValidateTF()
    @State var height: CGFloat = 56
    @State var radius: CGFloat = 15
    @State var isPhone: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("\(title)")
                    .font(.custom(AppFonts.shared.name(AppFontsTypes.semiBold), size: titleSize))
                    .foregroundStyle(Color(.black222222))
                Spacer()
            }
            HStack {
                if isPhone {
                    Text("+20")
                        .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 14))
                }
                TextField("\(placeHolder)", text: $text)
                    .frame(height: height)
                    .focused($isFocused)
                    .autocorrectionDisabled(true)
                    .keyboardType(keyboardType)
            }
            .padding([.leading, .trailing])
            .background(Color(.textFieldBG))
            .cornerRadius(radius)
            .shadow(radius: 1)
            .textInputAutocapitalization(.never)
           
            .submitLabel(submitLabel)
            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 14))
            .onChange(of: text) { newValue in
                if isPhone {
                    text = text.convertDigitsToEng
                }
                validateTF.checkValidation(text: text, validationType: validationType)
            }
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(isFocused ? Color(.mainOrange) : Color.clear, lineWidth: 2)
            )

            HStack {
                Text("\(validateTF.errorMessage)")
                    .font(.custom(AppFonts.shared.name(AppFontsTypes.semiBold), size: 13))
                    .minimumScaleFactor(0.9)
                    .padding(.leading, 5)
                    .foregroundStyle(Color.red)
                Spacer()
            }
        }
        .padding([.leading, .trailing])
    }
}

#Preview {
    MainAppTF(text: .constant(""), title: "", placeHolder: "", validationType: .phone, submitLabel: .done, keyboardType: .default)
}
