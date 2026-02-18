//
//  TransferBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 26/04/2025.
//

import SwiftUI
import LocalAuthentication

struct TransferBottomSheet: View {
    @Binding var isSheetPresented: Bool
    @Binding var amount: String
    @Binding var phoneNumber: String
    @Binding var name: String

    @Binding var isNavigateToTransferView : Bool
    @State private var selectedCountryCode: String = ""
    @State var price: String = ""
    @FocusState private var focusedField: FormField?
    @StateObject var viewModel = HomeVM()

    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 16) {
                PhoneNumberField(
                    phoneNumber: $phoneNumber,
                    selectedCountryCode: $selectedCountryCode,
                    image: .mobile)
                .focused($focusedField, equals: .phone)
                .id(FormField.phone)
                CustomMainTextField(text: $amount, placeHolder: "transferAmount".localized(),keyBoardType: .decimalPad,fieldType: .price)
                    .focused($focusedField, equals: .amount)
                    .id(FormField.amount)

                Spacer(minLength:60 )
                ReusableButton(buttonText:"transferBalance".localized(), isEnabled: true) {
                    viewModel.validateTransferAmount(phone: phoneNumber.normalizePhoneNumber, amount: amount)
                }
                .onChange(of: viewModel.isUserFound, { _, newValue in
                    if newValue {
                        isNavigateToTransferView = true
                        name = viewModel.userNameOfPhone
                        isSheetPresented = false
                    }
                })

              
            }
            .padding(.top,70)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(24)
            .toastView(toast: $viewModel.transferToast)
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
            else if !viewModel.isLoading {
                ProgressView().hidden()
            }
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    enum FormField {
        case phone, amount
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if device supports authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your passwords."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication Successful
                        print("Authentication Successful")
//                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                    } else {
                        // Authentication Failed
                        if let error = authenticationError as NSError? {
                            print("Authentication failed with error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            // No Biometrics or Passcode set
            if let error = error {
                print("Authentication not available: \(error.localizedDescription)")
            }
//            amountDouble = Double(amount.convertDigitsToEng) ?? 0
//            viewModel.validateWithdrawAmount(amount: amountDouble)
        }
    }


}
