//
//  ProcessComponent.swift
//  Dafeaa
//
//  Created by M.Magdy on 25/10/2024.
//

import SwiftUI
enum WalletStatusEnum: Int {
    case add = 1
    case sub
}
enum TransactionType: Int, Codable {
    case charge = 1
    case order = 2
    case cancel = 3
    case withdraw = 4
    case transfer = 5
    
    var imageResource: ImageResource {
          switch self {
          case .withdraw:
              return .orderFrom
          case .transfer:
              return .transfer
          default:
              return .orderTo
          }
      }
}
struct ProcessComponent: View {
    @State var process: HomeModelData?
    @State private var isExpanded: Bool = false // <-- for toggle expand
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                ZStack {
                    Color(.black010202)
                    
                    
                    Image(process?.type != 3 ? TransactionType(rawValue: process?.type ?? 1)?.imageResource ?? .orderFrom : (process?.status == 1 ? .orderFrom : .orderTo ))
                        .resizable()
                        .frame(width: 28, height: 28)

                }
                .frame(width: 48, height: 48)
                .cornerRadius(24)

                VStack(alignment: .leading, spacing: 3) {
                    Button {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(process?.description ?? "")
                                .textModifier(.plain, 15, .black1E1E1E)
                                .lineLimit(1)
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .resizable()
                                .frame(width: 12, height: 6)
                                .foregroundColor(.gray)
                        }
                    }
                    if isExpanded {
                        if let toName = process?.toName, toName != "" {
                            HStack {
                                Text(process?.status ==  WalletStatusEnum.sub.rawValue ? "transferTo".localized() : "transferFrom".localized())
                                    .textModifier(.plain, 13, .gray616161)
                                Text(toName)
                                    .textModifier(.plain, 13, .gray616161)
                            }
                        }
                        if let toPhone = process?.toPhone, toPhone != "" {
                            HStack {
                                Text("phoneNumber".localized() + ":")
                                    .textModifier(.plain, 13, .gray616161)
                                Text(toPhone)
                                    .textModifier(.plain, 13, .gray616161)
                            }
                        }
                        if let refNum = process?.transactionId, refNum != ""  {
                            VStack (alignment: .leading){
                                Text("referenceNumber".localized() + ":")
                                    .textModifier(.plain, 13, .gray616161)
                                Text(refNum)
                                    .textModifier(.plain, 13, .gray616161)
                            }
                        }
                        
                    }
                    
                    Text(process?.date?.to12HourDateFormat() ?? "")
                        .textModifier(.plain, 13, .gray616161)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(process?.amount ?? "")
                        .textModifier(.plain, 18, process?.status == WalletStatusEnum.add.rawValue ? .green026C34 : .redD73D24)
                    
                    Image(.riyal)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(process?.status == WalletStatusEnum.add.rawValue ? .green026C34 : .redD73D24)
                        .frame(width: 15)
                        .padding(.trailing, 10)
                }
                .environment(\.layoutDirection, .rightToLeft)
            }
          
        }
        .padding(.vertical, 8)
    }
}


//#Preview {
//    ProcessComponent(process: HomeModelData(id: 0, description: "عملية دفع عبر دافع", amount: "+200" , date: "10-11-2023"))
//}

