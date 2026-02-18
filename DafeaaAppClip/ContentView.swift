//
//  ContentView.swift
//  DafeaaAppClip
//
//  Created by AMNY on 18/01/2026.
//

import SwiftUI
import PassKit


struct ContentView: View {
    @State private var amount: Double = 100.0
    @State private var currency: String = "SAR"
    @State private var reference: String = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let paymentHandler = PaymentHandler()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                VStack(spacing: 10) {
                    Image(.splashLogoWithoutName)
                    
                    Text("Dafeaa".localized())
                        .textModifier(.extraBold, 43, .black222222)
                }
                // Title
                Text("Add Balance".localized())
                    .textModifier(.bold, 32, .black222222)

                
                // Amount
                HStack {
                Text("\(amount, specifier: "%.2f")")
                    .textModifier(.bold, 60, .black222222)
                Image(.riyal)
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .foregroundColor(.black000000)
                     .frame(width: 48)
                     .padding(.trailing, 10)
            }
            .environment(\.layoutDirection, .rightToLeft)
                // Apple Pay Button
                Button(action: handlePayment) {
                    HStack(spacing: 12) {
                        Image(systemName: "applepay")
                            .font(.system(size: 28))
                        Text("Pay with Apple Pay".localized())
                            .textModifier(.bold, 18, .white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(isProcessing)
                .padding(.horizontal, 32)
                
                Spacer()
                
//                // App Clip Badge
//                Text("Powered by App Clip".localized)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.bottom)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppClipURLReceived"))) { notification in
            if let url = notification.object as? URL {
                parsePaymentURL(url)
            }
        }
        .alert("Payment Successful!".localized(), isPresented: $showSuccess) {
            Button("Done".localized()) {
                // User can close App Clip
            }
        } message: {
            Text("Your balance has been added successfully.".localized())
        }
        .alert("Payment Failed".localized(), isPresented: $showError) {
            Button("OK".localized()) {
                isProcessing = false
            }
        } message: {
            Text(errorMessage)
        }
        // Support RTL for Arabic
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    func parsePaymentURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        if let amountStr = queryItems.first(where: { $0.name == "amount" })?.value,
           let parsedAmount = Double(amountStr) {
            amount = parsedAmount
        }
        
        if let curr = queryItems.first(where: { $0.name == "currency" })?.value {
            currency = curr
        }
        
        if let ref = queryItems.first(where: { $0.name == "ref" })?.value {
            reference = ref
        }
        
        print("💰 Parsed: \(amount) \(currency), Ref: \(reference)")
    }
    
    func handlePayment() {
        isProcessing = true
        
        paymentHandler.startPayment(
            amount: amount,
            currency: currency,
            countryCode: "SA"
        ) { success, token in
            isProcessing = false
            
            if success, let token = token {
                print("✅ Payment token: \(token.prefix(30))...")
                sendToBackend(token: token)
            } else {
                errorMessage = "Payment was cancelled or failed.".localized()
                showError = true
            }
        }
    }
    
    func sendToBackend(token: String) {
        guard let url = URL(string: "https://yourdomain.com/api/process-payment") else {
            showSuccess = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "token": token,
            "amount": amount,
            "currency": currency,
            "reference": reference
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    errorMessage = "Network error. Please try again.".localized()
                    showError = true
                } else {
                    showSuccess = true
                }
            }
        }.resume()
    }
}
