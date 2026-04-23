//
//  FailedView.swift
//  Dafeaa
//
//  Created by AMNY on 28/04/2025.
//

import SwiftUI

struct FailedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = HomeVM()

    @State var phoneNumber: String = ""
    @State var date: String = ""
    @State var amount: String = "0"
    @State var name: String = ""
    @State var fees: String = "0"
    @State var total: Double = 0
    @State var referenceNum: String = ""
    @State var reason: String = ""
    @State var statusChangedToSuccess: Bool = false
    @State var toast: FancyToast? = nil

    var body: some View {
        ZStack {
            VStack {
                NavigationBarView(title: "confirmTransfer") {
                    if statusChangedToSuccess { NavigationUtil.popToRootView() }
                    else { presentationMode.wrappedValue.dismiss() }
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 10) {
                            Image(statusChangedToSuccess ? .transferSuccess : .transferFailed)

                            Text(statusChangedToSuccess ? "transferSuccess".localized() : "transferFailed".localized())
                                .textModifier(.plain, 16, .black222222)

                            HStack {
                                Text(amount).textModifier(.plain, 20, .black222222)
                                Image(.riyal).resizable().aspectRatio(contentMode: .fit).foregroundColor(.black222222).frame(width: 20)
                            }
                            .environment(\.layoutDirection, .rightToLeft)

                            Text("noExtraFees".localized()).textModifier(.plain, 14, .black222222)
                        }

                        VStack(spacing: 24) {
                            infoRow(title: "Phone Number", value: phoneNumber)
                            infoRow(title: "Name", value: name)
                            if !reason.isEmpty {
                                infoRow(title: "transfer_reason", value: reason)
                            }
                            infoRow(title: "Date", value: date)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.grayBDBDBD, lineWidth: 1))
                        .padding(1)
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
                        .padding(1)
                        .background(.black000000.opacity(0.05))
                        .cornerRadius(8)

                        Spacer()
                    }
                    .padding(24)
                }

                VStack(spacing: 12) {
                    ReusableButton(
                        buttonText: "Try Again",
                        isEnabled: true,
                        buttonColor: .transparent,
                        borderColor: .black222222,
                        textColor: .black222222
                    ) {
                        viewModel.confirmTransfer(
                            phone: phoneNumber.normalizePhoneNumber,
                            amount: Double(amount) ?? 0,
                            reason: reason
                        )
                    }

                    ReusableButton(buttonText: "O.K") {
                        if statusChangedToSuccess { NavigationUtil.popToRootView() }
                        else { presentationMode.wrappedValue.dismiss() }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .onChange(of: viewModel.isTransferSuccess) { _, newValue in
                    if newValue { statusChangedToSuccess = true }
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
}

#Preview { FailedView() }
