//
//  PaymentHandler.swift
//  Dafeaa
//
//  Created by AMNY on 18/01/2026.
//


import PassKit

typealias PaymentCompletionHandler = (Bool, String?) -> Void

class PaymentHandler: NSObject {
    
    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .masterCard,
        .visa,
        .mada
    ]
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var completionHandler: PaymentCompletionHandler?
    var paymentToken: String?
    
    // Replace with your actual merchant ID
    private let merchantIdentifier = "merchant.com.yourcompany.dafeaa"
    
    func startPayment(
        amount: Double,
        currency: String = "SAR",
        countryCode: String = "SA",
        completion: @escaping PaymentCompletionHandler
    ) {
        
        guard PKPaymentAuthorizationController.canMakePayments() else {
            print("❌ Device cannot make payments")
            completion(false, nil)
            return
        }
        
        guard amount > 0 else {
            print("❌ Invalid amount: \(amount)")
            completion(false, nil)
            return
        }
        
        let totalAmount = NSDecimalNumber(value: amount)
        let total = PKPaymentSummaryItem(
            label: "Add Balance",
            amount: totalAmount,
            type: .final
        )
        
        paymentSummaryItems = [total]
        completionHandler = completion
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currency
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        
        paymentController?.present(completion: { [weak self] presented in
            if presented {
                print("✅ Payment controller presented")
            } else {
                print("❌ Failed to present payment controller")
                DispatchQueue.main.async {
                    self?.completionHandler?(false, nil)
                    self?.reset()
                }
            }
        })
    }
    
    private func reset() {
        paymentToken = nil
        paymentController = nil
        paymentSummaryItems = []
        completionHandler = nil
    }
}

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        
        let tokenData = payment.token.paymentData
        let tokenString = tokenData.base64EncodedString()
        
        guard !tokenString.isEmpty else {
            print("❌ Empty payment token")
            let result = PKPaymentAuthorizationResult(status: .failure, errors: nil)
            completion(result)
            return
        }
        
        print("✅ Token received: \(tokenString.prefix(20))...")
        self.paymentToken = tokenString
        
        let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
        completion(result)
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let token = self.paymentToken, !token.isEmpty {
                    print("✅ Payment completed")
                    self.completionHandler?(true, token)
                } else {
                    print("⚠️ Payment cancelled")
                    self.completionHandler?(false, nil)
                }
                self.reset()
            }
        }
    }
}
