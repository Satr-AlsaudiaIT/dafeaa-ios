//
//  ClientPaymentInfoView.swift
//  Dafeaa
//
//  Created by AMNY on 04/03/2026.
//



import SwiftUI

// MARK: - ClientPaymentInfoView
struct ClientPaymentInfoView: View {
    let offerData: ShowOfferData
    @Binding var shippingPrice: Double
    var isLoggedIn: Bool

    private var product: productList? { offerData.products?.first }
    private var isFreeShipping: Bool { offerData.shipmentFree == 1 }
    private var shippingCompanies: [String] { offerData.shippingCompanies ?? [] }

    private var itemPrice: Double {
        product?.offerPrice ?? product?.price ?? 0
    }
    private var total: Double {
        isFreeShipping || !isLoggedIn ? itemPrice : itemPrice + shippingPrice
    }

    var body: some View {
        VStack(spacing: 12) {
            priceRow
            shippingRow
            if !isLoggedIn && !shippingCompanies.isEmpty {
                shippingCompaniesRow
            }
            Divider().padding(.horizontal, 14)
            totalRow
        }
        .padding(.vertical)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primaryF9CE29, lineWidth: 1)
        )
    }

    // MARK: - price
    private var priceRow: some View {
        HStack {
            Text("price_label".localized() + " :")
                .textModifier(.plain, 13, .grayAAAAAA)
            Spacer()
            riyalRow(value: itemPrice, color: .grayAAAAAA, size: 14)
        }
        .padding(.horizontal, 14)
    }

    // MARK: - shipping
    private var shippingRow: some View {
        HStack {
            Text("shipping_label".localized() + " :")
                .textModifier(.plain, 13, .grayAAAAAA)
            Spacer()
            if isFreeShipping {
                Text("free".localized())
                    .textModifier(.plain, 13, .grayAAAAAA)
            } else if !isLoggedIn {
                Text("unknown".localized())
                    .textModifier(.plain, 13, .grayAAAAAA)
            } else {
                riyalRow(value: shippingPrice, color: .grayAAAAAA, size: 14)
            }
        }
        .padding(.horizontal, 14)
    }

    // MARK: - shipping companies (guest only)
    private var shippingCompaniesRow: some View {
        HStack {
            Text("shipping_via".localized() + " :")
                .textModifier(.plain, 13, .grayAAAAAA)
            Spacer()
            Text(shippingCompanies.joined(separator: " , "))
                .textModifier(.plain, 13, .grayAAAAAA)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
    }

    // MARK: - total
    private var totalRow: some View {
        HStack {
            Text("total".localized() + " :")
                .textModifier(.bold, 14, .black222222)
            Spacer()
            riyalRow(value: total, color: .black222222, size: 14, bold: true)
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Riyal Helper
    @ViewBuilder
    private func riyalRow(value: Double, color: Color, size: CGFloat, bold: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(String(format: "%.2f", value))
                .textModifier(bold ? .bold : .plain, size, color)
                .fixedSize()
            Image(.riyal)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
                .frame(width: 14)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
