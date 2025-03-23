//
//  ProcessComponent.swift
//  Dafeaa
//
//  Created by M.Magdy on 25/10/2024.
//

import SwiftUI

struct ProcessComponent: View {
    @State var process: HomeModelData?
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                Color(.black010202)
                Image(process?.amount?.first == "+" ? .addBlanceProcess : .withdrawProcess)
                    .resizable()
                    .frame(width: 28,height: 28)
            }
            .frame(width: 48,height: 48)
            .cornerRadius(24)
            VStack(alignment: .leading, spacing: 8) {
                Text(process?.description ?? "")
                    .textModifier(.plain, 15, .black1E1E1E)
                Text(process?.date ?? "")
                    .textModifier(.plain, 17, .gray616161)
            }
            Spacer()
            HStack(spacing: 2) {
                Text(process?.amount ?? "")
                    .textModifier(.plain, 18,  process?.amount?.first == "+" ? .green026C34 : .redD73D24)
                Image(.riyal)
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .foregroundColor(process?.amount?.first == "+" ? .green026C34 : .redD73D24)
                     .frame(width: 15)
                     .padding(.trailing, 10)
            }
            .environment(\.layoutDirection, .rightToLeft)
            
        }
    }
}

#Preview {
    ProcessComponent(process: HomeModelData(id: 0, description: "عملية دفع عبر دافع", amount: "+200" , date: "10-11-2023"))
}

