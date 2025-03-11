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
    @State var selectedProduct: productList = productList(id: 3, image: "www", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 1, remainingQuantity: 0)
    @State var showingProductDetails: Bool = false
    @State var totalPrice: Double = 0
    @State var itemsPrice: Double = 0
    var orderData: OrderData {
        return viewModel.orderData ?? OrderData()
    }
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                NavigationBarView(title: "orderDetails".localized()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                    VStack(alignment: .leading, spacing: 24) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                if let orderStatusInt = orderData.orderStatus {
                                    PathViewChoice(orderStatus: .constant(orderStatusEnum(rawValue: orderStatusInt) ?? .pending))
                                        .padding(.horizontal,-10)
                                        .padding(.vertical,-10)
                                }
                               if orderData.qrCode != ""{
                                    QRCodeView(text: viewModel.orderData?.qrCode ?? "")
                                }
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
                                            ForEach(0..<(orderData.products?.count ?? 0),id: \.self){ index in
                                                Button(action: {
                                                    showingProductDetails = true
                                                    selectedProduct = orderData.products?[index] ?? selectedProduct
                                                }) {
                                                    OrderItemView(itemName: orderData.products?[index].name ?? "" ,
                                                                  price: orderData.products?[index].price ?? 0,
                                                                  amount: orderData.products?[index].amount ?? 0,
                                                                  isLast: index == (orderData.products?.count ?? 3 ) - 1 )
                                                }
                                            }
                                        } .padding(.horizontal,16)
                                    }
                                }
                                // Payment Info Section
                                VStack(spacing: 8) {
                                    Text("paymentInfo".localized())
                                        .textModifier(.plain, 15,  .black222222)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                    
                                    
                                    
                                    PaymentInfoView(breakdown: PaymentDetails(tax: orderData.taxPrice ?? 0.00, deliveryPrice: orderData.deliveryPrice ?? 0.00),itemsPrice: $itemsPrice, isShowDetails: true)
                                    
                                    
                                    
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
                                            AddressView(name: orderData.clientName ?? "", address: orderData.address ?? "", phone: orderData.clientPhone ?? "")
                                            
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
                                
                                if orderData.orderStatus ?? 0 == 1 {
                                    ReusableButton(buttonText: "reject".localized(),isEnabled: true){
                                        isRejectTapped = true
                                        
                                    }
                                    
                                    ReusableButton(buttonText: "accept".localized(),isEnabled: true,buttonColor: .yellow){
                                        viewModel.changeOrderStatus(id: orderID ?? 0, status: 2)
                                    }
                                }
                                else if orderData.orderStatus ?? 0 == 2 {
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
        .sheet(isPresented: $showingProductDetails, onDismiss: {
            showingProductDetails = false
        }, content: {
            ProductDetailsPopUp(product: $selectedProduct )
                .presentationCornerRadius(24)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        })
        .navigationDestination(isPresented: $isNavigateToContactInfo) {
            HelpAndSupportView()
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear() {
            AppState.shared.swipeEnabled = true
            viewModel.getOrder(id: orderID ?? 0)
        }
        .onChange(of: viewModel.isLoading, { oldValue, newValue in
            if !newValue {
                totalPrice = orderData.totalPrice ?? 0
                itemsPrice = orderData.products?.reduce(0.0) { total, product in
                          let price = product.offerPrice ?? product.price ?? 0.0
                          let quantity = Double(product.amount ?? 0)
                          return total + (price * quantity)
                      } ?? 0.0
            }
        })
        .onChange(of: viewModel._isStatusChangedSuccess) { _, newValue in
            if newValue {
                isCancelTapped = false
                isRejectTapped = false
                viewModel.getOrder(id: orderID ?? 0)
            }
        }
        
    }
}


#Preview {
    OrderBusinessDetailsView()
}
