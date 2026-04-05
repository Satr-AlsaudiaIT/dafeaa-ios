//
//  NotificationsView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = HomeVM()
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedTab : TabBarView.Tab
    @State private var navigateToClientOrder = false
    @State private var navigateToMerchantOrder = false
    @State private var navigateToWithdraws = false
    @State private var actionId: Int = 0

    var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    NavigationBarView(title: "notifications".localized()) {
                        presentationMode.wrappedValue.dismiss()
                    }

                    VStack(alignment: .center, spacing: 24) {
                        if viewModel.notifications.isEmpty {
                            VStack {
                                Spacer()
                                Image(.noNotification)
                                    .resizable()
                                    .frame(width: 120, height: 139)
                                Text("emptyNotifications".localized())
                                    .textModifier(.plain, 16, .grayADADAD)
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(0 ..< viewModel.notifications.count, id: \.self) { index in
                                        notificationsComponent(
                                            model: viewModel.notifications[index],
                                            onTap: { action in
                                                switch action {
                                                case let .clientOrder(id):
                                                    self.actionId = id
                                                    self.navigateToClientOrder = true

                                                case let .merchantOrder(id):
                                                    self.actionId = id
                                                    self.navigateToMerchantOrder = true

                                                case let .withdraws(id):
                                                    self.actionId = id
                                                    self.navigateToWithdraws = true

                                                case  .wallet:
                                                    selectedTab = .wallet
                                                    presentationMode.wrappedValue.dismiss()

                                                case .none:
                                                    break
                                                }
                                            }
                                        )
                                        .onAppear {
                                            if index == viewModel.notifications.count - 1 {
                                                loadMoreOrdersIfNeeded()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)

                    .navigationDestination(isPresented: $navigateToClientOrder) {
                        OrderClientDetailsView(orderID: actionId)
                    }
                    .navigationDestination(isPresented: $navigateToMerchantOrder) {
                        OrderBusinessDetailsView(orderID: actionId)
                    }
//                    .navigationDestination(isPresented: $navigateToWithdraws) {
//                        WithdrawsView(heighlightedId: actionId)
//                    }

                }

                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView().hidden()
                }
            }
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                viewModel.notificationsList(skip: 0)
            }
        
    }

    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.notificationsList(skip: viewModel.notifications.count)
        }
    }
}
#Preview {
    NotificationsView(selectedTab:.constant(.home))
}


struct notificationsComponent: View {
    let model: NotificationsData
    let onTap: (NotificationAction) -> Void

    var body: some View {
        ZStack {
            Color(model.isRead == 0 ? Color(.primaryF9CE29).opacity(0.1) : .clear)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text(model.title ?? "")
                        .textModifier(.plain, 14, .gray565656)
                    Spacer()
                    Text(model.createdAt ?? "")
                        .textModifier(.plain, 14, .gray858585)
                }
                .padding(.top,20)
                Text(model.body ?? "")
                    .textModifier(.plain, 14,  .gray919191).lineSpacing(4)
                
                if model.actionType == 1 || model.actionType == 2 || model.actionType == 3 {
                    Text( "Press to show details".localized())
                        .textModifier(.plain, 12, .black010202)
                }
                
                Divider()
                    .foregroundColor(Color(.black).opacity(0.10))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .onTapGesture {
                onTap(model.navigationAction)
            }
        }
    }
}
