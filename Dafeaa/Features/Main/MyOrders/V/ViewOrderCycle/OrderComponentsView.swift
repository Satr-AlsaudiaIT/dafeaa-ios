//
//  OrderComponentsView.swift
//  Dafeaa
//
//  Created by AMNY on 26/10/2024.
//


import SwiftUI
// Components for QR Code, Order Item, Payment Info, and Address Views

struct QRCodeView: View {
    var text: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        if let qrImage = generateQRCode(from: text) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200 ,height: 200)
        } else {
            Text("QR code generation failed")
                .foregroundColor(.red)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

struct OrderItemView: View {
    var itemName  : String
    var price     : Double
    var amount    : Int
    var isLast    : Bool
    
    var body: some View {
        VStack(alignment:.leading, spacing: 16){
            HStack {
                Image(.process)
                    .resizable()
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 8) {
                    Text(itemName)
                        .textModifier(.plain, 14,  .black222222)
                    HStack {
                        Text(String(format: "%.2f %@", price, "SAR".localized()))
                            .textModifier(.plain, 12, .gray8B8C86)
                        Spacer()
                        Text("amount: ".localized() + "\(amount)" )
                            .textModifier(.plain, 12, .gray8B8C86)
                    }
                }
            }
            if !isLast {
                Divider()
                    .foregroundColor( Color(.black).opacity(0.10))
            } else {
                Divider().hidden()
            }
        }.padding(.top,16)
    }
}

struct PaymentInfoView: View {
    var breakdown: PaymentDetails?
    @State var isMerchantOfferDetails: Bool = false
    @Binding var itemsPrice: Double
    @State var isShowDetails: Bool = false
    var body: some View {
        ZStack() {
//            Text("paymentWay".localized())
//                .textModifier(.plain, 14, .black222222)
//            Text("buyWithDafea".localized())
//                .textModifier(.plain, 12, .grayAAAAAA)
//            
//            Divider()
//                .foregroundColor(Color(.black).opacity(0.10))
//                .padding(.vertical, 12)
            
            // Use PriceRowView for each item in breakdown
            VStack(alignment: .leading, spacing: 8) {
//                if !isMerchantOfferDetails {
                    PriceRowView(title: "product".localized(), price: itemsPrice)
//                }
                PriceRowView(title: "delaviryAndRecive".localized(), price: breakdown?.deliveryPrice ?? 0)
//                if !isMerchantOfferDetails {
                    PriceRowView(title: "totalBeforeTax".localized(), price: ( (breakdown?.deliveryPrice ?? 0) + (itemsPrice)))
//                }
                PriceRowView(title: "tax".localized(), price: breakdown?.tax ?? 0,isTax: isShowDetails ? false : true)
//                if !isMerchantOfferDetails {
                    Divider()
                        .foregroundColor( Color(.black).opacity(0.10))
                    // Total row
                   if isShowDetails {
                       let totalPrice: Double = (breakdown?.deliveryPrice ?? 0.0) + (itemsPrice)  + (breakdown?.tax ?? 0.0)
                       PriceRowView(title: "total".localized(), price: totalPrice, isTotal: true)

                    }
                    else {
                        let taxPrice = (itemsPrice) * (breakdown?.tax ?? 0.0) / 100
                        let totalPrice: Double = (breakdown?.deliveryPrice ?? 0.0) + (itemsPrice) + taxPrice
                        PriceRowView(title: "total".localized(), price: totalPrice, isTotal: true)
                    }
//                }
            }
            .padding(.all,10)
                   
        }
        .onChange(of: itemsPrice, { oldValue, newValue in
            print(itemsPrice,"itemPriccccc")
        })
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.grayAAAAAA), lineWidth: 0.4)
        }
        .padding(.vertical, 16)
    }
}

struct PriceRowView: View {
    var title: String
    var price: Double
    var isTotal: Bool = false
    var isTax: Bool = false
    var body: some View {
        HStack {
            Text(title)
                .textModifier(.plain, 12, isTotal ? .black222222 : .grayAAAAAA)
            Spacer()
            Text(String(format: "%.2f %@", price, isTax ? "%" : "RS".localized()))
                .textModifier(.plain, 12, isTotal ? .black222222 : .grayAAAAAA)
        }
    }
}

struct AddressView: View {
    var name: String
    var address: String
    var phone: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("clientName:".localized() + name)
                    .textModifier(.plain, 12, .gray979797)
                Text("address".localized()+": \(address)")
                    .textModifier(.plain, 12, .gray979797)
                Text("clientPhone:".localized() + "\(phone)")
                    .textModifier(.plain, 12, .gray979797)
            }
            Spacer()
        }.padding(.horizontal,12)
        .padding(.vertical,16)
    }
}
