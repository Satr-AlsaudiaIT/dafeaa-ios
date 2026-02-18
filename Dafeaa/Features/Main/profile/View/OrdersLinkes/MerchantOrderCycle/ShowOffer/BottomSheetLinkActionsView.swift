//
//  BottomSheetLinkActionsView.swift
//  Dafeaa
//
//  Created by AMNY on 23/03/2025.
//

import Foundation
import SwiftUI

struct BottomSheetLinkActionsView: View {
    @State var offer: OffersData?
    @Binding var toast: FancyToast?
    @Binding var isShow: Bool
    var onDelete: (() -> Void)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading,spacing: 24) {
                // Copy Button
                
                HStack(spacing: 3) {
                    Image(.copy)
                        .resizable()
                        .frame(width: 20,height: 20)
                    Text("copy_link_offer".localized())
                        .textModifier(.plain, 14, .black222222)
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: { copyCode() }, label: {
                            Text("code".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal,10)
                                .padding(.vertical,4)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black222222, lineWidth: 1)
                                )
                        })
                        Button(action: { copyURL() }, label: {
                            Text("link_offer".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal,10)
                                .padding(.vertical,4)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black222222, lineWidth: 1)
                                )
                        })
                    }
                }
                
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
                                .padding(.horizontal,10)
                                .padding(.vertical,4)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black222222, lineWidth: 1)
                                )
                        })
                        
                        Button(action: { shareURL() }, label: {
                            Text("link_offer".localized())
                                .textModifier(.plain, 14, .black222222)
                                .padding(.horizontal,10)
                                .padding(.vertical,4)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black222222, lineWidth: 1)
                                )
                        })
                    }
                }
                
                Button(action: { shareQRCode() }, label: {
                    HStack(spacing: 3) {
                        Image(.qrcodeShare)
                            .resizable()
                            .frame(width: 20,height: 20)
                        Text("code_offer".localized())
                            .textModifier(.plain, 14, .black222222)
                    }
                })
                
                // Delete Button
                Button(action: { onDelete() }, label: {
                    HStack(spacing: 3) {
                        Image(.trash)
                            .resizable()
                            .frame(width: 20,height: 20)
                        Text("delete".localized())
                            .textModifier(.plain, 14, .black222222)
                    }
                })
                Spacer()
            }
            Spacer()
        }
        .toastView(toast: $toast)
        .padding(.horizontal,30)
        .padding(.top ,52)
        .environment(\.layoutDirection, Constants.shared.isAR ?  .rightToLeft : .leftToRight)
        
    }
    private func copyURL() {
        if let _ = offer?.id, let offerCode = offer?.code {
            let urlString = "https://dafea.com.sa/offers/\(offerCode)"
            UIPasteboard.general.string = urlString
            self.toast = FancyToast(type: .info, title:"", message:  "copied successfully".localized())
        }
    }
    
    private func copyCode() {
        if let offerCode = offer?.code {
            UIPasteboard.general.string = offerCode
            self.toast = FancyToast(type: .info, title:"", message: "copied successfully".localized())
        }
    }
    
    private func shareCode() {
        if let _ = offer?.id, let offerCode = offer?.code {
            let urlString = offerCode
            
            let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
            
            // Ensure the activityViewController is presented on the main thread
            DispatchQueue.main.async {
                // Get the current view controller from the window scene
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    // Find the topmost presented view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }
                    
                    // Present the activityViewController from the topmost view controller
                    topViewController.present(activityViewController, animated: true, completion: nil)
                } else {
                    print("Root view controller is nil")
                }
            }
        } else {
            print("Failed to generate QR code image")
        }
    }
    
    private func shareURL() {
        if let _ = offer?.id, let offerCode = offer?.code {
            let urlString = "https://dafea.com.sa/offers/\(offerCode)"
            
            let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
            
            // Ensure the activityViewController is presented on the main thread
            DispatchQueue.main.async {
                // Get the current view controller from the window scene
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    // Find the topmost presented view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }
                    
                    // Present the activityViewController from the topmost view controller
                    topViewController.present(activityViewController, animated: true, completion: nil)
                } else {
                    print("Root view controller is nil")
                }
            }
        } else {
            print("Failed to generate QR code image")
        }
    }
    
    private func shareQRCode() {
        guard let offerCode = offer?.code else { return }
        
        // Generate QR Code
        let qrCodeImage = qrcodeImage(string: offerCode)
        
        // Convert UIImage to SwiftUI Image
        if let qrCodeImage = qrCodeImage {
            // Share the QR Code Image
            let activityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
            
            // Ensure the activityViewController is presented on the main thread
            DispatchQueue.main.async {
                // Get the current view controller from the window scene
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    // Find the topmost presented view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }
                    
                    // Present the activityViewController from the topmost view controller
                    topViewController.present(activityViewController, animated: true, completion: nil)
                } else {
                    print("Root view controller is nil")
                }
            }
        } else {
            print("Failed to generate QR code image")
        }
    }
}
