//
//  WithdrawComponent.swift
//  Dafeaa
//
//  Created by AMNY on 14/11/2024.
//


import SwiftUI
struct WithdrawComponent: View {
    @State var process: withdrawsData?
    
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                Image(.process)
                    .resizable()
                    .frame(width: 48,height: 48)
                    .cornerRadius(24)
                VStack(alignment: .leading, spacing: 8) {
                    HStack (spacing:3){
                        Text("withdrawProcess".localized())
                            .textModifier(.bold, 15, .black1E1E1E)
                        Text(withdrawsStatusEnum(rawValue: process?.status ?? 0)?.text ?? "")
                            .textModifier(.plain, 15, withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                        
                    }
                    HStack {
                        Text(process?.statusDate ?? "")
                            .textModifier(.bold, 14, withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                        Spacer()
                        
                    }
                    //                     Spacer()
                    
                }
                HStack(spacing: 2) {
                    Text(String(format: "%.1f", process?.amount ?? 0))
                        .textModifier(.bold, 14, withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                    Image(.riyal)
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .foregroundColor(.gray8B8C86)
                         .frame(width: 20)
                         .padding(.trailing, 10)
                }
                .environment(\.layoutDirection, .rightToLeft)

            }
            .padding(.all, 16)
        }
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.grayDADADA),lineWidth: 1)
        }
    }
}
#Preview {
    WithdrawComponent()
}



enum withdrawsStatusEnum:Int {
    case pending = 1
    case progress = 2
    case done = 3
    
    var text:String {
        switch self {
        case .pending:
            return "pending".localized()
        case .progress:
            return "progress".localized()
        case .done:
            return "done".localized()
        }
    }
    var color:Color {
        switch self {
        case .pending:
            return .gray616161
        case .progress:
            return .primary
        case .done:
            return .green026C34
        }
    }
}
