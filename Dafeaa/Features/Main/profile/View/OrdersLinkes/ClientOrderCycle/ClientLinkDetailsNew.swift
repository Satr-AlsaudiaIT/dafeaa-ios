//
//  ClientLinkDetailsNew.swift
//  Dafeaa
//
//  Created by AMNY on 07/11/2024.
//

import SwiftUI

struct ClientLinkDetailsNew: View {
    let code: String = Constants.clientOrderCode
    @State var offerData: ShowOfferData?
    @StateObject var viewModel = OrdersVM()
    @State var productAmountDic: [[String:Any]] = []
    @State var amount : Int = 0
    @State var totalPrice: Double = 0
    @State var amountChanged: Bool = false
    @State var addressId:Int = Constants.selectedAddressId
    @State var address: String = Constants.selectedAddress
    @State var isNavigateToAddress: Bool = false
    @State var showingProductDetails: Bool = false
    @State var isAmountInCellDisabled: Bool = false
    @State var showOrderDetails: Bool = false
    @State private var  selectedImage: String?
    @State private var showSelectedImage: Bool = false
    @State var quantity : String = ""
     var isAbleToEdit : Bool = false
     var isMerchant : Bool = false
    
    @State var selectedProduct: productList = productList(id: 3, images: [ImageModel(file: "ww")], name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000,amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 0, remainingQuantity: 1)
    var linkDetails: ShowOfferData  {
        return viewModel.offersData ?? ShowOfferData(id: 0, name: "", code: "", description: "", clientId: 1, deliveryPrice: 1, taxPrice: 1, products: [], status: 0,commissionRatio: "",maxCommissionValue: "")
    }
    var body: some View {
            ZStack {
                
                    VStack(alignment: .leading) {
                        NavigationBarView(title: "offerDetails".localized()) {
                            GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                            MOLH.reset()
                        }
                        ScrollView {
                        VStack(alignment: .leading,spacing: 19) {
//                            Text(linkDetails.name ?? "")
//                                .textModifier(.plain, 16, .black010202)
//                            Text(linkDetails.description ?? "")
//                                .textModifier(.plain, 15, .black222222)
//                                .padding(.top,-10)
                            if viewModel.offersData?.status == 2 {
                                Text("orderNotAvailable".localized())
                                    .textModifier(.plain, 15, .redFA4248)
                            }
//                            ForEach (linkDetails.products ?? []) { product in
//                                Button(action: {
//                                    showingProductDetails = true
//                                    selectedProduct = product
//                                }) {
//                                    ClientLinkCellIView(product: product, productAmountDic: $productAmountDic,amountChanged: $amountChanged,isDisabled: $isAmountInCellDisabled)
//                                        
//                                        
//                                      
//                                }
//                            }
                            if linkDetails.products?.count ?? 0 > 0, let product = linkDetails.products?.first  {
                                VStack(alignment: .leading) {
                                        VStack {
                                            InfiniteCarouselView(listOfPages: .constant(product.images ?? []),onImageTap: { file in
                                                selectedImage = file
                                                showSelectedImage = true
                                            })
                                            HStack {
                                                Text(product.name ?? "")
                                                    .textModifier(.plain, 15, .black222222)
                                                Spacer()
                                                
                                                    HStack {
                                                        HStack(spacing: 5){
                                                            Text(String(format: "%.1f", product.price ?? 0))
                                                                .textModifier(.plain, 14, .black010202)
                                                                .strikethrough((product.offerPrice == 0 || product.offerPrice == nil) ? false : true, color: .black010202)
                                                                .fixedSize()
                                                            Image(.riyal)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .foregroundColor(.gray8B8C86)
                                                                .frame(width: 20)
                                                                .padding(.trailing, 10)
                                                        }
                                                        .environment(\.layoutDirection, .rightToLeft)
                                                    if product.offerPrice != 0, product.offerPrice != nil {
                                                        HStack(spacing: 5){
                                                            Text(String(format: "%.1f", product.offerPrice ?? 0))
                                                                .textModifier(.plain, 14, .black010202)
                                                                .fixedSize()
                                                            Image(.riyal)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .foregroundColor(.gray8B8C86)
                                                                .frame(width: 20)
                                                                .padding(.trailing, 10)
                                                        }
                                                        .environment(\.layoutDirection, .rightToLeft)
                                                    }
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack {
                                                    Text(product.description ?? "")
                                                        .textModifier(.plain, 15, .gray565656)
                                                    Spacer()
                                                }
                                            }
                                        }
                                      .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                                }
//                                .padding(.horizontal,20)
                                .onAppear {
                                    // Initialize the dictionary with product ID and initial amount
                                    let initialAmount = 1
                                    productAmountDic.append(["product_id": product.id ?? 0, "amount": "\(initialAmount)"])
                                    calculateTotalPrice()
                                }
                            }
                            PaymentInfoView(breakdown: PaymentDetails(commission: Double(linkDetails.commissionRatio ?? "0") ?? 0, commissionMaxPrice: Double(linkDetails.maxCommissionValue ?? "0") ?? 0),itemsPrice: $totalPrice)
                            
                            HStack {
                                Text("deliveryAddress".localized())
                                    .textModifier(.plain, 15, .black010202)
                                Spacer()
                                Button(action: {
                                    isNavigateToAddress = true
                                }) {
                                    Text(addressId == 0 ? "select".localized() : "edit".localized())
                                        .textModifier(.plain, 15, Color(.primary))
                                }
                            }
                            if addressId != 0 {
                                ZStack {
                                    HStack {
                                        Text(address)
                                            .textModifier(.plain, 12, .grayAAAAAA)
                                        Spacer()
                                    }
                                    .padding(.all, 10)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.grayAAAAAA), lineWidth: 0.4)
                                )
                                
                            }
                            ReusableButton(buttonText: "orderNow",isEnabled: viewModel.offersData?.status == 1 ? true : false){ viewModel.validations(dynamicLinkId: viewModel.offersData?.id ?? 0, addressId: addressId, products: productAmountDic)}
                            Spacer()
                        }
                        .padding(.all,24)
                        .navigationDestination(isPresented: $isNavigateToAddress) {
                            SavedAddressesView(selectedAddressId: $addressId, selectedAddress: $address,initSelectedAddressId: addressId,isComingFromSelection: true)
                        }
                        .onChange(of: viewModel.isOrderSuccess) { _, newValue in
                            if newValue {
                                showOrderDetails = true
                            }
                        }
                        .navigationDestination(isPresented: $showOrderDetails) {
                            if let orderId = viewModel.orderId {
                                OrderClientDetailsView(orderID: orderId, isComingFromCreateOrder: true)
                            }
                            
                        }
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
            .onChange(of: viewModel.offersData, { oldValue, newValue in
                isAmountInCellDisabled = viewModel.offersData?.status == 2 ? true : false
            })
            .sheet(isPresented: $showingProductDetails, onDismiss: {
                showingProductDetails = false
            }, content: {
                ProductDetailsPopUp(product: $selectedProduct)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            })
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
        
            .onAppear{
                if let offerData { viewModel.offersData = offerData
                } else { viewModel.showOffer(code: code) }
            }
        
    }
    // Function to calculate the total price
     private func calculateTotalPrice() {
         totalPrice = productAmountDic.reduce(0) { result, dict in
             guard
                 let productId = dict["product_id"] as? Int,
                 let amount = dict["amount"] as? String,
                 let product = linkDetails.products?.first(where: { $0.id == productId })
             else {
                 return result
             }
             
             let price = product.offerPrice ?? product.price
             return result + (Double(price ?? 0) * (Double(amount) ?? 0))
         }
     }
}

#Preview {
    ClientLinkDetails()
}



