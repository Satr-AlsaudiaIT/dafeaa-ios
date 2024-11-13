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
                            Text("\(product.price ?? 0)" + "rs".localized())
                                .textModifier(.plain, 14, .black010202)
                                .strikethrough(true, color: .black010202)
                            Text("\(product.offerPrice ?? 0)" + "rs".localized())
                                .textModifier(.plain, 14, .black010202)
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
