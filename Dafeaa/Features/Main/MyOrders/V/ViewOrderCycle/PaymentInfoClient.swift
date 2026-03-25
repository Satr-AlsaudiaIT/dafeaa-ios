//
//  PaymentInfoClient.swift
//  Dafeaa
//
//  Created by AMNY on 09/03/2026.
//

import SwiftUI

// MARK: - PaymentInfoClient
struct PaymentInfoClient: View {

    let data: OrderData

    private var isFreeShipping: Bool   { data.isFreeShipping == true }
    private var orderPrice:     Double { data.orderPrice     ?? 0 }
    private var shippingCost:   Double { data.shippingCost   ?? 0 }  // 0 if free, fees if not
    private var totalPrice:     Double { orderPrice + shippingCost }

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            // MARK: Card
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    headerView
                    Divider().padding(.horizontal).padding(.vertical, 6)
                    priceRow
                    shippingRow
                    Divider().padding(.horizontal)
                    totalRow
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

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("paymentWay".localized())
                    .textModifier(.plain, 15, .black000000)
                Text("dafeaa_payment_way".localized() + ":")
                    .textModifier(.plain, 13, .grayAAAAAA)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Rows

    private var priceRow: some View {
        HStack {
            Text("product_label".localized() + ":")
                .textModifier(.plain, 13, .grayAAAAAA)
            Spacer()
            riyalRow(value: orderPrice, color: .grayAAAAAA, size: 14)
        }
        .padding(.horizontal, 14)
    }

    /// Always shown — value is 0 when free shipping, actual cost when buyer pays
    private var shippingRow: some View {
        HStack {
            Text("shipping_delivery_label".localized() + " :")
                .textModifier(.plain, 13, .grayAAAAAA)
            Spacer()
            riyalRow(
                value: shippingCost,
                color: .grayAAAAAA,
                size: 13,
                forceSign: true
            )
        }
        .padding(.horizontal, 14)
    }

    private var totalRow: some View {
        HStack {
            Text("total".localized() + " :")
                .textModifier(.bold, 14, .black000000)
            Spacer()
            riyalRow(value: totalPrice, color: .black000000, size: 14, bold: true)
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
