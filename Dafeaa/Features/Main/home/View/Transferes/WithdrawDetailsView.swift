//
// WithdrawDetailsView.swift
// Dafeaa
//
// Created by AMNY on 04/01/2026.
//

import SwiftUI

struct WithdrawDetailsView: View {
    @StateObject var ibanViewModel = IBANVM()
    @StateObject var withdrawViewModel = HomeVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var withdrawAmount: Double
    @State var accountHolderName: String = Constants.userName
    @State var selectedIBAN: String = ""
    @State var selectedIBANId: Int = 0
    @State var mobileNumber: String = Constants.phone
    @State var city: String = ""
    @State var ibanDisplayList: [String] = []
    
    @State private var nameError: String = ""
    @State private var ibanError: String = ""
    @State private var mobileError: String = ""
    @State private var cityError: String = ""
    @State private var hasAttemptedSubmit: Bool = false
    
    @State private var isIBANDropDownOpen: Bool? = false
    @FocusState private var focusedField: WithdrawFormField?
    @State private var showSARIEAlert: Bool = false

    var isFormValid: Bool {
        !accountHolderName.isEmpty &&
        selectedIBANId != 0 &&
        !mobileNumber.isEmpty &&
        mobileNumber.isValidPhone() &&
        !city.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                NavigationBarView(title: "Payout".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - Withdrawal Amount
                        VStack(spacing: 8) {
                            Text("Withdrawal Amount".localized())
                                .textModifier(.plain, 16, .gray979797)
                            HStack(spacing: 5) {
                                Text(String(format: "%.1f",withdrawAmount))
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
                        .padding(.top, 24)
                        
                        
                        if !showSARIEAlert {
                            // MARK: - Notice
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blueAlert)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notice".localized())
                                        .textModifier(.plain, 14, .mainBlueAlert)
                                    Text("Withdrawals are processed instantly or within 5 minutes.".localized())
                                        .textModifier(.plain, 12, .blueAlert)
                                }
                                
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                 .stroke( Color(.blue) , lineWidth: 1)
                            )
                        }
                        
                        if showSARIEAlert {
                                                   HStack(spacing: 12) {
                                                       Image(systemName: "info.circle")
                                                           .foregroundColor(.orangeAlert)
                                                           .font(.system(size: 20))
                                                       
                                                       VStack(alignment: .leading, spacing: 4) {
                                                           Text("5 minutes during business hours, otherwise the next business day".localized())
                                                               .textModifier(.plain, 12, .brownAlert)
                                                           HStack(alignment: .center, spacing: 2) {
                                                               Text("SARIE transfer – for amounts over".localized())
                                                                   .textModifier(.plain, 12, .orangeAlert)
                                                               HStack(spacing: 5) {
                                                                   Text("20,000")
                                                                       .textModifier(.plain, 12, .orangeAlert)
                                                                   Image(.riyal)
                                                                       .resizable()
                                                                       .aspectRatio(contentMode: .fit)
                                                                       .foregroundColor( .orangeAlert)
                                                                       .frame(width: 14)
//                                                                       .padding(.trailing, 4)
                                                               }
                                                               .environment(\.layoutDirection, .rightToLeft)
                                                           }
                                                       }
                                                       
                                                       Spacer()
                                                   }
                                                   .padding(8)
                                                   .background(Color.yellow.opacity(0.1))
                                                   .cornerRadius(8)
                                                   .overlay(
                                                       RoundedRectangle(cornerRadius: 8)
                                                        .stroke( Color(.primary) , lineWidth: 1)
                                                   )
                                               }
                        
                        // MARK: - Form Fields
                        VStack(spacing: 20) {
                            // Account Holder Name
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "ACCOUNT HOLDER NAME".localized())
                                    .textModifier(.plain, 14, .black1E1E1E)
                                
                                CustomMainTextField(
                                    text: $accountHolderName,
                                    placeHolder: "Account Holder Name",
                                    image: .nameTFIcon
                                )
                                .focused($focusedField, equals: .accountName)
                                .onChange(of: accountHolderName) { _, newValue in
                                    validateNameLive(newValue)
                                }
                                
                                
                                if !nameError.isEmpty {
                                    Text(nameError)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
                            }
                            
                            // IBAN Dropdown
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "IBAN".localized())
                                    .textModifier(.plain, 14, .black1E1E1E)
                                
                                DropdownSearchTF(
                                    placeHolder: "Select IBAN".localized(),
                                    isOpen: $isIBANDropDownOpen,
                                    text: $selectedIBAN,
                                    title: "IBAN".localized(),
                                    options: $ibanDisplayList,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    image:  UIImage(systemName: "creditcard") ?? UIImage()
                                )
                                .focused($focusedField, equals: .iban)
                                .onChange(of: selectedIBAN) { _, newValue in
                                    if newValue != "" {
                                        selectedIBANId = getIBANId(from: selectedIBAN)
                                        showSARIEAlert = shouldShowSARIEAlert()
                                        
                                        validateIBANLive()
                                    }
                                }
                                .onChange(of: isIBANDropDownOpen) { _, new in
                                    if new == true {
                                        selectedIBAN = ""
                                    }
                                }
                                
                                
                                if !ibanError.isEmpty {
                                    Text(ibanError)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
                            }
                            
                            // Mobile Number
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "MOBILE NUMBER".localized())
                                    .textModifier(.plain, 14, .black1E1E1E)
                                
                                CustomMainTextField(
                                    text: $mobileNumber,
                                    placeHolder: "Mobile Number",
                                    image: .callCalling
                                )
                                .focused($focusedField, equals: .mobile)
                                .onChange(of: mobileNumber) { _, newValue in
                                    validateMobileLive(newValue)
                                }
                                
                                if !mobileError.isEmpty {
                                    Text(mobileError)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
                            }
                            
                            // City
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "CITY".localized())
                                    .textModifier(.plain, 14, .black1E1E1E)
                                
                                CustomMainTextField(
                                    text: $city,
                                    placeHolder: "City",
                                    image: .iconAddress
                                )
                                .focused($focusedField, equals: .city)
                                .onChange(of: city) { _, newValue in
                                    validateCityLive(newValue)
                                }
                                
                                if !cityError.isEmpty {
                                    Text(cityError)
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
                
                Spacer()
                
                // MARK: - Withdraw Button
                Button(action: {
                    if isFormValid {
                        hasAttemptedSubmit = true
                        submitWithdraw()
                    }
                }) {
                    Text("Withdraw".localized())
                        .textModifier(.plain, 15, .white)
                        .frame(maxWidth: .infinity, minHeight: 51)
                        .background(isFormValid ? Color(.black222222) : Color(.grayDADADA))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.clear, lineWidth: 1)
                        )
                        .padding(1)
                        .background(isFormValid ? Color(.black222222) : Color(.grayDADADA))
                        .cornerRadius(32)
                }
                .disabled(!isFormValid)
                .shadow(color: isFormValid ? Color(.dropShadow2B2D3333).opacity(0.2) : .clear, radius: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            // MARK: - Loading Indicator
            if ibanViewModel.isLoading || withdrawViewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: $ibanViewModel.toast)
        .toastView(toast: $withdrawViewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            ibanViewModel.getIBANs()
        }
        .onChange(of: ibanViewModel.ibanList) { _, newList in
            updateIBANDisplayList()
        }
        .onChange(of: withdrawViewModel._isWithdrawSuccess) { _, newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
                
            }
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
    }
    
    // MARK: - Update IBAN Display List
    private func updateIBANDisplayList() {
        ibanDisplayList = ibanViewModel.ibanList.map { iban in
            let ibanNumber = iban.iban ?? ""
            let accountName = iban.name ?? ""
            return "\(ibanNumber)"
        }
    }
    
    // MARK: - Get IBAN ID from Display Text
    private func getIBANId(from displayText: String) -> Int {
        if let selectedIBAN = ibanViewModel.ibanList.first(where: { iban in
            let display = "\(iban.iban ?? "")"
            return display == displayText
        }) {
            return selectedIBAN.id ?? 0
        }
        return 0
    }
    
    // MARK: - Live Validation
    private func validateNameLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            nameError = value.isEmpty ? "accountHolderNameValidation".localized() : ""
        }
    }
    
    private func validateIBANLive() {
        if hasAttemptedSubmit || selectedIBANId != 0 {
            ibanError = selectedIBANId == 0 ? "ibanSelectionValidation".localized() : ""
        }
    }
    
    private func validateMobileLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                mobileError = "mobileValidation".localized()
            } else if !value.isValidPhone() {
                mobileError = "invalidMobileValidation".localized()
            } else {
                mobileError = ""
            }
        }
    }
    
    private func validateCityLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            cityError = value.isEmpty ? "cityValidation".localized() : ""
        }
    }
    
    // MARK: - Submit Withdraw
    private func submitWithdraw() {
        validateNameLive(accountHolderName)
        validateIBANLive()
        validateMobileLive(mobileNumber)
        validateCityLive(city)
        
        if isFormValid {
            withdrawViewModel.validateWithdrawAmount(
                amount: withdrawAmount,
                accountName: accountHolderName,
                iban: selectedIBAN,
                mobile: mobileNumber,
                city: city
            )
        }
    }
    
    
    // MARK: - Keyboard Navigation
    private func showNextTextField() {
        switch focusedField {
        case .accountName:
            focusedField = .iban
        case .iban:
            focusedField = .mobile
        case .mobile:
            focusedField = .city
        default:
            focusedField = nil
        }
    }
    
    private func showPreviousTextField() {
        switch focusedField {
        case .city:
            focusedField = .mobile
        case .mobile:
            focusedField = .iban
        case .iban:
            focusedField = .accountName
        default:
            focusedField = nil
        }
    }
    
    
    private func shouldShowSARIEAlert() -> Bool {
          
          guard withdrawAmount > Constants.WITHDRAW_THRESHOLD else { return false }
          guard selectedIBANId != 0 else { return false }
          
          if let selectedIBANData = ibanViewModel.ibanList.first(where: { $0.id == selectedIBANId }),
             let ibanNumber = selectedIBANData.iban {
              return !Constants.isArabNationalBank(ibanNumber)
          }
          
          return false
      }
}

enum WithdrawFormField {
    case accountName
    case iban
    case mobile
    case city
}

#Preview {
    WithdrawDetailsView(withdrawAmount: 100.0)
}
