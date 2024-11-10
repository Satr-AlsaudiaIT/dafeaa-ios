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
                            Image(.home)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                            Text("home".localized())
                                .textModifier(.bold,12, selectedTab == .home ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.home)
                    
                    WalletView()
                        .tabItem {
                            Image(.wallet)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                            Text("wallet".localized())
                                .textModifier(.bold,12, selectedTab == .wallet ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.wallet)
                    
                    MyOrdersView()
                        .tabItem {
                            Image(.bag)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                            Text(userType == 1 ? "myOrders".localized() : "orders".localized())
                                .textModifier(.bold,12, selectedTab == .myOrders ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.myOrders)
                    
                    ProcessesView()
                        .tabItem {
                            Image(.receipt)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                            Text("processes".localized())
                                .textModifier(.bold,12, selectedTab == .processes ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.processes)
                    
                    ProfileView()
                        .tabItem {
                            Image(.profile)
                                .renderingMode(.template)
                                .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                            Text("profile".localized())
                                .textModifier(.bold,12, selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                        }
                        .tag(Tab.profile)
                }
                .accentColor(Color(.primary))

                // Custom Border Overlay for Tab Bar
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width, height: 1) // Border height
                        .foregroundColor(.black.opacity(0.1))
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 55) // Position border above tab items
                }
//                .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
    }
}
