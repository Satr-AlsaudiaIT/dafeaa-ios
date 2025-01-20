import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 20) {
                
                NavigationBarView(title: "Help and Support") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("helpTitle".localized())
                            .textModifier(.plain, 14, .black292D32)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("helpSubTitle".localized())
                            .textModifier(.plain, 14, .gray919191)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("keepContactWithUs".localized())
                            .textModifier(.plain, 14, .black292D32)
                            .frame(height: 23)
                        
                        // Button to make a phone call
                        ButtonWithImageView(imageName: .callCalling, text: "contactClientsServices".localized()) {
                            let phoneNumber = "tel://\(viewModel.contactData?.contactPhone ?? "")"
                            if let url = URL(string: phoneNumber) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        // Button to open Keybase chat
                        ButtonWithImageView(imageName: .chat, text: "chatClientsServices".localized()) {
                            openKeybaseChat("nTest")
                        }
                        
                        // Button to send an email
                        ButtonWithImageView(imageName: .email, text: "contactWithEmail".localized()) {
                            let email = "mailto:\(viewModel.contactData?.contactEmail ?? "")"
                            if let url = URL(string: email) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            AppState.shared.swipeEnabled = true
            viewModel.getContacts()
        }
    }
    
    /// Open Keybase chat with the given username
    func openKeybaseChat(_ username: String) {
        let keybaseURLScheme = "keybase://chat?username=\(username)"
        let keybaseWebURL = "https://keybase.io/\(username)" // Web URL for fallback

        if let url = URL(string: keybaseURLScheme), UIApplication.shared.canOpenURL(url) {
            // Open Keybase if installed
            UIApplication.shared.open(url)
        }
                 else if let url = URL(string: keybaseWebURL) {
                    // Open Keybase website if app is not installed
                    UIApplication.shared.open(url)
                }
        /*else {
         // Redirect to App Store if Keybase is not installed
         if let appStoreURL = URL(string: "https://apps.apple.com/app/keybase-crypto-for-everyone/id1044461770") {
             UIApplication.shared.open(appStoreURL)
         }
     }*/
    }
}

#Preview {
    HelpAndSupportView()
}
