//
//  TabBarView.swift
//  Dafeaa
//
//  Created by AMNY on 11/10/2024.
//

import SwiftUI

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .home
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    
    enum Tab {
        case home, wallet, myOrders, processes, profile
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(selectedTab == .home ? .homeFill:.home)
                                
                            Text("home".localized())
                                .textModifier(.bold,12, selectedTab == .home ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.home)
                    
                    WalletView( selectedTab: $selectedTab)
                        .tabItem {
                            Image(selectedTab == .wallet ? .walletFill:.wallet)
                               
                            Text("wallet".localized())
                                .textModifier(.bold,12, selectedTab == .wallet ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.wallet)
                    
                    MyOrdersView()
                        .tabItem {
                            Image(selectedTab == .myOrders ? .bagFill : .bag)
                                
                            Text(userType == 1 ? "myOrders".localized() : "orders".localized())
                                .textModifier(.bold,12, selectedTab == .myOrders ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.myOrders)
                    
                    ProcessesView()
                        .tabItem {
                            Image(selectedTab == .processes ? .receiptFill : .receipt)
                                
                            Text("processes".localized())
                                .textModifier(.bold,12, selectedTab == .processes ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.processes)
                    
                    ProfileView()
                        .tabItem {
                            Image(selectedTab == .profile ? .profileFill : .profile)
                                
                            Text("profile".localized())
                                .textModifier(.bold,12, selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.profile)
                }
                .accentColor(Color(.primary))

      
            }
        }
        .navigationBarHidden(true)
    }
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
