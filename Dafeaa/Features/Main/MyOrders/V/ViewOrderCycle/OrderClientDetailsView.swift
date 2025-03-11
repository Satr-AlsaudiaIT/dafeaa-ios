//
//  OrderClientDetailsView.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import SwiftUI

import CoreImage.CIFilterBuiltins

struct OrderClientDetailsView: View {
    @State var orderID: Int?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private let userType: Int = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @StateObject var viewModel = OrdersVM()
    @State var selectedSegment = 0
    @State var isNavigateToContactInfo: Bool = false
    @State var confirmReceivingOrder: Bool = false
    @State var isCancelTapped: Bool = false
    @StateObject private var scanner = ScannerViewModel()
    @State var selectedProduct: productList = productList(id: 3, image: "www", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 1, remainingQuantity: 0)
    @State var showingProductDetails: Bool = false
    @State var totalPrice: Double = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "orderDetails".localized()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            if let orderStatusInt = viewModel.orderData?.orderStatus {
                                PathViewChoice(orderStatus: .constant( orderStatusEnum(rawValue: orderStatusInt) ?? .pending))
                                    .padding(.horizontal,-10)
                                    .padding(.vertical,-10)
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
                                        ForEach(0..<(viewModel.orderData?.products?.count ?? 3),id: \.self){ index in
                                            Button(action: {
                                                showingProductDetails = true
                                                selectedProduct = viewModel.orderData?.products?[index] ?? selectedProduct
                                            }) {
                                                OrderItemView(itemName:viewModel.orderData?.products?[index].name ?? "",
                                                              price: viewModel.orderData?.products?[index].price ?? 0,
                                                              amount: viewModel.orderData?.products?[index].amount ?? 0,
                                                              isLast: index == (viewModel.orderData?.products?.count ?? 3 ) - 1 )
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
                                
                                   
                                PaymentInfoView(breakdown: PaymentDetails(tax: viewModel.orderData?.taxPrice ?? 0.00, deliveryPrice: viewModel.orderData?.deliveryPrice ?? 0.00),itemsPrice: $totalPrice, isShowDetails: true)
                                        
                                  
                                
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
                                        AddressView(name: Constants.userName , address: viewModel.orderData?.address ?? "",phone: Constants.phone)
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
                            if viewModel.orderData?.orderStatus ?? 0 == 3 {
                                
                                ReusableButton(buttonText: "confirmReceivingOrder".localized(),isEnabled: true){
                                    confirmReceivingOrder = true
                                }
                            }
                            
                            else if viewModel.orderData?.orderStatus == 1 || viewModel.orderData?.orderStatus == 2 {
                                ReusableButton(buttonText: "Cancel".localized(),isEnabled: true){
                                    isCancelTapped = true
                                    
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationDestination(isPresented: $isNavigateToContactInfo) {
                HelpAndSupportView()
            }
            if isCancelTapped {
                PopUpComponent(title: "cancelOrder", question: "cancelOrderQuestion",isShowing: $isCancelTapped){
                    viewModel.changeOrderStatus(id: orderID ?? 0, status: 5)
                }
            }
            if confirmReceivingOrder {
                ZStack {
                    
                    QRCodeScannerView(scanner: scanner)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    QRCodeScannerOverlay(isShowing: $confirmReceivingOrder)
                        .frame(maxWidth: .infinity)
                       
                }
                .onChange(of: scanner.scannedCode) { _,new in
                    viewModel.completeOrder(id: orderID ?? 0, qrCode: scanner.scannedCode)
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
        .toastView(toast: $viewModel.toast)
        .onChange(of: viewModel._isCompleteOrderSuccess) {_,newValue in
            confirmReceivingOrder = false
            viewModel.getOrder(id: orderID ?? 0)
        }
        .onChange(of: viewModel._isStatusChangedSuccess) {_,newValue in
            isCancelTapped = false
            viewModel.getOrder(id: orderID ?? 0)
        }
        .navigationBarHidden(true)
        .onAppear() {
            AppState.shared.swipeEnabled = true
            viewModel.getOrder(id: orderID ?? 0)
        }
       
        .onChange(of: viewModel.isLoading, { oldValue, newValue in
            if !newValue {
                
                totalPrice = viewModel.orderData?.totalPrice ?? 0
            }
        })
    }
}


#Preview {
    OrderClientDetailsView()
}
