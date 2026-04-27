//
// WithdrawDetailsView.swift
// Dafeaa
//
// Created by AMNY on 04/01/2026.
//

import SwiftUI
import LocalAuthentication

struct WithdrawDetailsView: View {
    @StateObject var ibanViewModel = IBANVM()
    @StateObject var withdrawViewModel = HomeVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var withdrawAmount: String = ""
    @State var accountHolderName: String = Constants.userName
    @State var selectedIBAN: String = ""
    @State var selectedIBANId: Int = 0
    @State var mobileNumber: String = Constants.phone
    @State var city: String = ""
    @State var ibanDisplayList: [String] = []
    
    @State private var amountError: String = ""
    @State private var nameError: String = ""
    @State private var ibanError: String = ""
    @State private var mobileError: String = ""
    @State private var cityError: String = ""
    @State private var reasonError: String = ""
    @State private var hasAttemptedSubmit: Bool = false

    @State private var selectedReason: TransferReason? = nil
    @State private var isReasonDropDownOpen: Bool? = false
    @State private var isIBANDropDownOpen: Bool? = false
    @FocusState private var focusedField: WithdrawFormField?
    @State private var showSARIEAlert: Bool = false

    var isFormValid: Bool {
        let amount = Double(withdrawAmount.convertDigitsToEng) ?? 0
        return amount > 0 &&
            !accountHolderName.isEmpty &&
            selectedIBANId != 0 &&
            !mobileNumber.isEmpty &&
            mobileNumber.isValidPhone() &&
            !city.isEmpty &&
            selectedReason != nil &&
            amountError.isEmpty &&
            nameError.isEmpty &&
            ibanError.isEmpty &&
            mobileError.isEmpty &&
            cityError.isEmpty &&
            reasonError.isEmpty
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "Payout".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Withdrawal Amount".localized())
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

                                TextField("0", text: $withdrawAmount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .textModifier(.plain, 43, .black2B2D33)
                                    .frame(minHeight: 50)
                                    .focused($focusedField, equals: .amount)
                                    .onChange(of: withdrawAmount) { _, newValue in
                                        validateAmountLive(newValue)
                                        let amount = Double(newValue.convertDigitsToEng) ?? 0
                                        if amount > 0 && selectedIBANId != 0 {
                                            showSARIEAlert = shouldShowSARIEAlert()
                                        }
                                    }

                                if !amountError.isEmpty {
                                    Text(amountError).font(.system(size: 12)).foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.top, 24)

                        if !showSARIEAlert {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blueAlert)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notice".localized()).textModifier(.plain, 14, .mainBlueAlert)
                                    Text("Withdrawals are processed instantly or within 5 minutes.".localized()).textModifier(.plain, 12, .blueAlert)
                                }
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.blue), lineWidth: 1))
                        }

                        if showSARIEAlert {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.orangeAlert)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("5 minutes during business hours, otherwise the next business day".localized()).textModifier(.plain, 12, .brownAlert)
                                    HStack(alignment: .center, spacing: 2) {
                                        Text("SARIE transfer – for amounts over".localized()).textModifier(.plain, 12, .orangeAlert)
                                        HStack(spacing: 5) {
                                            Text("20,000").textModifier(.plain, 12, .orangeAlert)
                                            Image(.riyal).resizable().aspectRatio(contentMode: .fit).foregroundColor(.orangeAlert).frame(width: 14)
                                        }
                                        .environment(\.layoutDirection, .rightToLeft)
                                    }
                                }
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.primary), lineWidth: 1))
                        }

                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "ACCOUNT HOLDER NAME".localized()).textModifier(.plain, 14, .black1E1E1E)
                                CustomMainTextField(text: $accountHolderName, placeHolder: "Account Holder Name", image: .nameTFIcon)
                                    .focused($focusedField, equals: .accountName)
                                    .onChange(of: accountHolderName) { _, newValue in validateNameLive(newValue) }
                                if !nameError.isEmpty {
                                    Text(nameError).font(.system(size: 12)).foregroundColor(.red).padding(.leading, 8)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "IBAN".localized()).textModifier(.plain, 14, .black1E1E1E)
                                DropdownSearchTF(
                                    placeHolder: "Select IBAN".localized(),
                                    isOpen: $isIBANDropDownOpen,
                                    text: $selectedIBAN,
                                    title: "IBAN".localized(),
                                    options: $ibanDisplayList,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    image: UIImage(systemName: "creditcard")
                                )
                                .focused($focusedField, equals: .iban)
                                .onChange(of: selectedIBAN) { _, newValue in
                                    if newValue != "" {
                                        selectedIBANId = getIBANId(from: selectedIBAN)
                                        let amount = Double(withdrawAmount.convertDigitsToEng) ?? 0
                                        if amount > 0 { showSARIEAlert = shouldShowSARIEAlert() }
                                        validateIBANLive()
                                    }
                                }
                                .onChange(of: isIBANDropDownOpen) { _, new in
                                    if new == true { selectedIBAN = "" }
                                }
                                if !ibanError.isEmpty {
                                    Text(ibanError).font(.system(size: 12)).foregroundColor(.red).padding(.leading, 8)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "MOBILE NUMBER".localized()).textModifier(.plain, 14, .black1E1E1E)
                                CustomMainTextField(text: $mobileNumber, placeHolder: "Mobile Number", image: .callCalling)
                                    .focused($focusedField, equals: .mobile)
                                    .onChange(of: mobileNumber) { _, newValue in validateMobileLive(newValue) }
                                if !mobileError.isEmpty {
                                    Text(mobileError).font(.system(size: 12)).foregroundColor(.red).padding(.leading, 8)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "CITY".localized()).textModifier(.plain, 14, .black1E1E1E)
                                CustomMainTextField(text: $city, placeHolder: "City", image: .iconAddress)
                                    .focused($focusedField, equals: .city)
                                    .onChange(of: city) { _, newValue in validateCityLive(newValue) }
                                if !cityError.isEmpty {
                                    Text(cityError).font(.system(size: 12)).foregroundColor(.red).padding(.leading, 8)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TransferReasonDropdown(selectedReason: $selectedReason, isOpen: $isReasonDropDownOpen)
                                    .onChange(of: selectedReason) { _, _ in validateReasonLive() }
                                if !reasonError.isEmpty {
                                    Text(reasonError).font(.system(size: 12)).foregroundColor(.red).padding(.leading, 8)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }

                Spacer()

                Button(action: {
                    hasAttemptedSubmit = true
                    validateAmountLive(withdrawAmount)
                    validateNameLive(accountHolderName)
                    validateIBANLive()
                    validateMobileLive(mobileNumber)
                    validateCityLive(city)
                    validateReasonLive()
                    if isFormValid { submitWithdraw() }
                }) {
                    Text("Withdraw".localized())
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

            if ibanViewModel.isLoading || withdrawViewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: $ibanViewModel.toast)
        .toastView(toast: $withdrawViewModel.toast)
        .navigationBarHidden(true)
        .onAppear { ibanViewModel.getIBANs() }
        .onChange(of: ibanViewModel.ibanList) { _, _ in updateIBANDisplayList() }
        .onChange(of: withdrawViewModel._isWithdrawSuccess) { _, newValue in
            if newValue { presentationMode.wrappedValue.dismiss() }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done".localized()) { hideKeyboard() }
                Spacer()
                Button { showPreviousTextField() } label: { Image(systemName: "chevron.up").foregroundColor(.blue) }
                Button { showNextTextField() } label: { Image(systemName: "chevron.down").foregroundColor(.blue) }
            }
        }
    }

    private func updateIBANDisplayList() {
        ibanDisplayList = ibanViewModel.ibanList.map { $0.iban ?? "" }
    }

    private func getIBANId(from displayText: String) -> Int {
        ibanViewModel.ibanList.first(where: { ($0.iban ?? "") == displayText })?.id ?? 0
    }

    private func validateAmountLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            let amount = Double(value.convertDigitsToEng) ?? 0
            amountError = (value.isEmpty || amount <= 0) ? "amount_validation".localized() : ""
        }
    }

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
            if value.isEmpty { mobileError = "mobileValidation".localized() }
            else if !value.isValidPhone() { mobileError = "invalidMobileValidation".localized() }
            else { mobileError = "" }
        }
    }

    private func validateCityLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            cityError = value.isEmpty ? "cityValidation".localized() : ""
        }
    }

    private func validateReasonLive() {
        if hasAttemptedSubmit || selectedReason != nil {
            reasonError = selectedReason == nil ? "select_transfer_reason".localized() : ""
        }
    }

    private func submitWithdraw() {
        validateAmountLive(withdrawAmount)
        validateNameLive(accountHolderName)
        validateIBANLive()
        validateMobileLive(mobileNumber)
        validateCityLive(city)
        validateReasonLive()
        if isFormValid { authenticateWithBiometrics() }
    }

    private func showNextTextField() {
        switch focusedField {
        case .amount:      focusedField = .accountName
        case .accountName: focusedField = .iban
        case .iban:        focusedField = .mobile
        case .mobile:      focusedField = .city
        default:           focusedField = nil
        }
    }

    private func showPreviousTextField() {
        switch focusedField {
        case .city:        focusedField = .mobile
        case .mobile:      focusedField = .iban
        case .iban:        focusedField = .accountName
        case .accountName: focusedField = .amount
        default:           focusedField = nil
        }
    }

    private func shouldShowSARIEAlert() -> Bool {
        let amount = Double(withdrawAmount.convertDigitsToEng) ?? 0
        guard amount > Constants.WITHDRAW_THRESHOLD, selectedIBANId != 0 else { return false }
        if let data = ibanViewModel.ibanList.first(where: { $0.id == selectedIBANId }),
           let iban = data.iban {
            return !Constants.isArabNationalBank(iban)
        }
        return false
    }

    private func authenticateWithBiometrics() {

            BiometricAuthManager.shared.authenticate(message: "confirm_payment_biometric".localized()) { success, _ in
                if success {
                    self.callWithdrawAPI()
                }
            }
        }
        
//    private func authenticateWithBiometrics() {
//        let context = LAContext()
//        var error: NSError?
//        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//            authenticateWithPasscode()
//            return
//        }
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "confirm_payment_biometric".localized()) { success, authError in
//            DispatchQueue.main.async {
//                if success { callWithdrawAPI() }
//                else if let err = authError as? LAError, err.code == .biometryLockout { authenticateWithPasscode() }
//            }
//        }
//    }
//
//    private func authenticateWithPasscode() {
//        let context = LAContext()
//        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "confirm_payment_biometric".localized()) { success, _ in
//            DispatchQueue.main.async {
//                if success { callWithdrawAPI() }
//            }
//        }
//    }
    private func callWithdrawAPI() {
        let amount = Double(withdrawAmount.convertDigitsToEng) ?? 0
        withdrawViewModel.validateWithdrawAmount(
            amount: amount,
            accountName: accountHolderName,
            iban: selectedIBAN,
            mobile: mobileNumber,
            city: city,
            reason: selectedReason?.localized ?? ""
        )
    }
}

enum WithdrawFormField { case amount, accountName, iban, mobile, city }

#Preview { WithdrawDetailsView() }
