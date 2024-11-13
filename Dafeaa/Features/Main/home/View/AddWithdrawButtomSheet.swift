//
//  AddWithdrawButtomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 27/10/2024.
//

import SwiftUI

enum bottomSheetAction {
    case addBalance
    case withDraw
}

struct AddWithdrawBottomSheet: View {
    @State private var amount: String = ""
    @Binding var actionType: bottomSheetAction?
    @Binding var amountDouble: Double
    @Binding var isSheetPresented: Bool
    @StateObject var viewModel = HomeVM()
    @State var actionFinished: Bool = false

    var body: some View {
        ZStack {
            Color.clear // Transparent background for detecting taps outside
                
            VStack(spacing: 16) {
                
                Text(actionType == .addBalance ? "addWalletBalance".localized() : "withdrawWalletBalance".localized())
                    .textModifier(.plain, 19, .black222222)
                
//                Spacer(minLength: 10) // Control minimum spacing
                    .padding(.bottom)
                HStack {
                    Image(.saudiFlag)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("SAR")
                        .textModifier(.bold, 22, .gray919191)
                }
                .padding(.horizontal)
                
                TextField("0", text: $amount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textModifier(.plain, 43, .black2B2D33)
                    .frame(minHeight: 50) // Explicit height for text field
                    
                Text(actionType == .addBalance ? "noExtraFees".localized() : "weWillContactYou".localized())
                    .textModifier(.bold, 14, actionType == .addBalance ? .gray919191 : Color(.redD73D24))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
//                Spacer(minLength: 10) // Control minimum spacing
                
                ReusableButton(buttonText: actionType == .addBalance ? "addBalance".localized() : "withdrawBalance".localized(), isEnabled: true) {
                    switch actionType {
                    case .addBalance:
                        actionFinished = true
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        print("Balance Added successfully")
                    case .withDraw:
                        amountDouble = Double(amount.convertDigitsToEng) ?? 0
                        viewModel.withdrawAmount(amount: amountDouble)
                    case .none:
                        return
                    }
                }
            }
            .onChange(of: viewModel._isWithdrawSuccess, { _, newValue in
                if newValue {
                    print("Balance withdraw successfully")
                    isSheetPresented = false
                }
            })
            .padding()
            .background(Color.white) // Specify background color to avoid transparent view issues
            .cornerRadius(24)
            .frame(height: UIScreen.main.bounds.height * 0.6) // Explicit frame height
            .onTapGesture {
                hideKeyboard()
            }
           
        }
        .toastView(toast: $viewModel.toast)
        .onTapGesture {
            hideKeyboard() // Ensures keyboard is dismissed on any tap outside the TextField
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//#Preview {
//    AddWithdrawBottomSheet(amountDouble: .constant(0))
//}
