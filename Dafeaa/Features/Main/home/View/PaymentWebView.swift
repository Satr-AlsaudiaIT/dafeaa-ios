//
//  PaymentWebView.swift
//  Dafeaa
//
//  Created by AMNY on 26/01/2025.
//


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

    init( onActionTriggered: @escaping () -> Void) {
        self.onActionTriggered = onActionTriggered
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        print(urlString)
        if urlString.contains("status=") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
       
            
        ZStack  {
                PaymentWebView(url: url)
            VStack {
                NavigationBarView(title: "payment") {
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
