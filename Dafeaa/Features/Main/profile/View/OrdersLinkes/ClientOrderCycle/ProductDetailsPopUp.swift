//
//  ProductDetailsPopUp.swift
//  Dafeaa
//
//  Created by AMNY on 09/11/2024.
//

import SwiftUI
import SDWebImageSwiftUI
struct ProductDetailsPopUp: View {
    @Binding var product:productList
    @StateObject var viewModel = OrdersVM()
    @State private var isEditTapped : Bool = false
    @State private var  selectedImage: String?
    @State private var showSelectedImage: Bool = false
    @State var quantity : String = ""
     var isAbleToEdit : Bool = false
     var isMerchant : Bool = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("productDetails".localized())
                        .textModifier(.plain, 17, .black010202)
                    Spacer()
                }
                .padding(.vertical,19)
                ScrollView {
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
                            
                            if isMerchant {
                                if product.totalQuantity != 0 && product.totalQuantity != nil {
                                    HStack {
                                        Text("totalQuantity".localized())
                                            .textModifier(.plain, 15, .gray565656)
                                        Spacer()
                                        Text("\(product.totalQuantity ?? 0)")
                                            .textModifier(.plain, 15, .gray565656)
                                    }
                                }
                                if product.paiedQuantity != 0 && product.paiedQuantity != nil {
                                    HStack {
                                        Text("paidQuantity".localized())
                                            .textModifier(.plain, 15, .gray565656)
                                        Spacer()
                                        Text("\(product.paiedQuantity ?? 0)")
                                            .textModifier(.plain, 15, .gray565656)
                                    }
                                }
                                if product.remainingQuantity != 0 && product.remainingQuantity != nil {
                                    HStack {
                                        Text("remainingQuantity".localized())
                                            .textModifier(.plain, 15, .gray565656)
                                        Spacer()
                                        Text("\(product.remainingQuantity ?? 0)")
                                            .textModifier(.plain, 15, .gray565656)
                                    }
                                }
                            }
                        }
                        if isAbleToEdit {
                            if !isEditTapped{
                                Button {
                                    isEditTapped = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("updateQuantity".localized())
                                            .textModifier(.plain, 15, .primaryF9CE29)
                                            .underline()
                                        Spacer()
                                    }
                                }
                                
                            }
                            Spacer()
                            if isEditTapped {
                                CustomMainTextField(text: $quantity, placeHolder: "newQuantity".localized())
                                ReusableButton(buttonText: "Update") {
                                    viewModel.updateQuantity(productId: product.id ?? 0, quantity: Int(quantity) ?? 0)
                                }
                                .padding(24)
                            }
                        }
                    }
                    
                }
                .scrollIndicators(.hidden)
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
            }
            .padding(.horizontal,20)
            if let selectedImage = selectedImage, showSelectedImage {
                ZStack {
                    Color(.black010202.opacity(0.5))
                        .onTapGesture {
                            showSelectedImage = false
                        }
                    WebImage(url: URL(string: selectedImage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.width * 0.9)
                        .disabled(true)
                        .cornerRadius(10)
                        }
                .ignoresSafeArea(.all)
                
            }
        }
        .onAppear{
            isEditTapped = false
            quantity = String(product.remainingQuantity ?? 0)
        }
        .toastView(toast: $viewModel.toast)
        .onChange(of: viewModel.isUpdateQuantitySuccess) { oldValue, newValue in
            if newValue {
                isEditTapped = false
                viewModel.isUpdateQuantitySuccess = false
                product.remainingQuantity = Int(quantity)
            }
            
        }
        
    }
}

//#Preview {
//    ProductDetailsPopUp()
//}
