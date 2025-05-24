//
//  SuccessView.swift
//  Dafeaa
//
//  Created by AMNY on 28/04/2025.
//

import SwiftUI
import UIKit

struct SuccessView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    
    @State var phoneNumber: String = "59999999"
    @State var date: String = "2025-04-28 18:29:24"
    @State var amount: String = "0"
    @State var name = "A M"
    @State var fees: String = "0"
    @State var total: Double = 0
    @State var referenceNum: String = "sdfghjkjhgfcxcfgh"
    @State var toast: FancyToast? = nil
    
    @State private var screenshotImage: UIImage? = nil
    @State private var showShareSheet: Bool = false
    @State private var hideView : Bool = false
    var body: some View {
        ZStack {
            VStack {
                NavigationBarView(title: "confirmTransfer") {
                    NavigationUtil.popToRootView()
                }
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        
                        // Capture this VStack for screenshot
                        VStack(spacing: 24) {
                            
                            
                            VStack(spacing: 10) {
                                Image(.transferSuccess)
                                
                                Text("transferSuccess".localized())
                                    .textModifier(.plain, 16, .black222222)
                                HStack {
                                    Text(amount)
                                        .textModifier(.plain, 20, .black222222)
                                    Image(.riyal)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.black222222)
                                        .frame(width: 20)
                                }
                                .environment(\.layoutDirection, .rightToLeft)
                                Text("noExtraFees".localized())
                                    .textModifier(.plain, 14, .black222222)
                            }
                            
                            VStack(spacing: 24) {
                                infoRow(title: "phoneNumber", value: phoneNumber)
                                infoRow(title: "Name", value: name)
                                infoRow(title: "date", value: date.to12HourDateFormat() ?? "")
                            }
                            .padding(.horizontal,24)
                            .padding(.vertical,16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.grayBDBDBD, lineWidth: 1)
                            )
                            .background(Color.white)
                            .cornerRadius(8)
                            
                            VStack {
                                Text("referenceNumber".localized())
                                    .textModifier(.plain, 16, .gray8B8C86)
                                
                                HStack {
                                    Text(referenceNum)
                                        .textModifier(.plain, 16, .gray8B8C86)
                                    Button {
                                        UIPasteboard.general.string = referenceNum
                                        self.toast = FancyToast(type: .info, title:"", message: "copied successfully".localized())
                                    } label: {
                                        Image(.transferCopy)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal,24)
                            .padding(.vertical,16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.grayBDBDBD, lineWidth: 1)
                            )
                            .background(.black000000.opacity(0.05))
                            .cornerRadius(8)
                        }
                        
                        
                        Spacer(minLength: 120) // Push content up so buttons are lower
                    }
                    .padding(24)
                }
                if !hideView {
                    // Buttons
                    VStack(spacing: 12) {
                        ReusableButton(
                            buttonText: "Share",
                            isEnabled: true,
                            buttonColor: .transparent,
                            borderColor: .black222222,
                            textColor: .black222222
                        ) {
                            hideView = true
                        }
                        
                        ReusableButton(buttonText: "O.K") {
                            NavigationUtil.popToRootView()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)
        .toastView(toast: $toast)
        .onChange(of: hideView, { _, newValue in
            if newValue {
                takeScreenshot()
            }
        })
        
        .sheet(isPresented: $showShareSheet) {
            if let image = screenshotImage {
                ShareSheet(activityItems: [image])
            }
        }
        .onAppear {
            total = (Double(fees) ?? 0) + (Double(amount) ?? 0)
        }
    }
    
    private func infoRow(title: String, value: String, isPrice: Bool = false, color: Color = .gray8B8C86) -> some View {
        HStack {
            Text(title.localized())
                .textModifier(.plain, 16, color)
            Spacer()
            HStack {
                Text(value)
                    .textModifier(.plain, 16, color)
                if isPrice {
                    Image(.riyal)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color)
                        .frame(width: 20)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    private func takeScreenshot() {
        let window = UIApplication.shared.windows.first!
        let bounds = window.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { ctx in
            window.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        self.screenshotImage = image
        hideView = false
        self.showShareSheet = true
    }
}

#Preview {
    SuccessView()
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update anything here
    }
}
