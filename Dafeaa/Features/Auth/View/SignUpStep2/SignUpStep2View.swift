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
    @State private var email:String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAgreeChecked: Bool = false
    @State private var selectedProfileImage: UIImage?
    @State private var selectedProfileImageURL: String? = ""
    var selectedOption: AccountTypeOption = .none
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
           ZStack{
               VStack(alignment: .leading, spacing: 16) {
                   HStack {
                       Button(action: {
                           withAnimation(.easeInOut(duration: 0.3)) {
                               self.presentationMode.wrappedValue.dismiss()
                           }
                       }) {
                           Image(.arrowRight)
                               .resizable()
                               .frame(width: 32, height: 32)
                               .foregroundColor(.black222222)
                       }
                       Spacer()
                   }
                   
                   HStack {
                       RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.primary))
                       RoundedRectangle(cornerRadius: 2).foregroundColor(Color(.primary))
                   }
                   .frame(maxWidth: .infinity)
                   .frame(height: 3)
                   
                   VStack(alignment:.leading,spacing:8) {
                       Text("addSomeData".localized())
                           .textModifier(.plain, 19, .black222222)
                       
                       // Subtitle
                       Text("selectAccountTypeSubtitle".localized())
                           .textModifier(.plain, 15, .gray666666)
                   }
                   
                   ScrollViewReader { proxy in
                       ScrollView {
                           VStack(alignment: .leading, spacing: 8) {
                               HStack {
                                   Spacer()
                                   ProfileImageView(selectedImage: $selectedProfileImage, imageURL: $selectedProfileImageURL, isShowFromEdit: false)
                                   Spacer()
                               }
                               .padding(.bottom,15)
                               CustomMainTextField(text: $name, placeHolder: "Name", image: .nameTFIcon)
                                   .focused($focusedField, equals: .userName)
                                   .id(FormField.userName)
                               
                               PhoneNumberField(
                                   phoneNumber: $phoneNumber,
                                   selectedCountryCode: $selectedCountryCode,
                                   image: .mobile
                               )
                               .focused($focusedField, equals: .phone)
                               .id(FormField.phone)
                               
                               Text("PhoneIsTheMainActor".localized())
                                   .textModifier(.plain, 12, .errorRed)
                               
                               CustomMainTextField(text: $email, placeHolder: "Email", image: .mailTFIcon,keyBoardType: .emailAddress)
                                   .focused($focusedField, equals: .email)
                                   .id(FormField.email)
                               
                               CustomPasswordField(password: $password)
                                   .focused($focusedField, equals: .password)
                                   .id(FormField.password)
                               
                               CustomPasswordField(password: $confirmPassword,placeholder: "confirmPasswordPlaceholder".localized())
                                   .focused($focusedField, equals: .confirmPassword)
                                   .id(FormField.confirmPassword)
                               
                               Spacer()
                               TermsAndConditionsView(isAgreeChecked: $isAgreeChecked)
                           }
                           
                           Spacer()
                           
                           ReusableButton(buttonText: "createAccount", isEnabled: true) {
                               viewModel.validateRegister(photo: selectedProfileImage, name: name, email: email, phone: phoneNumber, accountType: selectedOption, password: password, confirmPassword: confirmPassword, isAgreeChecked: isAgreeChecked)
                           }
                           .navigationDestination(isPresented: $viewModel._isSignUpSuccess) {
                               OTPConfirmationView(phone: phoneNumber, isForgetPassword: false)
                           }
                           
                           HStack {
                               Spacer()
                               Text("haveAccount?".localized())
                                   .textModifier(.plain, 16, .black222222)
                               Button(action: {
                                   NavigationUtil.popToRootView()
                               }) {
                                   Text("login".localized())
                                       .textModifier(.plain, 16, Color(.primary))
                               }
                               Spacer()
                           }
                           .padding(.top, 24)
                           .padding(.bottom, 30)
                       }
                       .scrollIndicators(.hidden)
                       .onChange(of: focusedField) { oldField,newField in
                           withAnimation {
                               if let newField = newField {
                                   proxy.scrollTo(newField, anchor: .center)
                               }
                           }
                       }
                   }
                   .padding(.bottom, keyboardHeight) // Adjust the scroll view padding based on the keyboard height
               }
               .padding([.leading,.trailing,.top],24)
               .onAppear { subscribeToKeyboardEvents(keyboardHeight: keyboardHeight) }
               .onDisappear { unsubscribeFromKeyboardEvents() }
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
               if viewModel.isLoading {
                   ProgressView("Loading...".localized())
                       .foregroundColor(.white)
                       .progressViewStyle(WithBackgroundProgressViewStyle())
               } else if viewModel.isFailed {
                   ProgressView().hidden()
               }
           }
           .navigationBarHidden(true)
           .toastView(toast: $viewModel.toast)
       }
    func showNextTextField(){
        switch focusedField {
        case .userName:
            focusedField = .phone
        case .phone:
            focusedField = .email
        case .email:
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
            focusedField = .email
        case .email:
            focusedField = .phone
        case .phone:
            focusedField = .userName
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case userName, email, phone, password, confirmPassword
    }
   
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//
//#Preview {
//    SignUpStep2View()
//}


import SwiftUI

struct TermsAndConditionsView: View {
//    @Binding var isFirstLineChecked: Bool
    @Binding var isAgreeChecked: Bool

    @State private var showTermsAndConditions: Bool = false // To handle navigation
    
    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
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
                        .textModifier(.plain, 14, Color(.primary))
                        .onTapGesture {
                            showTermsAndConditions = true // Handle navigation on click
                        }
                    
                }
                .padding(.horizontal)
                
                
            }
            .navigationDestination(isPresented: $showTermsAndConditions) {
                StaticPagesView(type: .constant(.termsAndCondition))
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


