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
            Image(.process)
                .resizable()
                .frame(width: 48,height: 48)
                .cornerRadius(24)
            VStack(alignment: .leading, spacing: 8) {
                Text(process?.description ?? "")
                    .textModifier(.plain, 15, .black1E1E1E)
                Text(process?.date ?? "")
                    .textModifier(.extraBold, 14, .gray616161)
            }
            Spacer()
            HStack(spacing: 2) {
                Text(process?.amount ?? "")
                    .textModifier(.extraBold, 16,  process?.amount.first == "+" ? .green026C34 : .redD73D24)
                Text("ر.س".localized())
                    .textModifier(.plain, 16, process?.amount.first == "+" ? .green026C34 : .redD73D24)
            }
        }
    }
}

#Preview {
    ProcessComponent(process: HomeModelData(id: 0, description: "عملية دفع عبر دافع", amount: "+200" , date: "10-11-2023"))
}

