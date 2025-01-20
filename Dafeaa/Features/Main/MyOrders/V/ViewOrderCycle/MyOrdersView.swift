//
//  MyOrdersView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct MyOrdersView: View {
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @StateObject var viewModel = OrdersVM()
    @State var selectedSegment = 0
    @State var selectedOrder: OrdersData?
    @State var navigateToClientDetails: Bool = false
    @State var navigateToBusinessDetails: Bool = false
    @State var showMenu: Bool = false
    var body: some View {
        ZStack{
            VStack(spacing: 0){
//                NavigationBarView(title:  "orders".localized())
                HStack {
                    HStack {
                        Image("")
                            .resizable()
                            .frame(width: 30,height: 30)
                        Spacer()
                        Text("orders".localized())
                            .textModifier(.plain, 17, .black222222)
                        Spacer()
                        Button {
                            showMenu = true
                        } label: {
                            Image(.filter)
                                .resizable()
                                .frame(width: 20,height: 20)
                        }
                    }
                    .padding(20)
                }
                .background(Color(.primary))
                VStack(spacing: 16){
                    CustomSegmentView(titlesArray: ["MyPurchases","MySales"], selectedSegment:$selectedSegment)
                        .onChange(of: selectedSegment) { newValue, oldValue in
                            if userType == 1{
                                viewModel.orders(skip: 0, status: newValue == 1 ? "current":"history")
                            }
                            else {
                                viewModel.orders(skip: 0, status: newValue == 1 ? "current":"history")
                            }
                        }
                    VStack(alignment: .leading,spacing: 24) {
                        if viewModel.ordersList.isEmpty {
                            EmptyCostumeView()
                        } else {
                            ScrollView(showsIndicators: false) {
                               LazyVStack(spacing: 8) {
                                    ForEach(0..<(viewModel.ordersList.count),id: \.self){ index in
                                        Button(action: {
                                            selectedOrder = viewModel.ordersList[index]
                                            if userType == 1{
                                                navigateToClientDetails = true
                                            }
                                            else {
                                                navigateToBusinessDetails = true
                                            }
                                        }) {
                                            OrderComponent(order: viewModel.ordersList[index])
                                                .onAppear {
                                                    if index == viewModel.ordersList.count - 1 {
                                                        loadMoreOrdersIfNeeded()
                                                    }
                                                }
                                        }
                                    }
                                }
                                
                            }.refreshable {
                                viewModel.orders(skip: 0, status: selectedSegment == 1 ? "history" : "current",animated: false)
                            }
                        }
                    }
                    .navigationDestination(isPresented: $navigateToClientDetails) {
                        OrderClientDetailsView(orderID: selectedOrder?.id ?? 0)
                    }
                    .navigationDestination(isPresented: $navigateToBusinessDetails) {
                        OrderBusinessDetailsView(orderID: selectedOrder?.id ?? 0)
                    }
                }.padding(24)
            }
            .onTapGesture {
                showMenu = false
            }
            if showMenu {
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Color(.white)
                            VStack {
                                VStack(spacing: 10) {
                                    Button {
                                        showMenu = false
                                    } label: {
                                        HStack {
                                           
                                            Text("current".localized())
                                                .textModifier(.plain, 14, .gray666666)
                                                .frame(width: 100)
                                            Image(systemName: "arrow.up")
                                                .padding(.trailing,20)
                                                .foregroundColor(.gray666666)
                                        }
                                    }
                                    
                                    Button {
                                        showMenu = false
                                    } label: {
                                        HStack {
                                            Text("history".localized())
                                                .textModifier(.plain, 14, .gray666666)
                                                .frame(width: 100)
                                            Image(systemName: "arrow.down")
                                                .padding(.trailing,20)
                                                .foregroundColor(.gray666666)
                                        }
                                    }
                                    
                                    
                                    
                                }
                                .padding(20)
                            }
                        }
                        .cornerRadius(10)
                        .shadow(color:.gray616161, radius: 4, x: 0, y: 3)
                        .fixedSize()
                        .padding(.trailing,30)
                    }
                    .padding(.top,49)
                    
                    Spacer()
                }
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
            AppState.shared.swipeEnabled = true
            viewModel.orders(skip: 0, status: selectedSegment == 1 ? "history" : "current")
        }
        .onDisappear{
            viewModel._ordersList.removeAll()
        }
    }
    
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.orders(skip: viewModel.ordersList.count, status: selectedSegment == 1 ? "history" : "current")
        }
    }
}

#Preview {
    MyOrdersView()
}


struct OrderComponent: View {
    @State var order: OrdersData?
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0

    var body: some View {
        ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.clear))
                
                VStack(alignment: .leading,spacing:12) {
                    HStack(alignment: .center){
                        Image(.process)
                            .resizable()
                            .frame(width: 65,height: 65)
                            .clipShape(.circle)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order?.name ?? "")
                                .textModifier(.plain, 14, .black222222)
                            
                            Text(orderStatusEnum(rawValue: order?.orderStatus ?? 0)?.title ?? "" + " - \(order?.date ?? "")")
                                .textModifier(.plain, 12, .orangeFF6021)
                        }
                    }
                    HStack(spacing: 2) {
                        Image(.barcode)
                            .resizable()
                            .frame(width: 20,height: 20)
                        Text("orderNo".localized()+": \(order?.id ?? 0)")
                            .textModifier(.plain, 12,  .grayAAAAAA)
                        Spacer()
                       
                                Image(.routing)
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                Text("orderRoute".localized())
                                    .textModifier(.plain, 12, .black222222)
                          
                    }
                }.padding(16)
            }
    }
}
