//
//  ClientLinkCellIView.swift
//  Dafeaa
//
//  Created by AMNY on 09/11/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ClientLinkCellIView: View {
    var product: productList
        @Binding var productAmountDic: [[String: Any]]  // Pass in productAmountDic as a binding
        @State private var amount: Int  // Local state for amount
        @Binding var amountChanged: Bool
    init(product: productList, productAmountDic: Binding<[[String: Any]]>,amountChanged: Binding<Bool>) {
            self.product = product
            _productAmountDic = productAmountDic
            _amount = State(initialValue: 1)
            _amountChanged = amountChanged
        }
    var body: some View {
        ZStack {
            HStack {
                WebImage(url: URL(string: product.image ?? ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .mask(Circle().frame(width: 80, height: 80))
                    .overlay(
                        Circle()
                            .stroke( Color(.primary), lineWidth: 1)
                    )
                
                VStack(alignment: .leading,spacing: 19) {
                    HStack {
                        Text(product.name ?? "")
                            .textModifier(.semiBold, 15, .black010202)
                        Spacer()
                        if product.offerPrice != nil  {
                            HStack {
                                Text(String(format: "%.1f", product.price ?? 0.0,"RS".localized()))
                                    .textModifier(.semiBold, 15, .black010202)
                                    .padding(.trailing,5)
                                    .strikethrough(true, color: .black)
                                Text(String(format: "%.1f", product.offerPrice ?? 0.0,"RS".localized()))
                                    .textModifier(.plain, 15, .black010202)
                                    .padding(.trailing,5)
                            }
                        }
                        else {
                            Text(String(format: "%.1f", product.price ?? 0.0,"RS".localized()))
                                .textModifier(.semiBold, 15, .black010202)
                                .padding(.trailing,5)
                        }
                    }
                    
                    HStack {
                        Text(product.description ?? "")
                            .textModifier(.plain, 15, .gray616161)
                            .lineLimit(2)
                        Spacer()
                        HStack {
                            Button(action: {
                                amount += 1
                            }) {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color(.black222222))
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.all,5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke( Color(.grayAAAAAA), lineWidth: 0.4)
                                            .shadow(radius: 3)
                                    )
                            }
                            .frame(width: 25, height: 25)
                            Text("\(amount)")
                                .textModifier(.plain, 15, .black010202)
                            Button(action: {
                                amount -= 1
                            }) {
                                ZStack {
                                    
                                    Image(systemName: "minus")
                                        .foregroundStyle(Color(.black222222))
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.all,5)
                                }
                            }
                            .disabled(amount == 1)
                            .frame(width: 25, height: 25)
                            .background(Color(amount == 1 ? .grayDADADA : .clear).cornerRadius(3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke( Color(.grayAAAAAA), lineWidth: 0.4)
                                    .shadow(radius: 3) 
                            )
                        }
                        .padding(.leading,5)
                    }
                }
            }
            .padding(.all,10)
        }
        
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke( Color(.primary), lineWidth: 1)
        )
        
        .onChange(of: amount) { newAmount in
            if let index = productAmountDic.firstIndex(where: { $0["product_id"] as? Int == product.id }) {
                amountChanged.toggle()
                productAmountDic[index]["amount"] = newAmount
            }
        }
        //        .padding(.all,20)
        
    }
    
    
}
