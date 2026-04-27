//
//  WalletView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct WalletView: View {
    @StateObject var viewModel = WalletVM()
    @Binding var selectedTab : TabBarView.Tab
    @State var isSheetPresented: Bool = false
    @State var amount:Double = 0.0
    @State private var balanceActionType : bottomSheetAction?
    @State var navigateToWebView : Bool = false
    @State var paymentURL : String = ""
    @State private var isViewAppeared: Bool = false
    @State var navigateToWithDrawView: Bool = false
    @State var navigateToAddBalance: Bool = false
    @State private var popupMessage: PopupMessage? = nil
    @State var transferBalanceAmount : String = ""
    @State var showTransferMethodSheet: Bool = false
    @State var navigateToIBANTransfer: Bool = false
    @State var navigateToPhoneTransfer: Bool = false

    var body: some View {
        NavigationStack {
            //MARK: - upperView
            ZStack {
                VStack(spacing: 0) {
                    NavigationBarView(title: "wallet".localized())
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("yourBalance".localized())
                                .textModifier(.extraBold, 16, .black222222)
                            
                            HStack(spacing: 5) {
                                Text(String(format: "%.1f", viewModel.walletData?.availableBalance ?? 0))
                                    .textModifier(.extraBold, 36, .black030319)
                                Image(.riyal)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black010202)
                                    .frame(width: 30)
                                    .padding(.trailing, 10)
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }

                        //MARK: - Wallet Buttons
                        ZStack {
                            Color.white
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.black.opacity(0.1), lineWidth: 0.5)
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.white, lineWidth: 2)
                                .frame(height: 72/1.5)
                                .padding(.bottom, 24)
                            HStack {
                                WalletButton(buttonText: "transferBalance".localized(), image: .transferBalance) {
                                    showTransferMethodSheet = true
                                }
                                Spacer()
                                Rectangle()
                                    .fill(.black.opacity(0.1))
                                    .frame(width: 2, height: 24)
                                Spacer()
                                WalletButton(buttonText: "addBalance".localized(), image: .addBalance) {
                                    balanceActionType = .addBalance
                                    isSheetPresented = true
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .cornerRadius(16)
                        .shadow(color: Color(.black).opacity(0.06), radius: 16, x: 12, y: 12)
                        
                        //MARK: - Transactions List
                        VStack(spacing: 17) {
                            if viewModel.processList.isEmpty {
                                EmptyCostumeView()
                            } else {
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 17) {
                                        LazyVStack(spacing: 8) {
                                            ForEach(0..<viewModel.processList.count, id: \.self) { index in
                                                ProcessComponent(process: viewModel.processList[index])
                                                    .onAppear {
                                                        if index == viewModel.processList.count - 1 {
                                                            loadMoreOrdersIfNeeded()
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                                .refreshable {
                                    viewModel.wallet(skip: 0, animated: false)
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing, .top], 24)
                    .padding(.bottom, 2)
                }

                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView().hidden()
                }
            }
            .customBottomSheet(isPresented: $isSheetPresented, detents: [.fraction(0.45)]) {
                AddWithdrawBottomSheet(
                    actionType: $balanceActionType,
                    amountDouble: $amount,
                    isSheetPresented: $isSheetPresented,
                    navigateToWebView: $navigateToWebView,
                    paymentURL: $paymentURL,
                    navigateToWithDrawView: $navigateToWithDrawView,
                    navigateToAddBalance: $navigateToAddBalance
                )
            }


            .toastView(toast: $viewModel.toast)
            .popupView(popup: $popupMessage)
            .navigationBarHidden(true)
            .onAppear {
//                isViewAppeared = true
                viewModel.wallet(skip: 0)
                checkPaymentStatus()
            }
            .onDisappear {
                isViewAppeared = false
            }
//            .onChange(of: isViewAppeared) { _, newValue in
//                if newValue {
//                    viewModel.wallet(skip: 0)
//                }
//            }

            .navigationDestination(isPresented: $navigateToWebView) {
                PaymentWebViewContainer(url: paymentURL)
            }
            .navigationDestination(isPresented: $navigateToWithDrawView) {
                WithdrawDetailsView()
            }
            .navigationDestination(isPresented: $navigateToAddBalance) {
                AddBalanceCardDetailsView(addAmount: amount)
            }
            .customBottomSheet(isPresented: $showTransferMethodSheet, detents: [.fraction(0.45)]) {
                TransferMethodBottomSheet(
                    isSheetPresented: $showTransferMethodSheet,
                    navigateToIBANTransfer: $navigateToIBANTransfer,
                    navigateToPhoneTransfer: $navigateToPhoneTransfer
                )
            }

            .navigationDestination(isPresented: $navigateToIBANTransfer) {
                WithdrawDetailsView()
            }

            .navigationDestination(isPresented: $navigateToPhoneTransfer) {
                EnterPhoneTransferDetailsView(phoneNumber: "")

            }
        }
    }
    
    // MARK: - Private Methods

    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.wallet(skip: viewModel.processList.count)
        }
    }
    
    private func checkPaymentStatus() {
        if Constants.shouldNavigateToWallet {
            let status = Constants.lastPaymentStatus
            let payOutStatus = Constants.lastPayoutStatus
            
            if status.lowercased() == "paid" {
                popupMessage = PopupMessage(
                    type: .success,
                    title: "Success".localized(),
                    message: "The balance has been successfully recharged.".localized()
                )
            } else if status.lowercased() == "failed" {
                popupMessage = PopupMessage(
                    type: .failure,
                    title: "Failed".localized(),
                    message: "Payment failed. Please try again.".localized()
                )
            } else if payOutStatus == "done" {
                popupMessage = PopupMessage(
                    type: .success,
                    title: "Success".localized(),
                    message: "The balance has been successfully withdrawn.".localized()
                )
            }
            
            Constants.shouldNavigateToWallet = false
            Constants.lastPaymentStatus = ""
            Constants.lastPayoutStatus = ""
            viewModel.wallet(skip: 0)
        }
    }
    

}

#Preview {
    WalletView(selectedTab: .constant(.home))
}
