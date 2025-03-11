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

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("productDetails".localized())
                        .textModifier(.bold, 17, .black010202)
                    Spacer()
                }
                .padding(.vertical,19)
                WebImage(url: URL(string: product.image ?? ""))
                    .resizable()
                    .frame(height: 260)
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke( Color(.primary),lineWidth: 1)
                    }
                    
                HStack {
                    Text(product.name ?? "")
                        .textModifier(.bold, 15, .black222222)
                    Spacer()
                    if product.offerPrice != 0 {
                        HStack {
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.price ?? 0))
                                    .textModifier(.plain, 14, .black010202)
                                    .strikethrough(true, color: .black010202)
                              
                                Image(.riyal)
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .foregroundColor(.gray8B8C86)
                                     .frame(width: 20)
                                     .padding(.trailing, 10)
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                           
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.offerPrice ?? 0))
                                    .textModifier(.plain, 14, .black010202)
                              
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
                Text(product.description ?? "")
                    .textModifier(.plain, 15, .gray565656)
                    
            }
            .padding(.horizontal,20)
        }
        
    }
}

//#Preview {
//    ProductDetailsPopUp()
//}
