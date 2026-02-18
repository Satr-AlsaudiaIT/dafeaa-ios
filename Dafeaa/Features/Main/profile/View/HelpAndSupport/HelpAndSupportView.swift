import SwiftUI
import UIKit

struct HelpAndSupportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()

    var body: some View {

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

                    // Phone call
                    ButtonWithImageView(
                        imageName: .callCalling,
                        text: "contactClientsServices".localized(),
                        details: viewModel.contactData?.contactPhone ?? "",
                        showCopyIcon: true
                    ) {
                        let raw = viewModel.contactData?.contactPhone ?? ""
                        let phoneNumber = "tel://\(raw)"
                        if let url = URL(string: phoneNumber) {
                            UIApplication.shared.open(url)
                        }
                    } onCopy: {
                        let phone = viewModel.contactData?.contactPhone ?? ""
                        UIPasteboard.general.string = phone
                        // Optional: Show toast
                        viewModel.toast = FancyToast(type: .success, title: "", message: "Phone number copied".localized())
                    }

                    // WhatsApp
                    ButtonWithImageView(
                        imageName: .chat,
                        text: "WhatsApp".localized(),
                        details: viewModel.contactData?.contactPhone ?? "",
                        showCopyIcon: true
                    ) {
                        let raw = viewModel.contactData?.contactPhone ?? ""
                        openWhatsApp(phoneRaw: raw, message: "Hello".localized())
                    } onCopy: {
                        let phone = viewModel.contactData?.contactPhone ?? ""
                        UIPasteboard.general.string = phone
                        viewModel.toast = FancyToast(type: .success, title: "", message: "Phone number copied".localized())
                    }

                    // Email
                    ButtonWithImageView(
                        imageName: .email,
                        text: "contactWithEmail".localized(),
                        details: viewModel.contactData?.contactEmail ?? "",
                        showCopyIcon: true
                    ) {
                        let raw = viewModel.contactData?.contactEmail ?? ""
                        let email = "mailto:\(raw)"
                        if let url = URL(string: email) {
                            UIApplication.shared.open(url)
                        }
                    } onCopy: {
                        let email = viewModel.contactData?.contactEmail ?? ""
                        UIPasteboard.general.string = email
                        viewModel.toast = FancyToast(type: .success, title: "", message: "Email copied".localized())
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            AppState.shared.swipeEnabled = true
            viewModel.getContacts()
        }
    }
    
    private func cleanedInternationalNumber(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
    }

    private func openWhatsApp(phoneRaw: String, message: String? = nil) {
        let phone = cleanedInternationalNumber(phoneRaw)

        var urlString = "https://wa.me/\(phone)"
        if let message, !message.isEmpty {
            let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "?text=\(encoded)"
        }

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    HelpAndSupportView()
}

