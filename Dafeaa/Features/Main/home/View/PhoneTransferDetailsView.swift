//
//  PhoneTransferDetailsView.swift
//  Dafeaa
//
//  Created by AMNY on 20/01/2026.
//

import SwiftUI


struct PhoneTransferDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = HomeVM()
    
    @State var phoneNumber: String
    @State var contactName: String
    @State var amount: String = ""
    let isEditable: Bool
    @State var isAmountEditable: Bool = true
    
    @State private var selectedCountryCode: String = ""
    @State private var nameError: String = ""
    @State private var phoneError: String = ""
    @State private var amountError: String = ""
    @State private var hasAttemptedSubmit: Bool = false
    @FocusState private var focusedField: PhoneTransferField?
    @State var showPhoneDetails = false
    
    var isFormValid: Bool {
        let amountValue = Double(amount.convertDigitsToEng) ?? 0
        return amountValue > 0
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "Transfer Details".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Amount Input
                        VStack(spacing: 8) {
                            Text("Transfer Amount".localized())
                                .textModifier(.bold, 17, .black000000)
                            
                            VStack(alignment: .center, spacing: 8) {
                                HStack {
                                    Image(.riyal)
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.black)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                }
                                .padding(.horizontal)
                                .environment(\.layoutDirection, .rightToLeft)
                                
                                TextField("0.00", text: $amount)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .textModifier(.plain, 43, .black2B2D33)
                                    .frame(minHeight: 50)
                                    .disabled(!isAmountEditable)
                                    .focused($focusedField, equals: .amount)
                                    .onChange(of: amount) { _, newValue in
                                        validateAmountLive(newValue)
                                    }
                                
                                if !amountError.isEmpty {
                                    Text(amountError)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        // Contact Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("* " + "Account Holder Name".localized())
                                .textModifier(.plain, 14, .black1E1E1E)
                            
                            CustomMainTextField(
                                text: $contactName,
                                placeHolder: "Account Holder Name",
                                image: .nameTFIcon
                            )
                            .disabled(!isEditable)
                            .focused($focusedField, equals: .name)
                            .opacity(isEditable ? 1.0 : 0.6)
                           
                            
                            if !nameError.isEmpty {
                                Text(nameError)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.leading, 8)
                                    .padding(.top, 4)
                            }
                        }
                        
                        // Phone Number
                        VStack(alignment: .leading, spacing: 4) {
                            Text("* " + "Phone Number".localized())
                                .textModifier(.plain, 14, .black1E1E1E)
                            
                            if isEditable {
                                PhoneNumberField(
                                    phoneNumber: $phoneNumber,
                                    selectedCountryCode: $selectedCountryCode,
                                    image: .callCalling
                                )
                                .focused($focusedField, equals: .phone)
                              
                            } else {
                                CustomMainTextField(
                                    text: $phoneNumber,
                                    placeHolder: "Phone Number",
                                    image: .callCalling
                                )
                                .disabled(true)
                                .opacity(0.6)
                            }
                            
                            if !phoneError.isEmpty && isEditable {
                                Text(phoneError)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.leading, 8)
                                    .padding(.top, 4)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
                
                Spacer()
                
                // Transfer Button
                Button(action: {
                    hasAttemptedSubmit = true
                    validateAmountLive(amount)
                   
                    
                    if isFormValid {
                        viewModel.validateTransferAmount(phone: phoneNumber.normalizePhoneNumber, amount: amount)
                    }
                }) {
                    Text("Confirm Transfer".localized())
                        .textModifier(.plain, 15, .white)
                        .frame(maxWidth: .infinity, minHeight: 51)
                        .background(isFormValid ? Color(.black222222) : Color(.grayDADADA))
                        .cornerRadius(32)
                }
                .disabled(!isFormValid )
                .shadow(color: isFormValid ? Color(.dropShadow2B2D3333).opacity(0.2) : .clear, radius: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: $viewModel.transferToast)
        .navigationBarHidden(true)
        .onChange(of: viewModel.isUserFound) { _, newValue in
            if newValue {
                showPhoneDetails = true
            }
        }
        .navigationDestination(isPresented: $showPhoneDetails) {
            ConfirmTransferView(
                balance: String(format: "%.1f", Constants.availableAmount),
                phoneNumber: phoneNumber,
                amount: amount,
                name: viewModel.userNameOfPhone
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done".localized()) {
                    hideKeyboard()
                }
                Spacer()
                Button { showPreviousField() } label: {
                    Image(systemName: "chevron.up").foregroundColor(.blue)
                }
                Button { showNextField() } label: {
                    Image(systemName: "chevron.down").foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Validation Functions
    private func validateAmountLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            let amountValue = Double(value.convertDigitsToEng) ?? 0
            if value.isEmpty || amountValue <= 0 {
                amountError = "amount_validation".localized()
            } else {
                amountError = ""
            }
        }
    }
    
   
    
    // MARK: - Keyboard Navigation
    private func showNextField() {
        switch focusedField {
        case .amount: focusedField = .name
        case .name: focusedField = isEditable ? .phone : nil
        case .phone: focusedField = nil
        default: break
        }
    }
    
    private func showPreviousField() {
        switch focusedField {
        case .phone: focusedField = .name
        case .name: focusedField = .amount
        case .amount: focusedField = nil
        default: break
        }
    }
}

enum PhoneTransferField {
    case amount, name, phone
}

