//
//  HomeView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

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
    @State private var isGoingToOfferScreen: Bool = false
    @State private var isPresentBuySheet: Bool = false
    let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
    @State var showClientOfferDetails: Bool = false
    @State var showOfferDetails: Bool = false
    @State var offerData: ShowOfferData? = nil
    
    @StateObject var profileViewModel = MoreVM()

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
                                    Image(.notificationIcon)
                                }.navigationDestination(isPresented: $isNotificationPresented){ NotificationsView()}
                                
                            }
                            .padding(.horizontal,24)
                            .padding(.top,24)
                            
                            VStack {
                                HStack(spacing: 5) {
                                    Text(String(format: "%.1f",viewModel.homeData?.availableBalance ?? 0.0))
                                        .textModifier(.extraBold, 36, .black030319)
                                    Text("SAR".localized())
                                        .textModifier(.extraBold, 36, .black030319)
                                }
                                
                            }
                            .padding(.top,20)
                            Text("yourBalance".localized())
                                .textModifier(.extraBold, 16, .black222222)
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
                                Button {
                                    isPresentBuySheet = true
                                } label: {
                                    ZStack {
                                        HStack {
                                            Text("buy_product".localized())
                                                .textModifier(.extraBold, 16, .black222222)
                                            Spacer()
                                            Image(.buyProduct)
                                                .resizable()
                                                .frame(width: 28.05, height: 28)
                                        }
                                        .padding()
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 40)
                                    .fixedSize()
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(LinearGradient(colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                                        }
                                    )
                                    .background(
                                          RoundedRectangle(cornerRadius: 10)
                                              .fill(Color.white)
                                              .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                      )
                                }

                                
                                Button {
                                    isGoingToOfferScreen = true
                                } label: {
                                    ZStack {
                                        HStack {
                                            Text("sell_product".localized())
                                                .textModifier(.extraBold, 16, .black222222)
                                            Spacer()
                                            Image(.sellProduct)
                                                .resizable()
                                                .frame(width: 28.05, height: 28)
                                        }
                                        .padding()
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 40)
                                    .fixedSize()
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(LinearGradient(colors: [.primaryF9CE29, .primaryF9CE29.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                                        }
                                    )
                                    .background(
                                          RoundedRectangle(cornerRadius: 10)
                                              .fill(Color.white)
                                              .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                      )
                                }
                                
                                Spacer()
//                                LastProcessNavView(title: "lastProcesses".localized(), selectedTab: $selectedTab)
//                                    .padding(.horizontal,24)
//
//                                if viewModel.processList.isEmpty {
//                                    EmptyCostumeView()
//                                }else {
//                                    ScrollView (showsIndicators: false){
//                                        VStack(spacing: 8) {
//                                            ForEach(0..<viewModel.processList.count,id: \.self){ index in
//                                                ProcessComponent(process: viewModel.processList[index])
//                                            }
//                                        }
//                                    }
//                                    .padding(.horizontal,24)
//                                }
                            }
                        }
                        .cornerRadius(24)
                        .padding(.bottom,-24)
                        
                        //MARK: - Wallet View
                        VStack {
                            ZStack {
                                Color(.white)
                                HStack {
                                    HStack {
                                        WalletButton(buttonText: "addBalance".localized(),image: .addBalance) {
                                            balanceActionType = .addBalance
                                            isSheetPresented = true
                                            
                                        }
                                        
                                    }
                                    Spacer()
                                    Rectangle()
                                        .fill(.black.opacity(0.1))
                                        .frame(width: 2,height: 24)
                                    
                                    Spacer()
                                    HStack {
                                        WalletButton(buttonText: "withdrawBalance".localized(), image: .withdrawBalance) {
                                            balanceActionType = .withDraw
                                            isSheetPresented = true
                                        }
                                        
                                    }
                                    
                                }
                                .padding(.horizontal,24)
                            }
                            
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .cornerRadius(16)
                            .padding(.horizontal,24)
                            .shadow(color: Color(.dropShadow2B2D3333).opacity(0.2), radius: 5, x: 0, y: 6)
                            
                            
                            
                        }.padding(.top,-39)
                    }
                }.edgesIgnoringSafeArea(.top)
            }
            .toastView(toast: $viewModel.toast)
            .onAppear{
                isViewAppeared = true
            }
            .onChange(of: isViewAppeared, { _, newValue in
                if newValue {
                    viewModel.home()
                    if userId == 0 {
                        profileViewModel.profile()
                    }
                }
            })
            .onDisappear{
                isViewAppeared = false
            }
            .refreshable {
                viewModel.home()
            }
            .navigationDestination(isPresented: $showOfferDetails, destination: {
                OrderLinkDetailsView(offerData: offerData)
            })
            .navigationDestination(isPresented: $showClientOfferDetails, destination: {
                ClientLinkDetails(offerData: offerData)
            })
            .sheet(isPresented: $isPresentBuySheet, content: {
                BuyProductBottomSheet(isShowClientLinkDetails: $showClientOfferDetails, isShowOrderLinkDetails: $showOfferDetails, offerData: $offerData,isSheetPresented: $isPresentBuySheet)
                    .presentationDetents([.fraction(0.6)]) // Use fraction to make height consistent
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $isSheetPresented, content: {
                AddWithdrawBottomSheet(actionType: $balanceActionType, amountDouble: $amount, isSheetPresented: $isSheetPresented,navigateToWebView: $navigateToWebView,paymentURL: $paymentURL)
                    .presentationDetents([.fraction(0.6)]) // Use fraction to make height consistent
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
            })
            .navigationDestination(isPresented: $isGoingToOfferScreen, destination: {
                OrdersOffersLinksView()
            })
            .navigationDestination(isPresented: $navigateToWebView) {
                PaymentWebViewContainer(url: paymentURL)
            }
        }
    }
}
#Preview {
    HomeView(selectedTab: .constant(.home))
}


struct LastProcessNavView: View {
    var title    : String
    @Binding var selectedTab: TabBarView.Tab   // Optional selectedTab
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
                    selectedTab = .processes
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

