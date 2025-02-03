//
//  NotificationsView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = HomeVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        
        //MARK: - upperView
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "notifications".localized()){
                    presentationMode.wrappedValue.dismiss()
                }
                VStack ( alignment:.center, spacing: 24){
                    
                   
                    if viewModel.notifications.isEmpty {
                        VStack{
                            Spacer()
                            Image(.noNotification)
                                .resizable()
                                .frame(width: 120,height: 139)
                            Text("emptyNotifications".localized())
                                .textModifier(.plain, 16, .grayADADAD)
                                .lineSpacing(4)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }.padding(.horizontal,24)
                    } else {
                        ScrollView {
                            
                            LazyVStack(spacing: 0) {
                                ForEach(0..<viewModel.notifications.count,id: \.self){ index in
                                    notificationsComponent(model: viewModel.notifications[index])
                                        .onAppear {
                                            if index == viewModel.notifications.count - 1 {
                                                loadMoreOrdersIfNeeded()
                                            }
                                        }
                                }
                            }
                            
                        }
                   }
                    
                }.padding(.bottom,24)
            }
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear(){
//            viewModel.notificationsList(skip: 0)
        }
    }
    
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.notificationsList(skip: viewModel.notifications.count)
        }
    }
    
}
#Preview {
    NotificationsView()
}


struct notificationsComponent: View {
    @State var model: NotificationsData?
    
    var body: some View {
        ZStack {
            Color( model?.isRead  == 1 ?  Color(.primaryF9CE29).opacity(0.1) : .clear)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text(model?.title ?? "")
                        .textModifier(.plain, 14, .gray565656)
                    Spacer()
                    Text(model?.createdAt ?? "")
                        .textModifier(.plain, 14, .gray858585)
                }
                .padding(.top,20)
                Text(model?.body ?? "")
                    .textModifier(.plain, 14,  .gray919191).lineSpacing(4)
                Divider()
                    .foregroundColor( Color(.black).opacity(0.10))
                    .padding(.top,4)
            }
            .padding(.horizontal,20)
            
        }
    }
}

