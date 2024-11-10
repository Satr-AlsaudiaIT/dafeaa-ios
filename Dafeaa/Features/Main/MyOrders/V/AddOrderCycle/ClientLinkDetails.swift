//
//  ClientLinkDetails.swift
//  Dafeaa
//
//  Created by AMNY on 07/11/2024.
//

import SwiftUI

struct ClientLinkDetails: View {
    let id: Int = Constants.clientOrderId
    @StateObject var viewModel = OrdersVM()
//    @State var linkDetails: LinkDetailsClient = LinkDetailsClient(id: 1, name: "Phones", code: "wwwwww", description: "this package has very good phones and very helpful ones that is very harm full", clientId: 1, deliveryPrice: 20, taxPrice: 100, products: [productList(id: 1, image: "https://media.istockphoto.com/id/621973728/photo/young-man-photographer-looking-at-camera.jpg?s=612x612&w=0&k=20&c=GmmvFsTYwcMwaWBYYzTeu6wAWoDZ-5xMJDt-qhhEUmE=", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, offerPrice: 950),productList(id: 2, image: "https://media.istockphoto.com/id/621973728/photo/young-man-photographer-looking-at-camera.jpg?s=612x612&w=0&k=20&c=GmmvFsTYwcMwaWBYYzTeu6wAWoDZ-5xMJDt-qhhEUmE=", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, offerPrice: 950),productList(id: 3, image: "https://media.istockphoto.com/id/621973728/photo/young-man-photographer-looking-at-camera.jpg?s=612x612&w=0&k=20&c=GmmvFsTYwcMwaWBYYzTeu6wAWoDZ-5xMJDt-qhhEUmE=", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1200, offerPrice: 950),])
    @State var productAmountDic: [[String:Any]] = []
    @State var amount : Int = 0
    @State var totalPrice: Double = 0
    @State var amountChanged: Bool = false
    @State var addressId:Int = Constants.selectedAddressId
    @State var address: String = Constants.selectedAddress
    @State var isNavigateToAddress: Bool = false
    @State var showingProductDetails: Bool = false
    @State var selectedProduct: productList = productList(id: 3, image: "www", name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, offerPrice: 950)
    var linkDetails: ShowOfferData  {
        return viewModel.offersData ?? ShowOfferData(id: 0, name: "", code: "", description: "", clientId: 1, deliveryPrice: 1, taxPrice: 1, products: [])
    }
    var body: some View {
        NavigationStack{
            ZStack {
                
                    VStack(alignment: .leading) {
                        NavigationBarView(title: "offerDetails".localized()) {
                            GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                            MOLH.reset()
                        }
                        ScrollView {
                        VStack(alignment: .leading,spacing: 19) {
                            Text(linkDetails.name ?? "")
                                .textModifier(.bold, 16, .black010202)
                            Text(linkDetails.description ?? "")
                                .textModifier(.plain, 15, .black222222)
                                .padding(.top,-10)
                            
                            ForEach (linkDetails.products ?? []) { product in
                                Button(action: {
                                    showingProductDetails = true
                                    selectedProduct = product
                                }) {
                                    ClientLinkCellIView(product: product, productAmountDic: $productAmountDic,amountChanged: $amountChanged)
                                        .onAppear {
                                            // Initialize the dictionary with product ID and initial amount
                                            let initialAmount = 1
                                            productAmountDic.append(["product_id": product.id ?? 0, "amount": initialAmount])
                                            calculateTotalPrice()
                                        }
                                        .onChange(of: amountChanged) { oldValue, newValue in
                                            calculateTotalPrice()
                                            
                                        }
                                }
                            }
                            PaymentInfoView(breakdown: PaymentDetails(itemsPrice: totalPrice, tax: linkDetails.taxPrice, deliveryPrice: linkDetails.deliveryPrice))
                            
                            HStack {
                                Text("deliveryAddress".localized())
                                    .textModifier(.bold, 15, .black010202)
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
                            ReusableButton(buttonText: "orderNow"){ viewModel.validations(dynamic_link_id: id, address_id: addressId, products: productAmountDic)}
                            Spacer()
                        }
                        .padding(.all,24)
                        .navigationDestination(isPresented: $isNavigateToAddress) {
                            SavedAddressesView(selectedAddressId: $addressId, selectedAddress: $address,isComingFromSelection: true)
                        }
                    }
                    
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
            .onAppear{
                viewModel.showOffer(id: id)
            }
        }
    }
    // Function to calculate the total price
     private func calculateTotalPrice() {
         totalPrice = productAmountDic.reduce(0) { result, dict in
             guard
                 let productId = dict["product_id"] as? Int,
                 let amount = dict["amount"] as? Int,
                 let product = linkDetails.products?.first(where: { $0.id == productId })
             else {
                 return result
             }
             
             let price = product.offerPrice ?? product.price
             return result + (Double(price ?? 0) * Double(amount))
         }
     }
}

#Preview {
    ClientLinkDetails()
}



