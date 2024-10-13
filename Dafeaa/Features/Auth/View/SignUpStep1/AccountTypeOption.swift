//
//  AccountTypeOption.swift
//  Dafeaa
//
//  Created by M.Magdy on 07/10/2024.
//

import SwiftUI

// Account type options
enum AccountTypeOption {
    case companyOrMerchant
    case individual
    case none
    
    func returnedInt() -> (Int){
        switch self {
        case .individual : 1
        case .companyOrMerchant : 2
        case .none : 0
        }
    }
}

// Custom view for each account option
struct AccountOptionView: View {
    var optionType: AccountTypeOption
    var isSelected: Bool
    var isGrayOut: Bool
    var onSelect: () -> Void
    
    // Custom icon and texts based on option type
    private var iconImage: UIImage {
        switch optionType {
        case .companyOrMerchant:
            return .companyOrMerchant
        case .individual:
            return .individual
        case .none:
            return .eyeSlash
        }
    }
    
    private var titleText: String {
        switch optionType {
        case .companyOrMerchant:
            return "companyOrMerchant"
        case .individual:
            return "individual"
        case .none:
            return ""
        }
    }
    
    private var descriptionText: String {
        switch optionType {
        case .companyOrMerchant:
            return "companyOrMerchantDesc"
        case .individual:
            return "individualDesc"
        case .none:
            return ""
        }
    }
    
    // Background and border color based on selection
    private var backgroundColor: Color {
        isSelected ? Color(.primary) : Color(.grayF6F6F6)
    }
    
    private var borderColor: Color {
        isSelected ? Color(.primary) : Color(.grayF6F6F6)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text(titleText.localized())
                    .textModifier(.plain, 18, .black222222)
                    .lineLimit(1)
                Text(descriptionText.localized())
                    .textModifier(.plain, 12, Color(.black010202).opacity(0.8))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(uiImage: iconImage)
                .resizable()
                .frame(width: 80, height: 80)
                .grayscale(isGrayOut ? 1.0 : 0.0)
            
        }.padding(24).frame(height: 112)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
    }
}
