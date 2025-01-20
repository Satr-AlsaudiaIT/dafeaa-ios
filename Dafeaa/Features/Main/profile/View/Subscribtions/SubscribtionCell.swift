//
//  SubscribtionCell.swift
//  Dafeaa
//
//  Created by M.Magdy on 20/10/2024.
//

import SwiftUI

struct SubscribtionCell: View {
    var isSelected: Bool
    var subscribtionData: SubscribtionModelData
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        let val = subscribtionData.percentage ?? 0.0 == 0 ? Double(subscribtionData.price ?? 0) : (subscribtionData.percentage ?? 0.0)
                        let mark = subscribtionData.percentage ?? 0.0 == 0 ? "" : "%"
                        Text("\(val)" + "\(mark)")
                            .textModifier(.bold, 28, .black222222)
                        Text(subscribtionData.forUse ?? "")
                            .textModifier(.plain, 15, .black222222)
                        Spacer()
                    }
                    .padding(.bottom,10)
                    HStack {
                        Text(subscribtionData.description ?? "")
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

#Preview {
    SubscribtionCell(isSelected: false, subscribtionData: SubscribtionModelData(id: 1, price: 199, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"))
}



