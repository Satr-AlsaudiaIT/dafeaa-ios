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
        @State private var showAmountError: Bool = false
        @Binding var isDisabled: Bool 
    init(product: productList, productAmountDic: Binding<[[String: Any]]>,amountChanged: Binding<Bool>,isDisabled: Binding<Bool>) {
            self.product = product
            _productAmountDic = productAmountDic
            _amount = State(initialValue: 1)
            _amountChanged = amountChanged
        _isDisabled = isDisabled
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
                
                VStack(alignment: .leading,spacing: 10) {
                    HStack {
                        Text(product.name ?? "")
                            .textModifier(.semiBold, 15, .black010202)
                        Spacer()
                        if product.offerPrice != nil  {
                            HStack {
                                HStack(spacing: 5){
                                    Text(String(format: "%.1f", product.price ?? 0.0))
                                        .textModifier(.semiBold, 13, .black010202)
                                        .padding(.trailing,5)
                                        .strikethrough(true, color: .black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .fixedSize()
                                    Image(.riyal)
                                         .resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .foregroundColor(.gray8B8C86)
                                         .frame(width: 20)
                                         .padding(.trailing, 10)
                                }
                                .environment(\.layoutDirection, .rightToLeft)

                                HStack(spacing: 5){
                                    Text(String(format: "%.1f", product.offerPrice ?? 0.0))
                                        .textModifier(.plain, 13, .black010202)
                                        .padding(.trailing,5)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
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
                        else {
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.price ?? 0.0))
                                    .textModifier(.semiBold, 13, .black010202)
                                    .padding(.trailing,5)
                                    .strikethrough(true, color: .black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
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
                    
                    HStack {
                        Text(product.description ?? "")
                            .textModifier(.plain, 15, .gray616161)
                            .lineLimit(2)
                        Spacer()
                        HStack {
                            Button(action: {
                                if (amount + 1) <= product.remainingQuantity ?? 0 {
                                    amount += 1
                                } else {
                                    showAmountError = true
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color(.black222222))
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.all,5)
                                    .background(Color( isDisabled ? .grayDADADA : .clear).cornerRadius(3))

                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke( Color(.grayAAAAAA), lineWidth: 0.4)
                                            .shadow(radius: 3)
                                    )
                            }
                            .frame(width: 25, height: 25)
                            .disabled(isDisabled)
                            Text("\(amount)")
                                .textModifier(.plain, 15, .black010202)
                            Button(action: {
                                amount -= 1
                                showAmountError = false
                            }) {
                                ZStack {
                                    Image(systemName: "minus")
                                        .foregroundStyle(Color(.black222222))
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.all,5)
                                }
                            }
                            .disabled(amount == 1 || isDisabled)
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
                    if showAmountError {
                        Text("exceedQuantity".localized() + " " + "\(product.remainingQuantity ?? 0)")
                            .textModifier(.semiBold, 10, .redD73D24)

                            .onAppear{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showAmountError = false
                                }
                            }
                    }
                    else {
                        Text("")
                            .textModifier(.semiBold, 10, .redD73D24)
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
        .onAppear{
            if product.remainingQuantity ?? 0 == 0 {
                isDisabled = true
                showAmountError = true 
            }
        }
        .onChange(of: amount) { newAmount in
            if let index = productAmountDic.firstIndex(where: { $0["product_id"] as? Int == product.id }) {
                amountChanged.toggle()
                productAmountDic[index]["amount"] = "\(newAmount)"
            }
        }
        //        .padding(.all,20)
        
    }
    
    
}



import SwiftUI
import SDWebImageSwiftUI

struct BusinessLinkCellIView: View {
    var product: productList
   
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
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.price ?? 0.0))
                                    .textModifier(.semiBold, 13, .black010202)
                                    .padding(.trailing,5)
                                    .strikethrough(true, color: .black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .fixedSize()
                                Image(.riyal)
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .foregroundColor(.gray8B8C86)
                                     .frame(width: 20)
                                     .padding(.trailing, 10)
                            }
                            .environment(\.layoutDirection, .rightToLeft)

                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.offerPrice ?? 0.0))
                                    .textModifier(.plain, 13, .black010202)
                                    .padding(.trailing,5)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
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
                        else {
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product.price ?? 0.0))
                                    .textModifier(.semiBold, 13, .black010202)
                                    .padding(.trailing,5)
                                    .strikethrough(true, color: .black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
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
                    
                    HStack {
                        Text(product.description ?? "")
                            .textModifier(.plain, 15, .gray616161)
                            .lineLimit(2)
                        Spacer()
                   
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
        
       
        //        .padding(.all,20)
        
    }
    
    
}


struct BusinessCreateLinkCellView: View {
    var product: [String: Any]
   
    var body: some View {
        ZStack {
            HStack {
                Image(uiImage:  product["image"]  as? UIImage ?? UIImage())
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
                        Text(Constants.shared.isAR ? product["name_ar"]  as? String ?? "" : product["name_en"]  as? String ?? "")
                            .textModifier(.semiBold, 15, .black010202)
                        Spacer()
                        if product["offer_price"] != nil  {
                            HStack {
                                HStack(spacing: 5){
                                    Text(String(format: "%.1f", product["price"] as? Double ?? 0.0))
                                        .textModifier(.semiBold, 13, .black010202)
                                        .padding(.trailing,5)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .strikethrough(true, color: .black)
                                        .fixedSize()
                                    Image(.riyal)
                                         .resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .foregroundColor(.gray8B8C86)
                                         .frame(width: 20)
                                         .padding(.trailing, 10)
                                }
                                .environment(\.layoutDirection, .rightToLeft)
                              
                                HStack(spacing: 5){
                                     Text(String(format: "%.1f", product["offer_price"] as? Double ?? 0.0))
                                         .textModifier(.plain, 13, .black010202)
                                         .padding(.trailing,5)
                                         .lineLimit(1)
                                         .minimumScaleFactor(0.8)
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
                        else {
                            HStack(spacing: 5){
                                Text(String(format: "%.1f", product["price"] as? Double ?? 0.0))
                                    .textModifier(.semiBold, 13, .black010202)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.trailing,5)
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
                    
                    HStack {
                        Text(Constants.shared.isAR ? product["description_ar"]  as? String ?? "" : product["description_en"]  as? String ?? "")
                            .textModifier(.plain, 15, .gray616161)
                            .lineLimit(2)
                        Spacer()
                   
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
        
       
        //        .padding(.all,20)
        
    }
    
    
}
