//
//  PaymentWebView.swift
//  Dafeaa
//
//  Created by AMNY on 26/01/2025.
//

import SwiftUI
@preconcurrency import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var onActionTriggered: (() -> Void)?

    init(onActionTriggered: @escaping () -> Void) {
        self.onActionTriggered = onActionTriggered
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        print("PaymentWebView URL: \(urlString)")
        
        if urlString.contains("status=") {
            // Extract status from URL
            if let url = navigationAction.request.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                
                var status = ""
                
                for item in queryItems {
                    if item.name == "status" {
                        status = item.value ?? ""
                        break
                    }
                }
                
                // Save payment status to Constants
                if !status.isEmpty {
                    Constants.lastPaymentStatus = status
                    Constants.shouldNavigateToWallet = true
                    print("Payment Status Saved: \(status)")
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NavigationUtil.popToRootView()
            }
        }
        
        decisionHandler(.allow)
    }
}

struct PaymentWebView: UIViewRepresentable {
    let url: String
    var onActionTriggered: (() -> Void)?

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(
            onActionTriggered: onActionTriggered ?? {}
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update logic needed for now
    }
}

struct PaymentWebViewContainer: View {
    let url: String
    @State private var statusMessage: String = "Initializing..."
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            PaymentWebView(url: url)
            VStack {
                NavigationBarView(title: "Payment".localized()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    PaymentWebViewContainer(url: "https://checkout.tap.company/?mode=page&themeMode=&language=en&token=eyJhbGciOiJIUzI1NiJ9.eyJpZCI6IjY3OTY1OGNkZGVlZjQyNjg1YTY0NjUxYSJ9.-hd58sq_P4R2OT_Y9zJ6uK5nWCPkOTuTGn1JAOLebVE")
}
