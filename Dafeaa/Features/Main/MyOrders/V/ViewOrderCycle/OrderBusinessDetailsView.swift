//
//  OrderBusinessDetailsView 2.swift
//  Dafeaa
//
//  Created by AMNY on 26/10/2024.
//


import SwiftUI

import CoreImage.CIFilterBuiltins

struct OrderBusinessDetailsView: View {
    @State var orderID: Int?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @StateObject var viewModel = OrdersVM()
    @State var selectedSegment = 0
    @State var isNavigateToContactInfo: Bool = false
    @State var isCancelTapped: Bool = false
    @State var isRejectTapped: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "orderDetails".localized()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            PathViewChoice(orderStatus: orderStatus(rawValue: viewModel.orderData?.orderStatus ?? 1) ?? .pending)
                                .padding(.horizontal,-10)
                                .padding(.vertical,-10)
                            //  Order Items Section
                            VStack(spacing: 8) {
                                Text("showOrderDetails".localized())
                                    .textModifier(.plain, 15,  .black222222)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                ZStack{
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.clear))
                                    VStack(spacing: 8) {
                                        ForEach(0..<(viewModel.orderData?.products?.count ?? 3),id: \.self){ index in
                                            OrderItemView(itemName: "هاتف ايفون 15 برو ماكس", price: 2500.00, isLast: index == (viewModel.orderData?.products?.count ?? 3 ) - 1 )
                                            
                                        }
                                    } .padding(.horizontal,16)
                                }
                            }
                            // Payment Info Section
                            VStack(spacing: 8) {
                                Text("paymentInfo".localized())
                                    .textModifier(.plain, 15,  .black222222)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                ZStack{
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.clear))
                                    
                                    VStack(spacing: 8) {
                                        PaymentInfoView(breakdown: PaymentDetails(itemsPrice:viewModel.orderData?.totalPrice ?? 0.00 ,tax: viewModel.orderData?.taxPrice ?? 0.00, deliveryPrice: viewModel.orderData?.deliveryPrice ?? 0.00))
                                        
                                    } .padding(.horizontal,16)
                                }
                            }
                            
                            
                            // Shipping Address Section
                            VStack(spacing: 8) {
                                Text("addressInfo".localized())
                                    .textModifier(.plain, 15,  .black222222)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                ZStack{
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                                        .background(RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.clear))
                                    
                                    VStack(spacing: 8) {
                                        AddressView(name: viewModel.orderData?.addressDetails?.name ?? "", address: viewModel.orderData?.addressDetails?.adress ?? "", phone: viewModel.orderData?.addressDetails?.phone ?? "")
                                        
                                    }
                                }
                            }
                            
                            
                            
                            // Customer Service Section
                                Button(action: {
                                    isNavigateToContactInfo = true
                                    
                                }) {
                                    Text("problemInfo".localized())
                                        .textModifier(.plain, 15,  .redEE002B)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .underline()
                                }
                            
                            // Confirm Button
                            // Confirm Button
                            
                            if viewModel.orderData?.orderStatus ?? 0 == 1 {
                                ReusableButton(buttonText: "reject".localized(),isEnabled: true){
                                    isRejectTapped = true
                                    
                                }
                                
                                ReusableButton(buttonText: "accept".localized(),isEnabled: true,buttonColor: .yellow){
                                    viewModel.changeOrderStatus(id: orderID ?? 0, status: 2)
                                }
                            }
                            else if viewModel.orderData?.orderStatus ?? 0 == 2 {
                                ReusableButton(buttonText: "Cancel".localized(),isEnabled: true){
                                    isCancelTapped = true
                                }
                                ReusableButton(buttonText: "onWay".localized(),isEnabled: true,buttonColor: .yellow){
                                    viewModel.changeOrderStatus(id: orderID ?? 0, status: 3)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            if isRejectTapped {
                PopUpComponent(title: "rejectOrder", question: "rejectOrderQuestion",isShowing: $isRejectTapped){
                    viewModel.changeOrderStatus(id: orderID ?? 0, status: 4)
                }
            }
            if isCancelTapped {
                PopUpComponent(title: "Cancel Order", question: "Are you sure you want to cancel this order?",isShowing: $isCancelTapped){
                    viewModel.changeOrderStatus(id: orderID ?? 0, status: 5)
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
        .onAppear() {
            AppState.shared.swipeEnabled = true
            viewModel.getOrder(id: orderID ?? 0)
        }
    }
}


#Preview {
    OrderBusinessDetailsView()
}
