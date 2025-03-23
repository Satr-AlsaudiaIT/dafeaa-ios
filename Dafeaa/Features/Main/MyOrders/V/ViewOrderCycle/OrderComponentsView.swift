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
        
            
            if let qrCodeImage = qrcodeImage(string: text) {
                // Use the qrCodeImage with the logo
                
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200 ,height: 200)
            }
       
        
        
//        if let qrImage = generateQRCode(from: text) {
//            Image(uiImage: qrImage)
//                .interpolation(.none)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200 ,height: 200)
//        } else {
//            Text("QR code generation failed")
//                .foregroundColor(.red)
//        }
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
                        
                        HStack(spacing: 5) {
                            Text(String(format: "%.2f %@", price))
                                .textModifier(.plain, 12, .gray8B8C86)
                            Image(.riyal)
                                 .resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .foregroundColor(.gray8B8C86)
                                 .frame(width: 20)
                                 .padding(.trailing, 10)
                        }
                        .environment(\.layoutDirection, .rightToLeft)
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
    @State var itemsCommissionValue: Double = 0
    @State var isCalculateCommission: Bool = true
    var body: some View {
        ZStack() {

            VStack(alignment: .leading, spacing: 8) {
                
                PriceRowView(title: "product".localized(), price: itemsPrice)
                
                PriceRowView(title: "commissionVal".localized(), price: itemsCommissionValue)
//                PriceRowView(title: "totalBeforeTax".localized(), price: ( (itemsCommissionValue) + (itemsPrice)))

                    Divider()
                        .foregroundColor( Color(.black).opacity(0.10))
                    // Total row
                   if isShowDetails {
                       PriceRowView(title: "total".localized(), price: ( (itemsCommissionValue) + (itemsPrice)), isTotal: true)
                    }
                    else {
//                        let taxPrice = (itemsPrice) * (breakdown?.tax ?? 0.0) / 100
//                        let totalPrice: Double = (breakdown?.deliveryPrice ?? 0.0) + (itemsPrice)
                        PriceRowView(title: "total".localized(), price: ( (itemsCommissionValue) + (itemsPrice)), isTotal: true)
                    }
//                }
            }
            .padding(.all,10)
                   
        }
        .onChange(of: itemsPrice, { oldValue, newValue in
            print(itemsPrice,"itemPriccccc")
            if isCalculateCommission {
                itemsCommissionValue = (newValue * (breakdown?.commission ?? 0) )
                itemsCommissionValue = itemsCommissionValue > breakdown?.commissionMaxPrice ?? 0 ? breakdown?.commissionMaxPrice ?? 0 : itemsCommissionValue
            }
            else {
                itemsCommissionValue = breakdown?.commission ?? 0
            }
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
            if isTax {
                Text(String(format: "%.2f %@", price,  "%"))
                    .textModifier(.plain, 12, isTotal ? .black222222 : .grayAAAAAA)
                    .padding(.trailing, Constants.shared.isAR ? 35 : 0)
            }
            else {
                HStack(spacing: 5) {
                    Text(String(format: "%.2f", price))
                        .textModifier(.plain, 12, isTotal ? .black222222 : .grayAAAAAA)
                        .padding(.leading,10)
                    Image(.riyal)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray8B8C86)
                        .frame(width: 20)
                        .padding(.trailing, 10)
                }
                .environment(\.layoutDirection, .rightToLeft)

            }
        
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




import UIKit
import CoreImage
import QRCode



func qrcodeImage (string: String) -> UIImage?{
    // Generate the QR code
     do {
         let doc = try QRCode.Document(utf8String: string)

         doc.design.shape.eye = QRCode.EyeShape.RoundedPointingIn()
         
         doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath()
         let image = UIImage(named: "logowithWithBackGround") ?? UIImage()

         // Centered square logo
         doc.logoTemplate = QRCode.LogoTemplate(
            image: image.cgImage!,
            path: CGPath(rect: CGRect(x: 0.4, y: 0.4, width: 0.22, height: 0.24), transform: nil),
            inset: 2
         )

         let logoQRCode = try doc.platformImage(dimension: 300, dpi: 512)
         return logoQRCode
     } catch {
         print("Failed to create QRCode document: \(error)")
         return UIImage()
     }
}

 func generateQRCodeWithLogo(from string: String, withLogo logo: UIImage?) -> UIImage? {
   
    let filter = CIFilter(name: "CIQRCodeGenerator")!
    filter.setValue(Data(string.utf8), forKey: "inputMessage")
    
    if let outputImage = filter.outputImage {
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        
        // Create a CGImage from the CIImage
        let context = CIContext()
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            var qrCodeImage = UIImage(cgImage: cgImage)
            
            // If a logo is provided, overlay it on the QR code
            if let logo = logo {
                qrCodeImage = overlayLogo(on: qrCodeImage, with: logo)
            }
            
            return qrCodeImage
        }
    }
    
    return nil
}

 func overlayLogo(on qrCodeImage: UIImage, with logo: UIImage) -> UIImage {
    let qrCodeSize = qrCodeImage.size
    let logoSize = CGSize(width: 55, height: 65)
    UIGraphicsBeginImageContextWithOptions(qrCodeSize, false, UIScreen.main.scale)
    
    qrCodeImage.draw(in: CGRect(origin: .zero, size: qrCodeSize))
    
    let logoX = (qrCodeSize.width - logoSize.width) / 2
    let logoY = (qrCodeSize.height - logoSize.height) / 2
    let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
    
    logo.draw(in: logoRect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage ?? qrCodeImage
}
