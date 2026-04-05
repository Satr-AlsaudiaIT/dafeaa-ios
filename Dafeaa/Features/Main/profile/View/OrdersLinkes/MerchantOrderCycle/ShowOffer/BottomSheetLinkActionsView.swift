// BottomSheetLinkActionsView.swift

import Foundation
import SwiftUI

struct BottomSheetLinkActionsView: View {
    @State var offer: OffersData?
    @Binding var toast: FancyToast?
    @Binding var isShow: Bool
    var onDelete: (() -> Void)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 24) {
                // Copy Button
                HStack(spacing: 3) {
                    Image(.copy)
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("copy_link_offer".localized())
                        .textModifier(.plain, 14, .black222222)
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: { copyCode() }, label: {
                            Text("code".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .overlay(Capsule().stroke(Color.black222222, lineWidth: 1))
                        })
                        Button(action: { copyURL() }, label: {
                            Text("link_offer".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .overlay(Capsule().stroke(Color.black222222, lineWidth: 1))
                        })
                    }
                }
                
                // Share Button
                HStack(spacing: 3) {
                    Image(.share)
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("share_offer".localized())
                        .textModifier(.plain, 14, .black222222)
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: { shareCode() }, label: {
                            Text("code".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .overlay(Capsule().stroke(Color.black222222, lineWidth: 1))
                        })
                        Button(action: { shareURL() }, label: {
                            Text("link_offer".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .overlay(Capsule().stroke(Color.black222222, lineWidth: 1))
                        })
                    }
                }
                
                // Share QR Code Button
                Button(action: { shareQRCode() }, label: {
                    HStack(spacing: 3) {
                        Image(.qrcodeShare)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("code_offer".localized())
                            .textModifier(.plain, 14, .black222222)
                    }
                })
                
                // Delete Button
                Button(action: { onDelete() }, label: {
                    HStack(spacing: 3) {
                        Image(.trash)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("delete".localized())
                            .textModifier(.plain, 14, .black222222)
                    }
                })
                
                Spacer()
            }
            Spacer()
        }
        .toastView(toast: $toast)
        .padding(.horizontal, 30)
        .padding(.top, 52)
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
    }
    
    // MARK: - Shared Activity Presenter (iPad safe)
    private func presentActivityViewController(_ activityViewController: UIActivityViewController) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("Root view controller is nil")
                return
            }
            
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = topViewController.view
                popover.sourceRect = CGRect(
                    x: topViewController.view.bounds.midX,
                    y: topViewController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
            
            topViewController.present(activityViewController, animated: true)
        }
    }
    
    // MARK: - Copy
    private func copyURL() {
        guard let offerCode = offer?.code else { return }
        let urlString = "https://dafea.com.sa/offers/\(offerCode)"
        UIPasteboard.general.string = urlString
        self.toast = FancyToast(type: .info, title: "", message: "copied successfully".localized())
    }
    
    private func copyCode() {
        guard let offerCode = offer?.code else { return }
        UIPasteboard.general.string = offerCode
        self.toast = FancyToast(type: .info, title: "", message: "copied successfully".localized())
    }
    
    // MARK: - Share
    private func shareCode() {
        guard let offerCode = offer?.code else { return }
        let activityViewController = UIActivityViewController(activityItems: [offerCode], applicationActivities: nil)
        presentActivityViewController(activityViewController)
    }
    
    private func shareURL() {
        guard let offerCode = offer?.code else { return }
        let urlString = "https://dafea.com.sa/offers/\(offerCode)"
        let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
        presentActivityViewController(activityViewController)
    }
    
    private func shareQRCode() {
        guard let offerCode = offer?.code,
              let qrCodeImage = qrcodeImage(string: offerCode) else {
            print("Failed to generate QR code image")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
        presentActivityViewController(activityViewController)
    }
}
