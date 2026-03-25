//
//  PaymentInfoOwner.swift
//  Dafeaa
//
//  Created by AMNY on 08/03/2026.
//

import SwiftUI

struct PaymentInfoOwner: View {

    let data: OrderData

    @State private var showPriceTooltip: Bool = false

    private var isFreeShipping:      Bool   { data.isFreeShipping == true }
    private var orderPrice:          Double { data.orderPrice      ?? 0 }
    private var priceCommission:     Double { data.commissionValue  ?? 0 }
    private var totalShippingCost:   Double { data.shippingCost     ?? 0 }
    private var netValue:            Double { data.netValue         ?? 0 }

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            // MARK: Title
            Text("payment_info_title".localized())
                .textModifier(.bold, 16, .black222222)
                .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: Card
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    headerView
                    Divider().padding(.horizontal).padding(.vertical,6)
                    priceRow
                    commissionRow
                    if isFreeShipping {
                        shippingCostRow
                    }
                    Divider().padding(.horizontal)
                    netRow
                   
                }
                .padding(.vertical)
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryF9CE29, lineWidth: 1)
            )
        }
    }

    // MARK: - Rows

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading,spacing: 10) {
                Text("paymentWay".localized())
                    .textModifier(.plain, 15, .black000000)
                Text("dafeaa_payment_way".localized() + ":")
                    .textModifier(.plain, 13, .grayAAAAAA)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
    }
    
    private var priceRow: some View {
        HStack {
            Text("product_label".localized() + ":")
                    .textModifier(.plain, 13, .grayAAAAAA)
            
            Spacer()
            riyalRow(value: orderPrice, color: .grayAAAAAA, size: 14)
        }
        .padding(.horizontal, 14)
    }

    private var commissionRow: some View {
        HStack {
            Text("service_fees_label".localized() + " :")
                .textModifier(.bold, 13, Color(hex: "E53935"))
            Spacer()
            riyalRow(
                value: -priceCommission,
                color: Color(hex: "E53935"),
                size: 13,
                forceSign: true
            )
        }
        .padding(.horizontal, 14)
    }

    /// Shown ONLY when isFreeShipping == true
    private var shippingCostRow: some View {
        HStack {
            Text("shipping_delivery_label".localized() + " :")
                .textModifier(.bold, 13, Color(hex: "E53935"))
            Spacer()
            riyalRow(
                value: -totalShippingCost,
                color: Color(hex: "E53935"),
                size: 13,
                forceSign: true
            )
        }
        .padding(.horizontal, 14)
    }

    private var netRow: some View {
        HStack {
            Text("net_label".localized() + " :")
                .textModifier(.plain, 14,  .black000000)
            Spacer()
            riyalRow(
                value: netValue,
                color: netValue < 0 ? Color(hex: "E53935") : .black000000,
                size: 14,
                bold: true
            )
        }
        .padding(.horizontal, 14)
    }



    // MARK: - Helpers

    @ViewBuilder
    private func riyalRow(
        value: Double,
        color: Color,
        size: CGFloat,
        bold: Bool = false,
        forceSign: Bool = false
    ) -> some View {
        HStack(spacing: 4) {
            Text(forceSign
                 ? (value < 0 ? String(format: "%.2f", value) : String(format: "+%.2f", value))
                 : String(format: "%.2f", value))
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
