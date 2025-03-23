//
//  OrderLinkDetailsView.swift
//  Dafeaa
//
//  Created by AMNY on 10/11/2024.
//

import SwiftUI

struct OrderLinkDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var code: String = ""
    @State var offerData: ShowOfferData?
    @StateObject var viewModel = OrdersVM()
    @State var totalPrice: Double = 0
    @State var amountChanged: Bool = false
    @State var addressId:Int = Constants.selectedAddressId
    @State var address: String = Constants.selectedAddress
    @State var isNavigateToAddress: Bool = false
    @State var showingProductDetails: Bool = false
    @State var selectedProduct: productList = productList(id: 3, image: "www", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 1, remainingQuantity: 1)
    var linkDetails: ShowOfferData  {
        return viewModel.offersData ?? ShowOfferData(id: 0, name: "", code: "", description: "", clientId: 1, deliveryPrice: 1, taxPrice: 1, products: [], status: 0,commissionRatio: "",maxCommissionValue: "")
    }
    @State var status: Int = 0
    @State var toast: FancyToast? = nil
    var offerDataView: ShowOfferData {
        return viewModel.offersData ?? ShowOfferData(id: 0, name: "", code: "", description: "", clientId: 1, deliveryPrice: 1, taxPrice: 1, products: [], status: 0,commissionRatio: "",maxCommissionValue: "")
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            if offerData == nil {
                                presentationMode.wrappedValue.dismiss()
                            }else{
                                GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                                MOLH.reset()
                            }
                        }) {
                            Image("backArrow")
                                .resizable()
                                .frame(width: 10, height: 17)
                        }
                        Image("")
                            .frame(width: 25,height: 20)
                        Spacer()
                        Text("offerDetails".localized())
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 17))
                            .foregroundStyle(Color(.black222222))
                        Spacer()
                        Button(action: {copyURL()},
                               label: { Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                            .foregroundColor(.black222222)})
                        .frame(width: 25,height: 20)
                        let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
                        if let offerID = viewModel.offersData?.id , let offerCode = viewModel.offersData?.code, let url = URL(string: "https://dafeaa-backend.deplanagency.com/offers/\(offerID)/\(offerCode)/\(userId)"){
                            ShareLink(item: url) {  Image(.share).resizable().frame(width: 25,height: 20)} }
                    }
                    .padding(24)
                    .background(Color(.primary))
                    ZStack(alignment: .bottom){
                        ScrollView {
                            VStack(alignment: .leading,spacing: 19) {
                                Text("offerDetails".localized())
                                    .textModifier(.plain, 16, .black010202)
//                                Text(linkDetails.description ?? "")
//                                    .textModifier(.plain, 15, .black222222)
//                                    .padding(.top,-10)
                                
                                ForEach (linkDetails.products ?? []) { product in
                                    Button(action: {
                                        showingProductDetails = true
                                        selectedProduct = product
                                    }) {
                                        BusinessLinkCellIView(product: product)
                                        
                                    }
                                }
                                PaymentInfoView(breakdown: PaymentDetails(commission: Double(linkDetails.commissionRatio ?? "0" ) ?? 0, commissionMaxPrice: Double(linkDetails.maxCommissionValue ?? "0") ?? 0),isMerchantOfferDetails: true, itemsPrice: $totalPrice)
                            
                            }
                            .padding(.bottom,40)
                            .navigationDestination(isPresented: $isNavigateToAddress) {
                                SavedAddressesView(selectedAddressId: $addressId, selectedAddress: $address,isComingFromSelection: true)
                            }
                        }
                        VStack (spacing: 20) {
                            
                            if status == 1 {
                                    ReusableButton(buttonText: "stopOffer",buttonColor: .yellow){
                                        viewModel.stopActivateOffer(code: viewModel.offersData?.code ?? "", status: 2)
                                    }
                                }
                                else {
                                    ReusableButton(buttonText: "activateOffer",buttonColor: .yellow){
                                        viewModel.stopActivateOffer(code: viewModel.offersData?.code ?? "", status: 1)
                                    }
                                }
                            
                            ReusableButton(buttonText: "deleteOffer"){
                                viewModel.deleteOffer(id: viewModel.offersData?.id ?? 0)
                            }
                        }
                    }
                    .padding(24)

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
            .onChange(of: viewModel.activeStopSuccess, { _, _ in
              
                
            })
            .sheet(isPresented: $showingProductDetails, onDismiss: {
                showingProductDetails = false
            }, content: {
                ProductDetailsPopUp(product: $selectedProduct,isAbleToEdit: true,isMerchant: true)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.85)])
            }).edgesIgnoringSafeArea(.bottom)
                .toastView(toast: $viewModel.toast)
                .toastView(toast: $toast)

                .navigationBarHidden(true)
                .onAppear{
                    if let offerData {
//                        status = offerData.status ?? 0
                        viewModel.offersData = offerData
                    } else {
                        viewModel.showOffer(code: code)
                    }
                }
                .onReceive(viewModel.$_isSuccess){value in
                    if value {
                        self.presentationMode.wrappedValue.dismiss()
                }}
                .onChange(of: selectedProduct, { oldValue, newValue in
                    updateOfferData(with: newValue)
                })
                .onChange(of: viewModel.offersData) { oldValue, newValue in
                    if let products = viewModel.offersData?.products {
                        totalPrice = products.reduce(0.0) { (result, product) in
                            let productPrice = product.offerPrice ?? 0 > 0 ? product.offerPrice! : product.price ?? 0
                            let totalProductPrice = productPrice * Double(product.amount ?? 1)
                            return result + totalProductPrice
                        }
                        
                    }
                    status = viewModel.offersData?.status ?? 0
                }
        }
    }
    // Function to calculate the total price
    private func copyURL() {
        let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0

        if let offerID = viewModel.offersData?.id , let offerCode = viewModel.offersData?.code{
            let urlString = "https://dafeaa-backend.deplanagency.com/offers/\(offerID)/\(offerCode)/\(userId)"
            UIPasteboard.general.string = urlString
            self.toast = FancyToast(type: .error, title: "".localized(), message:  "copied successfully".localized())
        }
    }
    
    private func updateOfferData(with selectedProduct: productList) {
        guard var products = viewModel.offersData?.products else { return }

        if let index = products.firstIndex(where: { $0.id == selectedProduct.id }) {
            viewModel.offersData?.products?[index] = selectedProduct
//            offerData?.products = products
        }
    }
}

#Preview {
    OrderLinkDetailsView()
}



