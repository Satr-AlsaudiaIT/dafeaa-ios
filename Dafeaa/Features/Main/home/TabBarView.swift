//
//  TabBarView.swift
//  Dafeaa
//
//  Created by AMNY on 11/10/2024.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, wallet, myOrders, processes, profile
    }
    
    var body: some View {
        NavigationStack{
            TabView(selection: $selectedTab) {
                HomeView()
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
                        Image( .bag)
                            .renderingMode(.template)
                            .foregroundColor(selectedTab == .profile ? Color(.primary) : Color(.grayBDBDBD))
                        Text("myOrders".localized())
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
        }.navigationBarHidden(true)//.edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    TabBarView()
}
