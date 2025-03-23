//
//  SubscribtionCell.swift
//  Dafeaa
//
//  Created by M.Magdy on 20/10/2024.
//

import SwiftUI

struct SubscriptionCell: View {
    var isSelected: Bool
    var subscriptionData: SubscriptionModelData
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        let val = subscriptionData.price ?? 0
                        HStack(spacing: 5) {
                            Text(String(format: "%.2f", val))
                                .textModifier(.plain, 28, .black222222)
                            Image(.riyal)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray8B8C86)
                                .frame(width: 20)
                                .padding(.trailing, 10)
                            Text("/ " + "month".localized())
                                .textModifier(.plain, 15, .black222222)
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        Spacer()
                    }
                    .padding(.bottom,10)
                    HStack {
                        let text = subscriptionData.text ?? ""
                        let minProduct = "(\(subscriptionData.minProduct ?? 0)"
                        let maxProduct = "\(subscriptionData.maxProduct ?? 0)"
                        let minMaxText = minProduct + " - " + maxProduct + " " + "productUnit".localized() + ")"
                        Text(text + " " + minMaxText )
                            .textModifier(.plain, 15, .black222222)
                    }
                }
                
                Image(isSelected ? .checkBoxFilled : .checkBoxEmpty)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .animation(.easeInOut, value: isSelected)
            }
            .padding(.all, 24)
        }
        .background(isSelected ? Color(.primary).opacity(0.1) : .grayF6F6F6)
        .cornerRadius(15)
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color(.primary) : Color.black.opacity(0.1), lineWidth: 1)
        }
    }
}

//#Preview {
//    SubscribtionCell(isSelected: false, subscriptionData: SubscriptionModelData(id: 1, price: 199, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"))
//}



