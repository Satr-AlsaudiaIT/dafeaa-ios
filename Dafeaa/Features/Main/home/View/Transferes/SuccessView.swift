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

    @State var phoneNumber: String = ""
    @State var date: String = ""
    @State var amount: String = "0"
    @State var name: String = ""
    @State var fees: String = "0"
    @State var total: Double = 0
    @State var referenceNum: String = ""
    @State var reason: String = ""
    @State var toast: FancyToast? = nil

    @State private var screenshotImage: UIImage? = nil
    @State private var showShareSheet: Bool = false
    @State private var hideView: Bool = false

    var body: some View {
        ZStack {
            VStack {
                NavigationBarView(title: "confirmTransfer") {
                    NavigationUtil.popToRootView()
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 24) {
                            VStack(spacing: 10) {
                                Image(.transferSuccess)

                                Text("transferSuccess".localized())
                                    .textModifier(.plain, 16, .black222222)

                                HStack {
                                    Text(amount).textModifier(.plain, 20, .black222222)
                                    Image(.riyal).resizable().aspectRatio(contentMode: .fit).foregroundColor(.black222222).frame(width: 20)
                                }
                                .environment(\.layoutDirection, .rightToLeft)

                                Text("noExtraFees".localized()).textModifier(.plain, 14, .black222222)
                            }

                            VStack(spacing: 24) {
                                infoRow(title: "phoneNumber", value: phoneNumber)
                                infoRow(title: "Name", value: name)
                                if !reason.isEmpty {
                                    infoRow(title: "transfer_reason", value: reason)
                                }
                                infoRow(title: "date", value: date.to12HourDateFormat() ?? "")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.grayBDBDBD, lineWidth: 1))
                            .background(Color.white)
                            .cornerRadius(8)

                            VStack {
                                Text("referenceNumber".localized()).textModifier(.plain, 16, .gray8B8C86)
                                HStack {
                                    Text(referenceNum).textModifier(.plain, 16, .gray8B8C86)
                                    Button {
                                        UIPasteboard.general.string = referenceNum
                                        toast = FancyToast(type: .info, title: "", message: "copied successfully".localized())
                                    } label: {
                                        Image(.transferCopy)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.grayBDBDBD, lineWidth: 1))
                            .background(.black000000.opacity(0.05))
                            .cornerRadius(8)
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(24)
                }

                if !hideView {
                    VStack(spacing: 12) {
                        ReusableButton(
                            buttonText: "Share".localized(),
                            isEnabled: true,
                            buttonColor: .transparent,
                            borderColor: .black222222,
                            textColor: .black222222
                        ) {
                            hideView = true
                        }

                        ReusableButton(buttonText: "O.K") {
                            Constants.shouldNavigateToWallet = true
                            Constants.lastPayoutStatus = "done"
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
        .onChange(of: hideView) { _, newValue in
            if newValue { takeScreenshot() }
        }
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
            Text(title.localized()).textModifier(.plain, 16, color)
            Spacer()
            HStack {
                Text(value).textModifier(.plain, 16, color)
                if isPrice {
                    Image(.riyal).resizable().aspectRatio(contentMode: .fit).foregroundColor(color).frame(width: 20)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func takeScreenshot() {
        guard let window = UIApplication.shared.windows.first else { return }
        let bounds = window.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { ctx in window.drawHierarchy(in: bounds, afterScreenUpdates: true) }
        screenshotImage = image
        hideView = false
        showShareSheet = true
    }
}

#Preview { SuccessView() }

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
