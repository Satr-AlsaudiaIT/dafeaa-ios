//
//  ShippingCompanySelectionView.swift
//  Dafeaa
//
//  Created by AMNY on 12/01/2026.
//

import SwiftUI


// MARK: - ShippingCompanySelectionView
struct ShippingCompanySelectionView: View {
    @Binding var selectedCompany: String?
    let availableCompanies: [String]
    @State var showRadioButtons: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("shippingCompany".localized())
                .textModifier(.plain, 16, .black010202)
            
            VStack(spacing: 12) {
                ForEach(ShippingCompany.allCases, id: \.self) { company in
                    let companyString = company.rawValue
                    let isAvailable = availableCompanies.contains { $0.lowercased() == companyString.lowercased() }
                    
                    ShippingCompanyRow(
                        company: company,
                        isSelected: selectedCompany?.lowercased() == companyString.lowercased(),
                        isEnabled: isAvailable,
                        showRadioButtons: showRadioButtons,
                        action: {
                            if isAvailable {
                                selectedCompany = companyString
                            }
                        }
                    )
                }
            }
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryF9CE29, lineWidth: 1)
            )
        }
        
        .onAppear {
            if selectedCompany == nil, let firstCompany = availableCompanies.first {
                selectedCompany = firstCompany
            }
        }
    }
}

// MARK: - ShippingCompanyRow
struct ShippingCompanyRow: View {
    let company: ShippingCompany
    let isSelected: Bool
    let isEnabled: Bool
    let showRadioButtons: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if showRadioButtons {
                    ZStack {
                        Circle()
                            .stroke(
                                isEnabled ? (isSelected ? Color.primaryF9CE29 : Color.grayDADADA) : Color.grayDADADA.opacity(0.5),
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)
                        
                        if isSelected && isEnabled {
                            Circle()
                                .fill(Color.primaryF9CE29)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                Image(company.assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .opacity(isEnabled ? 1.0 : 0.4)
                
                Text(company.displayName)
                    .textModifier(.plain, 15, isEnabled ? .black222222 : .grayAAAAAA)
                
                Spacer()
                
                if !isEnabled {
                    Text("notAvailable".localized())
                        .textModifier(.plain, 12, .grayAAAAAA)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.grayDADADA.opacity(0.3))
                        )
                }
            }
            .padding(4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}
