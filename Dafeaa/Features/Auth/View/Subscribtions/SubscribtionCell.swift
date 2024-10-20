//
//  SubscribtionCell.swift
//  Dafeaa
//
//  Created by M.Magdy on 20/10/2024.
//

import SwiftUI

struct SubscribtionCell: View {
    @State var isSelected: Bool = false
    @State var subscribtionData:  SubscribtionModelData
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(subscribtionData.percentage ?? 0 == 0 ? subscribtionData.price ?? 0 : subscribtionData.percentage ?? 0 )")
                            .textModifier(.extraBold, 28, .black222222)
                        Text(subscribtionData.forUse ?? "")
                            .textModifier(.plain, 15, .black222222)
                        Spacer()
                    }
                    HStack {
                        Text(subscribtionData.forUse ?? "")
                            .textModifier(.plain, 15, .black222222)
                    }
                }
                
                Image(isSelected ? .checkBoxFilled : .checkBoxEmpty)
                    .resizable()
                    .frame(width:20,height:20)
                    .animation(.easeInOut)
                
                
            }
            .padding(.all,24)
        }
        .background(isSelected ? Color(.primary).opacity(0.1) : .grayF6F6F6)
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color(.primary) : Color.black.opacity(0.1), lineWidth: 1)
        }
    }
}

#Preview {
    SubscribtionCell( subscribtionData: SubscribtionModelData(id: 1, price: 199, percentage: 0, forUse: "ر.س/شهري", describtion: "مشاريع متوسطة (100-500 منتج)"))
}



