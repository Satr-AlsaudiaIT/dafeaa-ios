//
//  WithdrawComponent.swift
//  Dafeaa
//
//  Created by AMNY on 14/11/2024.
//


import SwiftUI
struct WithdrawComponent: View {
    @State var process: withdrawsData?
    @State var heighlightedId: Int = 0
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                ZStack {
                    Color(.black010202)
                    Image(uiImage: withdrawsStatusEnum(rawValue: process?.status ?? 0)?.image ?? UIImage())
                        .resizable()
                        .frame(width: 28,height: 28)
                }
                .frame(width: 48,height: 48)
                .cornerRadius(24)
                VStack(alignment: .leading, spacing: 8) {
                    HStack (spacing:3){
                        Text("withdrawProcess".localized())
                            .textModifier(.plain, 16, .black1E1E1E)
                      
                            Text(withdrawsStatusEnum(rawValue: process?.status ?? 0)?.text ?? "")
                                .textModifier(.plain, 12, withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                    }
                    HStack {
                        Text(process?.statusDate ?? "")
                            .textModifier(.plain, 14, .gray616161)
                        Spacer()
                        
                    }
                    //                     Spacer()
                    
                }
                HStack(spacing: 2) {
                    Text(String(format: "%.1f", process?.amount ?? 0))
                        .textModifier(.plain, 14, withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                    Image(.riyal)
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .foregroundColor(withdrawsStatusEnum(rawValue: process?.status ?? 0)?.color ?? .gray919191)
                         .frame(width: 15)
                         .padding(.trailing, 10)
                }
                .environment(\.layoutDirection, .rightToLeft)

            }
//            .padding(.all, 16)
        }
        .background(process?.id == heighlightedId ? Color.yellow : Color.clear) // Highlight if IDs match
        .border(process?.id == heighlightedId ? Color.blue : Color.clear, width: 2) // Optional: Add a border
//        .overlay{
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(.grayDADADA),lineWidth: 1)
//        }
    }
}
#Preview {
    WithdrawComponent()
}



enum withdrawsStatusEnum:Int {
    case pending = 1
    case rejected = 2
    case done = 3
    
    var text:String {
        switch self {
        case .pending:
            return "pending".localized()
        case .rejected:
            return "rejected".localized()
        case .done:
            return "done".localized()
        }
    }
    var color:Color {
        switch self {
        case .pending:
            return .gray616161
        case .rejected:
            return .redEE002B
        case .done:
            return .green026C34
        }
    }
    var image : UIImage? {
        switch self {
        case .pending:
            return .pendongProcess
        case .rejected:
            return .rejectedWithdraw
        case .done:
            return .withdrawProcess
        }
    }
}
