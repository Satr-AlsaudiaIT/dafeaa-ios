//
//  ShippingCompanyDropdownMulti.swift
//  Dafeaa
//
//  Created by AMNY on 11/01/2026.
//

import SwiftUI

struct ShippingCompanyDropdownMulti: View {
    let titleKey: String
    @Binding var selected: [ShippingCompany]
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized())
                .textModifier(.plain, 14, .black1E1E1E)

            ZStack(alignment: .topLeading) {
                HStack(spacing: 8) {
                    
                    ZStack(alignment: .leading) {
                        if selected.isEmpty {
                            Text("select_shipping_companies".localized())
                                .textModifier(.plain, 14, Color.gray.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        
                        // Selected items scrollview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selected) { company in
                                    SelectedChip(company: company) {
                                        selected.removeAll { $0 == company }
                                    }
                                }
                            }
                            .padding(.leading, 8)
                        }
                    }

                    Spacer()

                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.primary)
                        .padding(.trailing, 12)

                }
                .frame(height: 48)
                .background(Color(.grayF6F6F6))
                .cornerRadius(5)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { isOpen.toggle() } }

                if isOpen {
                    VStack(spacing: 0) {
                        ForEach(ShippingCompany.allCases) { company in
                            Button {
                                toggle(company)
                            } label: {
                                HStack {
                                    Text(company.displayName.lowercased())
                                        .textModifier(.plain, 16, .black1E1E1E)

                                    Spacer()

                                    if selected.contains(company) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.primaryF9CE29)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .background(
                                    selected.contains(company)
                                    ? Color.primaryF9CE29.opacity(0.08)
                                    : Color.white
                                )
                            }

                            if company != ShippingCompany.allCases.last {
                                Divider().opacity(0.15)
                            }
                        }
                    }
                    .background(Color(.grayF6F6F6))
                    .cornerRadius(5)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                    .padding(.top, 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isOpen ? Color(.primary) : Color.clear, lineWidth: 1)
                    )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isOpen ? Color(.primary) : Color.clear, lineWidth: 1)
            )
        }
    }

    private func toggle(_ company: ShippingCompany) {
        if selected.contains(company) {
            selected.removeAll { $0 == company }
        } else {
            selected.append(company)
        }
    }
}

private struct SelectedChip: View {
    let company: ShippingCompany
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(company.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 16)
                .cornerRadius(2)
            
            Text(company.displayName.lowercased())
                .textModifier(.plain, 14, .white)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(.clear)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(Color(company.assetName))
        .cornerRadius(5)
    }
}
