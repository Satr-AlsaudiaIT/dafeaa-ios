//
//  AddBalanceCardDetailsView.swift
//  Dafeaa
//
//  Created by AMNY on 04/01/2026.
//

import SwiftUI

struct AddBalanceCardDetailsView: View {
    @StateObject var viewModel = HomeVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var addAmount: Double
    @State var cardHolderName: String = ""
    @State var cardNumber: String = ""
    @State var expirationMonth: String = ""
    @State var expirationYear: String = ""
    @State var cvv: String = ""
    
    @State private var nameError: String = ""
    @State private var cardNumberError: String = ""
    @State private var monthError: String = ""
    @State private var yearError: String = ""
    @State private var cvvError: String = ""
    @State private var hasAttemptedSubmit: Bool = false
    @State private var isExpanded: Bool = false
    @State private var navigateToPaymentWeb = false

    @FocusState private var focusedField: CardFormField?
    @State private var toast: FancyToast? = nil
    
    var isFormValid: Bool {
        !cardHolderName.isEmpty &&
        cardNumber.isValidCardNumber &&
        expirationMonth.isValidMonth &&
        expirationYear.isValidYear &&
        cvv.isValidCVV
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                NavigationBarView(title: "Payment".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - Header
                        VStack(spacing: 8) {
                            Text("Secure & Fast Payment Processing".localized())
                                .textModifier(.plain, 16, .gray979797)
                        }
                        .padding(.top, 24)
                        
                        // MARK: - Total Amount
                        VStack(spacing: 8) {
                            Text("Total Amount".localized())
                                .textModifier(.plain, 16, .gray979797)
                            
                            HStack(spacing: 5) {
                                Text(String(format: "%.1f",addAmount))
                                    .textModifier(.plain, 36, .black030319)
                                Image(.riyal)
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .foregroundColor(.black010202)
                                     .frame(width: 30)
                                     .padding(.trailing, 10)
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }
                                             
                        // MARK: - Apple Pay Button
                        ApplyPayButton(
                            amount: addAmount,
                            currency: "SAR",
                            countryCode: "SA",
                            validationReturn: { message in
                                self.toast = FancyToast(type: .error, title: "Error".localized(), message: message)
                            }
                        ) { token in
                            if token != "" {
                                viewModel.processApplePay(amount: addAmount, token: token)
                            }
                        }

                        // MARK: - Or Divider
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("Or pay with".localized())
                                .textModifier(.plain, 14, .gray979797)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // MARK: - Pay with Card Section
                        VStack(spacing: 0) {
                            // Card Header
                            Button(action: {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color(.black222222))
                                        .cornerRadius(8)
                                    
                                    Text("Pay with Card".localized())
                                        .textModifier(.plain, 16, .black1E1E1E)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.black1E1E1E)
                                }
                               
                            }
                            
                            if isExpanded {
                                VStack(spacing: 20) {
                                    // Cardholder Name
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("* " + "CARDHOLDER NAME".localized())
                                            .textModifier(.plain, 14, .black1E1E1E)
                                        
                                        CustomMainTextField(
                                            text: $cardHolderName,
                                            placeHolder: "Cardholder Name",
                                            image: nil
                                        )
                                        .focused($focusedField, equals: .cardHolderName)
                                        .onChange(of: cardHolderName) { _, newValue in
                                            validateNameLive(newValue)
                                        }
                                        
                                        if !nameError.isEmpty {
                                            Text(nameError)
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                                .padding(.leading, 8)
                                        }
                                    }
                                    
                                    // Card Number
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("CARD NUMBER".localized())
                                            .textModifier(.plain, 14, .black1E1E1E)
                                        
                                        CustomMainTextField(
                                            text: $cardNumber,
                                            placeHolder: "XXXX XXXX XXXX XXXX",
                                            image: nil,
                                            keyBoardType: .numberPad
                                        )
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .cardNumber)
                                        .onChange(of: cardNumber) { _, newValue in
                                            cardNumber = newValue.formatCardNumber()
                                            validateCardNumberLive(cardNumber)
                                        }
                                        
                                        if !cardNumberError.isEmpty {
                                            Text(cardNumberError)
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                                .padding(.leading, 8)
                                        }
                                    }
                                    
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("EXPIRATION DATE".localized())
                                                .textModifier(.plain, 14, .black1E1E1E)
                                            
                                            HStack(spacing: 8) {
                                                CustomMainTextField(
                                                    text: $expirationMonth,
                                                    placeHolder: "MM",
                                                    image: nil,
                                                    keyBoardType: .numberPad
                                                )
                                                .keyboardType(.numberPad)
                                                .focused($focusedField, equals: .expirationMonth)
                                                .onChange(of: expirationMonth) { _, newValue in
                                                    if newValue.count > 2 {
                                                        expirationMonth = String(newValue.prefix(2))
                                                    }
                                                    validateMonthLive(expirationMonth)
                                                }
                                                .frame(width: 80)
                                                CustomMainTextField(
                                                    text: $expirationYear,
                                                    placeHolder: "YYYY",
                                                    image: nil,
                                                    keyBoardType: .numberPad
                                                )
                                                .keyboardType(.numberPad)
                                                .focused($focusedField, equals: .expirationYear)
                                                .onChange(of: expirationYear) { _, newValue in
                                                    if newValue.count > 4 {
                                                        expirationYear = String(newValue.prefix(4))
                                                    }
                                                    validateYearLive(expirationYear)
                                                }
                                                .frame(width: 100)
                                            }
                                            
                                            HStack {
                                                if !monthError.isEmpty || !yearError.isEmpty {
                                                    Text(monthError.isEmpty ? yearError : monthError)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.red)
                                                        .padding(.leading, 8)
                                                }
                                            }
                                            .frame(height: 18)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        // CVV (Smaller)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("* CVV")
                                                .textModifier(.plain, 14, .black1E1E1E)
                                            MaskedTextField(
                                                   text: $cvv,
                                                   placeHolder: "•••".localized(),
                                                   maxLength: 3
                                               )
                                               .onChange(of: cvv) { _, newValue in
//                                                   if newValue.count > 3 {
//                                                       cvv = String(newValue.prefix(4))
//                                                   }
                                                   validateCVVLive(cvv)
                                               }
                                            
                                            
                                            HStack {
                                                if !cvvError.isEmpty {
                                                    Text(cvvError)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.red)
                                                        .padding(.leading, 8)
                                                }
                                            }
                                            .frame(height: 18)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(width: 120)
                                    }

                                }
                                .padding(.top ,10)
                            }
                        }
                        .padding(16)
                        .background(Color(.grayD1D5DB))
                        .cornerRadius(12)
                        // MARK: - Notice
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                            
                            Text("The amount will be charged to your wallet via Dafea".localized())
                                .textModifier(.plain, 12, .black1E1E1E)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
                
                Spacer()
                
                // MARK: - Charge Button
                Button(action: {
                    if isFormValid {
                        hasAttemptedSubmit = true
                        submitPayment()
                    }
                }) {
                    HStack {
                        Text("Charge".localized())
                            .textModifier(.plain, 16, .white)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(isFormValid ? Color.black : Color.gray.opacity(0.5))
                    .cornerRadius(32)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            // MARK: - Loading Indicator
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: Binding(
            get: { viewModel.toast ?? toast },
            set: { newVal in
                if viewModel.toast != nil { viewModel.toast = newVal }
                else { toast = newVal }
            }
        ))
        .navigationBarHidden(true)
        .onChange(of: viewModel._isPaymentSuccess) { _, newValue in
                       if newValue {
                           navigateToPaymentWeb = true
                       }
                   }
        .navigationDestination(isPresented: $navigateToPaymentWeb) {
            PaymentWebViewContainer(url: viewModel.paymentURL)
                }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done".localized()) {
                    hideKeyboard()
                }
                Spacer()
                Button(action: {
                    showPreviousTextField()
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
        .onChange(of: viewModel._isApplePaySuccess) { oldValue, newValue in
            presentationMode.wrappedValue.dismiss()
            Constants.shouldNavigateToWallet = true
            NavigationUtil.popToRootView()
        }
        .onAppear{
            Constants.shouldNavigateToWallet = false
            Constants.lastPaymentStatus = ""
            Constants.lastPayoutStatus = ""
        }
    }
    
    // MARK: - Live Validation
    private func validateNameLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                nameError = "Cardholder name required".localized()
            } else if value.containsNumbers {
                nameError = "Cardholder name cannot contain numbers".localized()
            } else if !value.hasMultipleWords {
                nameError = "Invalid cardholder name".localized()
            } else {
                nameError = ""
            }
        }
    }

    
    private func validateCardNumberLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                cardNumberError = "Card number required".localized()
            } else if !value.isValidCardNumber {
                cardNumberError = "Invalid card number".localized()
            } else {
                cardNumberError = ""
            }
        }
    }
    
    private func validateMonthLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                monthError = "Month required".localized()
            } else if !value.isValidMonth {
                monthError = "Invalid month (01-12)".localized()
            } else {
                monthError = ""
            }
        }
    }
    
    private func validateYearLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            let currentYear = Calendar.current.component(.year, from: Date())
            let maxYear = currentYear + 10
            
            if value.isEmpty {
                yearError = "Year required".localized()
            } else {
                switch value.yearValidationStatus {
                case .invalidFormat:
                    yearError = "Invalid year (YYYY)".localized()
                case .expired:
                    yearError = String(format: "Expired year".localized(), currentYear, maxYear)
                case .valid:
                    yearError = ""
                }
            }
        }
    }

    private func validateCVVLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                cvvError = "CVV required".localized()
            } else if !value.isValidCVV {
                cvvError = "Invalid CVV (3-4 digits)".localized()
            } else {
                cvvError = ""
            }
        }
    }
    
    // MARK: - Submit Payment
    private func submitPayment() {
            validateNameLive(cardHolderName)
            validateCardNumberLive(cardNumber)
            validateMonthLive(expirationMonth)
            validateYearLive(expirationYear)
            validateCVVLive(cvv)
            
            if isFormValid {
                viewModel.addAmount(
                    amount: addAmount,
                    cardNumber: cardNumber,
                    cardHolderName: cardHolderName,
                    month: expirationMonth,
                    year: expirationYear,
                    cvv: cvv
                )
            }
        }
    
    // MARK: - Keyboard Navigation
    private func showNextTextField() {
        switch focusedField {
        case .cardHolderName:
            focusedField = .cardNumber
        case .cardNumber:
            focusedField = .expirationMonth
        case .expirationMonth:
            focusedField = .expirationYear
        case .expirationYear:
            focusedField = .cvv
        default:
            focusedField = nil
        }
    }
    
    private func showPreviousTextField() {
        switch focusedField {
        case .cvv:
            focusedField = .expirationYear
        case .expirationYear:
            focusedField = .expirationMonth
        case .expirationMonth:
            focusedField = .cardNumber
        case .cardNumber:
            focusedField = .cardHolderName
        default:
            focusedField = nil
        }
    }
}

enum CardFormField {
    case cardHolderName
    case cardNumber
    case expirationMonth
    case expirationYear
    case cvv
}


