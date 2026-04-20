//
//  HomeView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI
import AVFoundation
import LocalAuthentication

struct HomeView: View {
    @StateObject var viewModel = HomeVM()
    @Binding var selectedTab : TabBarView.Tab
    @State var isSheetPresented: Bool = false
    @State var isNotificationPresented: Bool = false
    @State var navigateToWebView : Bool = false
    @State var paymentURL : String = ""
    @State var amount:Double = 0.0
    @State private var balanceActionType : bottomSheetAction?
    @State private var isViewAppeared: Bool = false
    //    @State private var isGoingToOfferScreen: Bool = false
    @State private var isPresentBuySheet: Bool = false
    let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
    let businessInformationStatus = GenericUserDefault.shared.getValue(Constants.shared.businessInformationStatus) as? Int ?? nil
    @State var unreadCount: Int = 0
    @State var unReadNotificationCount: String  = UserDefaults.standard.value(forKey: Constants.shared.unReadNotificationCount) as? String ?? ""
    @State var showClientOfferDetails: Bool = false
    @State var showOfferDetails: Bool = false
    @State var offerData: ShowOfferData? = nil
    @State private var businessInfo: BusinessInfo = .noFilesUploaded
    @State private var showCompleteDataPopup: Bool = false
    @State private var navigateToPendingView: Bool = false
    @State private var navigateToOffers: Bool = false
    @StateObject var profileViewModel = MoreVM()
    @State private var navigateToCompleteProfileView: Bool = false
    @State var showTransferBottomSheet : Bool = false
    @State var isNavigateToTransferView : Bool = false
    @State var transferBalancePhone : String = ""
    @State var transferBalanceName : String = ""
    @State var navigateToWithDrawView: Bool = false
    @State var navigateToAddBalance: Bool = false

    @State var transferBalanceAmount : String = ""
    @State var showTransferMethodSheet: Bool = false
    @State var navigateToIBANTransfer: Bool = false
    @State var navigateToPhoneTransfer: Bool = false

    @State private var isShowingQRPaymentSheet: Bool = false
    @State private var sliderImages: [String] = [(Constants.shared.isAR ? "Ar1":"En1"), (Constants.shared.isAR ? "Ar2":"En2")]
    @State private var isHiddenPageIndicator: Bool = false
    @State private var isWebImage: Bool = false
    @State private var isIndicatorSeparated: Bool = true
    @State private var showQRDeeplinkSheet: Bool = false
    @State private var pendingDeeplinkQRCode: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: - upperView
                VStack {
                    ZStack(alignment: .top) {
                        LinearGradient(
                            gradient: Gradient(colors: [.white, Color(.primary)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                        .edgesIgnoringSafeArea(.top)
                        VStack(spacing: 8) {
                            HStack {
                                Image(.splashLogoWithoutName)
                                    .resizable()
                                    .frame(width: 27.23,height: 32)
                                Spacer()
                                Image(.logoName)
                                Spacer()
                                Button {
                                    isNotificationPresented = true
                                } label: {
                                    ZStack {
                                        Image(.notificationIcon)
                                        
                                        if unreadCount > 0 {
                                            VStack {
                                                HStack {
                                                    Spacer()
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.red)
                                                            .frame(width: 20, height: 20)
                                                        
                                                        Text("\(unreadCount > 99 ? "99+" : "\(unreadCount)")")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.white)
                                                            .fontWeight(.bold)
                                                    }
                                                    .offset(x: 8, y: -8)
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .fixedSize()
                                }.navigationDestination(isPresented: $isNotificationPresented){ NotificationsView(selectedTab: $selectedTab)}
                                
                            }
                            .padding(.horizontal,24)
                            .padding(.top,24)
                            
                            VStack {
                                HStack(spacing: 5) {
                                    Text(String(format: "%.1f",viewModel.walletAmount))
                                        .textModifier(.plain, 36, .black030319)
                                    Image(.riyal)
                                         .resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .foregroundColor(.black010202)
                                         .frame(width: 30)
                                         .padding(.trailing, 10)
                                }
                                .environment(\.layoutDirection, .rightToLeft)
                            }
                            .padding(.top,20)
                            Text("yourBalance".localized())
                                .textModifier(.plain, 16, .black222222)
                        }
                        
                    }
                    Spacer()
                }
                
                //MARK: - lowerView
                VStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: UIScreen.main.bounds.height * 0.4 - 39)
                    ZStack(alignment: .top) {
                        
                        

                        ZStack {
                            Color(.white)
    
                            VStack(spacing: 17) {
                                Rectangle().fill(.white)
                                    .frame(height: 32)
                                
                                ScrollView(showsIndicators: false) {
                                    
                                    VStack(spacing: 16) {
                                        
                                        Button {
                                            isShowingQRPaymentSheet = true
                                        } label: {
                                            HStack(spacing: 12) {
                                                Spacer()
                                                Image(.qrPrimary) //
                                                    .resizable()
                                                    .frame(width: 28, height: 28)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("quick_payment".localized())
                                                        .textModifier(.bold, 16, .black000000)
                                                    Text("scan_qr_desc".localized())
                                                        .textModifier(.bold, 10, .gray979797)
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical,9)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.primaryF9CE29, lineWidth: 1)
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.primaryF9CE29.opacity(0.1))
                                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 6)
                                            )
                                        }  .padding(.horizontal, 20)
                                            .frame(height:60)
                                        HStack(spacing:15) {
                                            Button {
                                                isPresentBuySheet = true
                                            } label: {
                                                ZStack {
                                                    HStack(spacing: 5) {
                                                        Spacer(minLength: 2)
                                                        Text("buy_product".localized())
                                                            .textModifier(.plain, 16, .black222222)
                                                        Image(.buyProduct)
                                                            .resizable()
                                                            .frame(width: 28.05, height: 28)
                                                        Spacer(minLength: 2)
                                                        
                                                    }
                                                    .padding(.vertical,15)
                                                }
                                                .overlay(
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(LinearGradient(colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                                                    }
                                                )
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.white)
                                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                                )
                                            }.frame(height:60)
                                            Button {
                                                if businessInfo.rawValue == 0 {
                                                    showCompleteDataPopup = true
                                                }
                                                else if businessInfo.rawValue == 1 {
                                                    navigateToPendingView = true
                                                }
                                                else {
                                                    navigateToOffers = true
                                                }
                                            } label: {
                                                ZStack {
                                                    HStack(spacing: 5) {
                                                        Spacer(minLength: 2)
                                                        Text("sell_product".localized())
                                                            .textModifier(.plain, 16, .black222222)
                                                            .minimumScaleFactor(0.95)
                                                        Image(.sellProduct)
                                                            .resizable()
                                                            .frame(width: 28.05, height: 28)
                                                        Spacer(minLength: 2)
                                                    }
                                                    .padding(.vertical,15)
                                                    
                                                }
                                                .overlay(
                                                    ZStack {
                                                        
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(LinearGradient(colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                                                    }
                                                )
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.white)
                                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                                )
                                            }
                                            .frame(height:60)
                                        }
                                        .padding(.horizontal, 19)
                                        SliderView(
                                            images: $sliderImages,
                                            isHiddenPageIndicator: $isHiddenPageIndicator,
                                            isWebImage: $isWebImage,
                                            isIndicatorSeparated: $isIndicatorSeparated,
                                            widthFraction: 0.9 )
                                        
                                        .padding(.vertical,16)
                                        .padding(.bottom,20)
                                        .cornerRadius(12)
                                        //.allowsHitTesting(false)
                                        
                                        
                                        //                                    HStack(spacing: 12) {
                                        //                                        // Buy Product
                                        //                                        Button {
                                        //                                            isPresentBuySheet = true
                                        //                                        } label: {
                                        //                                            HStack {
                                        //                                                Text("buy_product".localized())
                                        //                                                    .textModifier(.plain, 16, .black222222)
                                        //                                                Spacer()
                                        //                                                Image(.buyProduct)
                                        //                                                    .resizable()
                                        //                                                    .frame(width: 28, height: 28)
                                        //                                            }
                                        //                                            .padding(15)
                                        //                                            .overlay(
                                        //                                                RoundedRectangle(cornerRadius: 10)
                                        //                                                    .stroke(LinearGradient(
                                        //                                                        colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)],
                                        //                                                        startPoint: .top,
                                        //                                                        endPoint: .bottom
                                        //                                                    ), lineWidth: 1)
                                        //                                            )
                                        //                                            .background(
                                        //                                                RoundedRectangle(cornerRadius: 10)
                                        //                                                    .fill(Color.white)
                                        //                                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        //                                            )
                                        //                                        }
                                        //
                                        //                                        // Sell Product
                                        //                                        Button {
                                        //                                            if businessInfo.rawValue == 0 {
                                        //                                                showCompleteDataPopup = true
                                        //                                            } else if businessInfo.rawValue == 1 {
                                        //                                                navigateToPendingView = true
                                        //                                            } else {
                                        //                                                navigateToOffers = true
                                        //                                            }
                                        //                                        } label: {
                                        //                                            HStack {
                                        //                                                Text("sell_product".localized())
                                        //                                                    .textModifier(.plain, 16, .black222222)
                                        //                                                    .lineLimit(nil)
                                        //                                                Spacer()
                                        //                                                Image(.sellProduct)
                                        //                                                    .resizable()
                                        //                                                    .frame(width: 28, height: 28)
                                        //                                            }
                                        //                                            .padding(15)
                                        //                                            .overlay(
                                        //                                                RoundedRectangle(cornerRadius: 10)
                                        //                                                    .stroke(LinearGradient(
                                        //                                                        colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)],
                                        //                                                        startPoint: .top,
                                        //                                                        endPoint: .bottom
                                        //                                                    ), lineWidth: 1)
                                        //                                            )
                                        //                                            .background(
                                        //                                                RoundedRectangle(cornerRadius: 10)
                                        //                                                    .fill(Color.white)
                                        //                                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        //                                            )
                                        //                                        }
                                        //                                    }
                                    }
                                    .padding(.top, 15)
                                }

                                Spacer()
                            }
                        }
                        .cornerRadius(24)
                        .padding(.bottom, -24)

                        // MARK: - Wallet View
                        VStack {
                            ZStack {
                                Color(.white)
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
                                .padding(.vertical, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                            .shadow(color: Color(.dropShadow2B2D3333).opacity(0.2), radius: 5, x: 0, y: 6)
                        }
                        .padding(.top, -39)
                    }
                }
                .edgesIgnoringSafeArea(.top)

                // MARK: - Complete Data Popup
                if showCompleteDataPopup {
                    ZStack {
                        Color.black.opacity(0.2)
                        VStack {
                            Spacer()
                           
                                ZStack {
                                    Color(.white)
                                    VStack (spacing: 20){
                                        HStack {
                                            Text("merchants_service_title".localized())
                                                .textModifier(.plain, 16, .gray666666)
                                            Spacer()
                                        }
                                        .padding(.top)
                                        Text("merchants_service_body".localized())
                                            .textModifier(.plain, 14, .gray666666)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                        HStack {
                                            Spacer()
                                            Button {
                                                showCompleteDataPopup = false
                                            } label: {
                                                Text ("Cancel".localized())
                                                    .textModifier(.plain, 14, .gray666666)
                                            }
                                            .padding(.trailing, 20)
                                            Button {
                                                navigateToCompleteProfileView = true
                                                showCompleteDataPopup = false
                                            } label: {
                                                Text ("add_data_button".localized())
                                                    .textModifier(.plain, 14, .primaryF9CE29)
                                            }
                                        }
                                    }
                                    .padding(20)
                                }
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .cornerRadius(15)
                                .fixedSize()
                                
                            
                            Spacer()
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showCompleteDataPopup = false
                    }
                }

            }
            
            .toastView(toast: $viewModel.toast)
            .onAppear{
                isViewAppeared = true
                businessInfo = BusinessInfo(rawValue: self.businessInformationStatus ?? 0) ?? .noFilesUploaded
                if !Constants.sessionFlag {
                    profileViewModel.addressesList(isLoading: false)
                    Constants.sessionFlag = true
                }
                unReadNotificationCount = UserDefaults.standard.value(forKey: Constants.shared.unReadNotificationCount) as? String ?? ""
                unreadCount = ((unReadNotificationCount == "" || unReadNotificationCount == "0") ? 0 : Int(unReadNotificationCount)) ?? 0
                handleQRCodeIfNeeded()
            }
            .onChange(of: isViewAppeared, { _, newValue in
                if newValue {
                    viewModel.home()
                    profileViewModel.profile()
                    
                }
            })
            .navigationDestination(isPresented: $navigateToCompleteProfileView, destination: {
                CompleteDataView(phone:Constants.phone)
            })
            
            .onChange(of: profileViewModel.profileData, { oldValue, newValue in
                businessInfo = BusinessInfo(rawValue: profileViewModel.profileData?.businessInformationStatus ?? 0) ?? .noFilesUploaded
            })
            .onDisappear{
                isViewAppeared = false
            }
            .refreshable {
                viewModel.home()
            }
            .navigationDestination(isPresented: $navigateToPendingView) {
                PendingView()
            }
            .navigationDestination(isPresented: $navigateToOffers, destination: {
                OrdersOffersLinksView()
            })
            .navigationDestination(isPresented: $showOfferDetails, destination: {
                OrderLinkDetailsViewNew(offerData: offerData)
            })
            .navigationDestination(isPresented: $showClientOfferDetails, destination: {
                ClientLinkDetailsNew(offerData: offerData)
            })
            
            .appBottomSheet(isPresented: $isShowingQRPaymentSheet, detents: [.fraction(0.85)]) {
                          QRPaymentBottomSheet(
                              isPresented: $isShowingQRPaymentSheet,
                              onNavigateToWallet: {
                                  selectedTab = .wallet
                              }
                          )
                      }
            .appBottomSheet(isPresented: $showQRDeeplinkSheet, detents: [.fraction(0.55)]) {
                QRDeeplinkBottomSheet(
                    isPresented: $showQRDeeplinkSheet,
                    qrCode: $pendingDeeplinkQRCode,
                    onSuccess: {
                        selectedTab = .wallet
                    }
                )
            }
            .appBottomSheet(isPresented: $isPresentBuySheet, detents: [.fraction(0.45)]) {
                BuyProductBottomSheet(isShowClientLinkDetails: $showClientOfferDetails, isShowOrderLinkDetails: $showOfferDetails, offerData: $offerData,isSheetPresented: $isPresentBuySheet)
            }
            .appBottomSheet(isPresented: $isSheetPresented, detents: [.fraction(0.45)]) {
                AddWithdrawBottomSheet(actionType: $balanceActionType, amountDouble: $amount, isSheetPresented: $isSheetPresented,navigateToWebView: $navigateToWebView,paymentURL: $paymentURL, navigateToWithDrawView: $navigateToWithDrawView, navigateToAddBalance: $navigateToAddBalance)
                
            }
//            .sheet(isPresented: $showTransferBottomSheet, content: {
//                TransferBottomSheet(isSheetPresented: $showTransferBottomSheet,amount: $transferBalanceAmount,phoneNumber: $transferBalancePhone, name: $transferBalanceName,isNavigateToTransferView: $isNavigateToTransferView)
//                    .presentationDetents([.fraction(0.4)])
//                    .presentationCornerRadius(24)
//                    .presentationDragIndicator(.visible)
//                    .onAppear{
//                        transferBalancePhone = ""
//                        transferBalanceAmount = ""
//                        transferBalanceName = ""
//                    }
//            })
//            .navigationDestination(isPresented: $isNavigateToTransferView, destination: {
//                ConfirmTransferView( balance: String(viewModel.walletAmount),phoneNumber: transferBalancePhone, amount: transferBalanceAmount, name: transferBalanceName)
//            })
            .navigationDestination(isPresented: $navigateToWebView) {
                PaymentWebViewContainer(url: paymentURL)
            }
//            .navigationDestination(isPresented: $navigateToWithDrawView) {
//                WithdrawDetailsView(
//                    withdrawAmount: amount
//                )
//            }
            .navigationDestination(isPresented: $navigateToAddBalance) {
                AddBalanceCardDetailsView(
                    addAmount: amount
                )
            }
            .appBottomSheet(isPresented: $showTransferMethodSheet, detents: [.fraction(0.45)]) {
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
}

/// MARK: - QR Deeplink Handling
extension HomeView {
    private func handleQRCodeIfNeeded() {
        let qrCode = Constants.quickQrCode
        guard !qrCode.isEmpty else { return }
        authenticateWithBiometrics(qrCode: qrCode)
    }

    private func authenticateWithBiometrics(qrCode: String) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authenticateWithPasscode(qrCode: qrCode)
            return
        }
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "confirm_payment_biometric".localized()
        ) { success, authError in
            DispatchQueue.main.async {
                if success {
                    Constants.quickQrCode = ""
                    pendingDeeplinkQRCode = qrCode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showQRDeeplinkSheet = true
                    }
                } else if let err = authError as? LAError, err.code == .biometryLockout {
                    authenticateWithPasscode(qrCode: qrCode)
                }
            }
        }
    }

    private func authenticateWithPasscode(qrCode: String) {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "confirm_payment_biometric".localized()
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    Constants.quickQrCode = ""
                    pendingDeeplinkQRCode = qrCode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showQRDeeplinkSheet = true
                    }
                }
            }
        }
    }
}
// MARK: - Previews
#Preview {
    HomeView(selectedTab: .constant(.home))
}


struct LastProcessNavView: View {
    var title    : String
    @Binding var selectedTab: TabBarView.Tab
    var isShow   : Bool = true
    var body: some View {
        HStack{
            Image(.doubleArrow)
            Text(title)
                .textModifier(.plain, 18, .black1E1E1E
                )
            Spacer()
            if  isShow {
                Button {
//                    selectedTab = .processes
                } label: {
                    Image(.leftArrow)
                    
                }
            }
            
        }
    }
}

struct EmptyCostumeView: View {
    var message  : String = "thereIsNoData".localized()
    var body: some View {
        VStack{
            Spacer()
            Image(.empty).resizable()
                .frame(width: 147, height:  132)
            Text(message)
                .textModifier(.plain, 14, .gray919191 )
            Spacer()
            
        }
    }
}

