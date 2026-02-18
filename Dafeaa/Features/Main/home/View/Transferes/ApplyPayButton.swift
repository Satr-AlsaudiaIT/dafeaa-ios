//
//  ApplyPayButton.swift
//  Dafeaa
//
//  Created by AMNY on 15/01/2026.
//

import SwiftUI
import PassKit

struct ApplyPayButton: View {
    let amount: Double
    var currency: String = "SAR"
    var countryCode: String = "SA"
    var onPaymentSuccess: ((String) -> Void)?
    
    @State private var paymentHandler = PaymentHandler()
    
    var body: some View {
        Button(action: {
            self.paymentHandler.startPayment(
                amount: amount,
                currency: currency,
                countryCode: countryCode
            ) { success, token in
                if success, let token = token {
                    print("Payment Success with token: \(token)")
                    onPaymentSuccess?(token)
                } else {
                    print("Payment Failed")
                }
            }
        }, label: {
            HStack {
                Text("Pay with".localized())
                    .foregroundColor(.white)
                Image(systemName: "apple.logo")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.black)
            .cornerRadius(12)
        })
    }
}
