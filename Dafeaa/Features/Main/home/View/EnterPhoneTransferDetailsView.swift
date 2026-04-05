//
//  EnterPhoneTransferDetailsView.swift
//  Dafeaa
//
//  Created by AMNY on 21/01/2026.
//

import SwiftUI
import Contacts

struct EnterPhoneTransferDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = HomeVM()
    
    @State var phoneNumber: String
    @State var showPhoneDetails: Bool = false
    
    @State private var amount: String = ""
    @State private var selectedCountryCode: String = ""
    @State private var phoneError: String = ""
    @State private var amountError: String = ""
    @State private var hasAttemptedSubmit: Bool = false
    @FocusState private var focusedField: TransferField?
    
    // Contact picker
    @State private var showContactPicker: Bool = false
    @State private var selectedContactName: String = ""
    @State private var hasSelectedContact: Bool = false
    
    var isFormValid: Bool {
        let amountValue = Double(amount.convertDigitsToEng) ?? 0
        return amountValue > 0 &&
               !phoneNumber.isEmpty &&
               phoneNumber.isValidPhone() &&
               phoneError.isEmpty
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
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .textModifier(.plain, 43, .black2B2D33)
                                    .frame(minHeight: 50)
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
                        
                        // Phone Number Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("* " + "Phone Number".localized())
                                    .textModifier(.plain, 14, .black1E1E1E)
                                
                                Spacer()
                                
                               
                            }
                            
                            // Show Contact Card or Phone Field
                            if hasSelectedContact {
                                selectedContactCard
                            } else {
                                phoneInputField
                            }
                            
                            if !phoneError.isEmpty {
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
                    validatePhoneLive(phoneNumber)
                    
                    if isFormValid {
                        viewModel.validateTransferAmount(phone: phoneNumber.normalizePhoneNumber, amount: amount)
                    }
                }) {
                    Text("Transfer".localized())
                        .textModifier(.plain, 15, .white)
                        .frame(maxWidth: .infinity, minHeight: 51)
                        .background(isFormValid ? Color(.black222222) : Color(.grayDADADA))
                        .cornerRadius(32)
                }
                .disabled(!isFormValid)
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
        .navigationDestination(isPresented: $showPhoneDetails) {

            ConfirmTransferView(
                balance: String(format: "%.1f", Constants.availableAmount),
                phoneNumber: phoneNumber.normalizePhoneNumber,
                amount: amount,
                name: selectedContactName.isEmpty ? viewModel.userNameOfPhone : selectedContactName
            )
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerBottomSheet(selectedPhone: $phoneNumber, selectedName: $selectedContactName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showContactPicker) { _, isShowing in
            if !isShowing && !phoneNumber.isEmpty {
                phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
                
                if !selectedContactName.isEmpty {
                    hasSelectedContact = true
                }
            }
        }
        .onAppear {
            amount = ""
        }
        .onChange(of: viewModel.isUserFound) { _, newValue in
            if newValue {
                showPhoneDetails = true
            }
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
    
    // MARK: - Contact Card View (Matching Screenshot Design)
    private var selectedContactCard: some View {
        HStack(spacing: 12) {
            // Person Icon (Simple outlined person icon)
            Image(systemName: "person")
                .font(.system(size: 22))
                .foregroundColor(.primaryF9CE29)
            
            // Contact Info
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedContactName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black000000)
                
                Text(phoneNumber)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black000000)
            }
            
            Spacer()
            
            // X Button
            Button {
                clearContact()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.primary).opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.primary), lineWidth: 1.5)
        )
        .cornerRadius(8)
    }
    
    // MARK: - Phone Input Field (When no contact selected)
    private var phoneInputField: some View {
        ZStack {
            HStack(spacing: 12) {
                AdvancedTextField(
                    text: $phoneNumber,
                    placeholder: "Phone Number".localized(),
                    isRTL: Constants.shared.isAR,
                    keyboardType: .phonePad,
                    fieldType: .none,
                    onFocusChange: { focused in
                        if focused {
                            focusedField = .phone
                        } else if focusedField == .phone {
                            focusedField = nil
                        }
                    }
                )
                .onChange(of: phoneNumber) { _, newValue in
                    validatePhoneLive(newValue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.grayF6F6F6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(focusedField == .phone ? Color(.primary) : Color.clear, lineWidth: 1)
            )
            
            HStack {
                Spacer()
                Button {
                    showContactPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(.getcontacts)
                    }
                }
                .padding(.trailing, 10)
            }
        }
    }

 

    // MARK: - Helper Functions
    private func clearContact() {
        hasSelectedContact = false
        selectedContactName = ""
        phoneNumber = ""
        phoneError = ""
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
    
    

    
    private func validatePhoneLive(_ value: String) {
        let phoneNumber = phoneNumber.normalizePhoneNumber
       
        if hasAttemptedSubmit || !phoneNumber.isEmpty {
            if phoneNumber.isEmpty {
                phoneError = "enterPhone".localized()
            } else if !phoneNumber.isValidPhone() {
                phoneError = "enterValidPhone".localized()
            } else {
                phoneError = ""
            }
        }
    }
    
    // MARK: - Keyboard Navigation
    private func showNextField() {
        switch focusedField {
        case .amount:
            if !hasSelectedContact {
                focusedField = .phone
            }
        case .phone: focusedField = nil
        default: break
        }
    }
    
    private func showPreviousField() {
        switch focusedField {
        case .phone: focusedField = .amount
        case .amount: focusedField = nil
        default: break
        }
    }
}

enum TransferField {
    case amount, phone
}

