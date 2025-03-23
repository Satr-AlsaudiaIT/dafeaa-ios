//
//  TabBarView.swift
//  Dafeaa
//
//  Created by AMNY on 11/10/2024.
//

import SwiftUI

//
//  TabBarView.swift
//  Dafeaa
//
//  Created by AMNY on 11/10/2024.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @EnvironmentObject var navigationHelper: NavigationHelper

    enum Tab: CaseIterable {
        case home, wallet, myOrders, profile

        var icon: Image {
            switch self {
            case .home:
                return Image(.home)
            case .wallet:
                return Image(.wallet)
            case .myOrders:
                return Image(.bag)
            case .profile:
                return Image(.profile)
            }
        }

        var selectedIcon: Image {
            switch self {
            case .home:
                return Image(.homeFill)
            case .wallet:
                return Image(.walletFill)
            case .myOrders:
                return Image(.bagFill)
            case .profile:
                return Image(.profileFill)
            }
        }

        func title(userType: Int) -> String {
            switch self {
            case .home:
                return "home".localized()
            case .wallet:
                return "wallet".localized()
            case .myOrders:
                return userType == 1 ? "myOrders".localized() : "orders".localized()
            case .profile:
                return "profile".localized()
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main content view based on the selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                            .padding(.bottom,80)
                    case .wallet:
                        WalletView(selectedTab: $selectedTab)
                            .padding(.bottom,80)
                    case .myOrders:
                        MyOrdersView()
                            .padding(.bottom,80)
                    case .profile:
                        ProfileView()
                            .padding(.bottom,80)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab, userType: userType)

            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationDestination(isPresented: $navigationHelper.navigateToClientOrder) {
                OrderClientDetailsView(orderID: navigationHelper.actionId)
            }
            .navigationDestination(isPresented: $navigationHelper.navigateToMerchentOrder) {
                OrderBusinessDetailsView(orderID: navigationHelper.actionId)
            }
            .navigationDestination(isPresented: $navigationHelper.navigateToWithdraws) {
                WithdrawsView(heighlightedId: navigationHelper.actionId)
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: TabBarView.Tab
    let userType: Int

    var body: some View {
        HStack {
            ForEach(TabBarView.Tab.allCases, id: \.self) { tab in
                Spacer()

                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        if selectedTab == tab {
                            tab.selectedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        } else {
                            tab.icon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }

                        Text(tab.title(userType: userType)) // Pass userType here
                            .font(.custom("BahijTheSansArabicPlain", size: 12)) // Apply custom font
                            .foregroundColor(selectedTab == tab ? .primaryF9CE29 : .gray)
                    }
                    .padding(.bottom,20)
                }

                Spacer()
            }
            
        }
        .padding(.top, 15)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft,.topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -1)
    }
}

#Preview {
    TabBarView()
}
extension UITabBarController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 16
        // Choose with corners should be rounded
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top left, top right
        
        // Uses `accessibilityIdentifier` in order to retrieve shadow view if already added
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow"
            shadowView.backgroundColor = UIColor.white
            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = Color.gray.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
            shadowView.layer.shadowOpacity = 0.1
            shadowView.layer.shadowRadius = 2
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
}
