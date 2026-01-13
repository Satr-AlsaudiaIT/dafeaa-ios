//
//  PaymentInfoViewWithShipping.swift
//  Dafeaa
//
//  Created by AMNY on 13/01/2026.
//

import SwiftUI


struct PaymentInfoViewWithShipping: View {
    var breakdown: PaymentDetails?
    @State var isMerchantOfferDetails: Bool = false
    @Binding var itemsPrice: Double
    @State var totalPrice : Double = 0
    @Binding var deliveryPrice: Double
    @State var isShowDetails: Bool = false
    @State var itemsCommissionValue: Double = 0
    @State var isCalculateCommission: Bool = true
   
    var body: some View {
        ZStack() {

            VStack(alignment: .leading, spacing: 8) {
                
                PriceRowView(title: "product".localized(), price: itemsPrice)
                
                PriceRowView(title: "commissionVal".localized(), price: itemsCommissionValue)
                if deliveryPrice != 0  {
                    PriceRowView(title: "deliveryPrice".localized(), price: deliveryPrice)
                }


                    Divider()
                        .foregroundColor( Color(.black).opacity(0.10))
                    // Total row
                   if isShowDetails {
                       PriceRowView(title: "total".localized(), price: totalPrice, isTotal: true)
                    }
                    else {
//                        let taxPrice = (itemsPrice) * (breakdown?.tax ?? 0.0) / 100
//                        let totalPrice: Double = (breakdown?.deliveryPrice ?? 0.0) + (itemsPrice)
                        PriceRowView(title: "total".localized(), price: ( (itemsCommissionValue) + (itemsPrice) + (deliveryPrice)), isTotal: true)
                    }
//                }
            }
            .padding(.all,10)
                   
        }
        .onChange(of: itemsPrice, { oldValue, newValue in
            print(itemsPrice,"itemPriccccc")
            if isCalculateCommission {
                itemsCommissionValue = (newValue * (breakdown?.commission ?? 0) / 100 )
                itemsCommissionValue = itemsCommissionValue > breakdown?.commissionMaxPrice ?? 0 ? breakdown?.commissionMaxPrice ?? 0 : itemsCommissionValue
            }
            else {
                itemsCommissionValue = breakdown?.commission ?? 0
            }
        })
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.grayAAAAAA), lineWidth: 0.4)
        }
        .padding(.vertical, 16)
    }
}
