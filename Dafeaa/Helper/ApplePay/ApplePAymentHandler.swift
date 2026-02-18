//
//  PaymentButton.swift
//  Dafeaa
//
//  Created by AMNY on 15/01/2026.
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
    
    func startPayment(
        amount: Double,
        currency: String = "SAR",
        countryCode: String = "SA",
        completion: @escaping PaymentCompletionHandler
    ) {
        
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
        paymentRequest.merchantIdentifier = "merchant.com.Dafeaa.Plantech.merchent"
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currency
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { presented in
            if !presented {
                print("Failed to present payment controller")
                completion(false, nil)
            }
        })
    }
}

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Extract token
        let tokenData = payment.token.paymentData
        let tokenString = tokenData.base64EncodedString()
        
        print("✅ Token extracted successfully")
        print("Token length: \(tokenString.count)")
        
        self.paymentToken = tokenString
        
        let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
        completion(result)
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if let token = self.paymentToken, !token.isEmpty {
                    self.completionHandler?(true, token)
                } else {
                    self.completionHandler?(false, nil)
                }
            }
        }
    }
}
