//
//  OrderLinkDetailsViewNew.swift
//  Dafeaa
//
//  Created by AMNY on 10/11/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct OrderLinkDetailsViewNew: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var code: String = ""
    @State var offerData: ShowOfferData?
    @StateObject var viewModel = OrdersVM()
    @State var totalPrice: Double = 0
    @State var amountChanged: Bool = false
    @State var addressId:Int = Constants.selectedAddressId
    @State var address: String = Constants.selectedAddress
    @State var isNavigateToAddress: Bool = false
    @State var showingProductDetails: Bool = false
    @State var selectedShippingCompany: String?
    
    @State var selectedProduct: productList = productList(id: 3, images: [ImageModel(file: "ww")], name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000, amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 1, remainingQuantity: 1)
    var linkDetails: ShowOfferData  {
        return viewModel.offersData ?? ShowOfferData(
            id: 0,
            name: "",
            code: "",
            description: "",
            clientId: 1,
            deliveryPrice: 1,
            taxPrice: 1,
            products: [],
            status: 0,
            commissionRatio: "",
            maxCommissionValue: "",
            shippingCompanies: [],
            address: nil,
            shipmentFree: nil,
            hasTaxRecord: nil,
            priceCommission: nil,
            shippingCommission: nil,
            seller: nil
        )

    }
    @State var status: Int = 0
    @State var toast: FancyToast? = nil
    
    @State private var isEditTapped : Bool = false
    @State private var  selectedImage: String?
    @State private var showSelectedImage: Bool = false
    @State var quantity : String = ""
    var isAbleToEdit : Bool = false
    var isMerchant : Bool = false
    @State var showPopOverCopy : Bool = false
    @State var showPopOverShare : Bool = false

    var offerDataView: ShowOfferData {
        return viewModel.offersData ?? ShowOfferData(
            id: 0,
            name: "",
            code: "",
            description: "",
            clientId: 1,
            deliveryPrice: 1,
            taxPrice: 1,
            products: [],
            status: 0,
            commissionRatio: "",
            maxCommissionValue: "",
            shippingCompanies: [],
            address: nil,
            shipmentFree: nil,
            hasTaxRecord: nil,
            priceCommission: nil,
            shippingCommission: nil,
            seller: nil
        )
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            if offerData == nil {
                                presentationMode.wrappedValue.dismiss()
                            }else{
                                GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                                MOLH.reset()
                            }
                        }) {
                            Image("backArrow")
                                .resizable()
                                .frame(width: 10, height: 17)
                        }
                        Image("")
                            .frame(width: 25,height: 20)
                        Spacer()
                        Text("offerDetails".localized())
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 17))
                            .foregroundStyle(Color(.black222222))
                        Spacer()
                        Button(action: {showPopOverCopy.toggle()},
                               label: { Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                .foregroundColor(.black222222)
                                .frame(width: 25,height: 20)
                        })
                        .popover(isPresented: $showPopOverCopy, attachmentAnchor: .point(.bottom)) {
                            VStack(spacing: 10) {
                                Button(action: {
                                    copyCode()
                                    showPopOverCopy = false
                                }, label: {
                                    Text("code".localized())
                                        .textModifier(.plain, 14, .black222222)
                                        .frame(maxWidth: .infinity)
                                })
                                
                                
                                Button(action: {
                                    copyURL()
                                    showPopOverCopy = false
                                }, label: {
                                    Text("link_offer".localized())
                                        .textModifier(.plain, 14, .black222222)
                                        .frame(maxWidth: .infinity)
                                })
                            }
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }

                        Button(action: {showPopOverShare.toggle()}, label:{
                               Image(.share).resizable().frame(width: 25,height: 20)
                        })
                    .popover(isPresented: $showPopOverShare, attachmentAnchor: .point(.bottom)) {
                        VStack(spacing: 10) {
                            Button(action: {
                                showPopOverShare = false
                                shareCode()
                            }, label: {
                                Text("code".localized())
                                    .textModifier(.plain, 14, .black222222)
                                    .frame(maxWidth: .infinity)
                            })
                            
                            
                            Button(action: {
                                showPopOverShare = false
                                shareURL()
                            }, label: {
                                Text("link_offer".localized())
                                    .textModifier(.plain, 14, .black222222)
                                    .frame(maxWidth: .infinity)
                            })
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                    Button(action: {shareQRCode()},label:{
                           Image(.qrcodeShare)
                               .resizable()
                               .frame(width: 20,height: 20)
                    })
                    }
                    .padding(24)
                    .background(Color(.primary))
                    if !viewModel.isLoading {
                        ZStack(alignment: .bottom){
                            ScrollView {
                                VStack(alignment: .leading,spacing: 19) {
                                    Text("offerDetails".localized())
                                        .textModifier(.plain, 16, .black010202)
                                    //                                Text(linkDetails.description ?? "")
                                    //                                    .textModifier(.plain, 15, .black222222)
                                    //                                    .padding(.top,-10)
                                    if viewModel.offersData?.products?.count ?? 0 > 0, let product = viewModel.offersData?.products?.first  {
                                        VStack(alignment: .leading) {
                                            
                                            VStack {
                                                InfiniteCarouselView(listOfPages: .constant(product.images ?? []),onImageTap: { file in
                                                    selectedImage = file
                                                    showSelectedImage = true
                                                })
                                                HStack(alignment: .top) {
                                                    Text(product.name ?? "")
                                                        .textModifier(.plain, 15, .black222222)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        HStack(spacing: 5){
                                                            Text(String(format: "%.1f", product.price ?? 0))
                                                                .textModifier(.plain, (product.offerPrice == 0 || product.offerPrice == nil) ? 14 : 12, (product.offerPrice == 0 || product.offerPrice == nil) ? .black222222 : .black010202.opacity(0.6))
                                                                .strikethrough((product.offerPrice == 0 || product.offerPrice == nil) ? false : true, color: .black010202)
                                                                .fixedSize()
                                                            Image(.riyal)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .foregroundColor((product.offerPrice == 0 || product.offerPrice == nil) ? .black010202 : .black010202.opacity(0.6))
                                                                .frame(width: (product.offerPrice == 0 || product.offerPrice == nil) ? 11 : 16)
                                                        }
                                                        .environment(\.layoutDirection, .rightToLeft)
                                                        if product.offerPrice != 0, product.offerPrice != nil {
                                                            HStack(spacing: 5){
                                                                Text(String(format: "%.1f", product.offerPrice ?? 0))
                                                                    .textModifier(.plain, 14, .black010202)
                                                                    .fixedSize()
                                                                Image(.riyal)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fit)
                                                                    .foregroundColor(.black)
                                                                    .frame(width: 16)
                                                                //                                                            .padding(.trailing, 10)
                                                            }
                                                            .environment(\.layoutDirection, .rightToLeft)
                                                        }
                                                        Spacer()
                                                    }
                                                    if let originalPrice = product.price, let discountPrice = product.offerPrice, originalPrice > 0 {
                                                        let discountPercentage = ((originalPrice - discountPrice) / originalPrice) * 100
                                                        HStack {
                                                            Text("discount".localized() + " " + "\(Int(discountPercentage))%")
                                                                .textModifier(.plain, 14, .primaryF9CE29)
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 10) {
                                                    HStack {
                                                        HTMLDescriptionView(html: product.description ?? "")
                                                        Spacer()
                                                    }
                                                }
                                                .padding(.top)
                                            }
                                            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                                        }
                                        //                                        .padding(.horizontal,20)
                                        
                                        
                                        
                                    }
                                    if let shippingCompanies = linkDetails.shippingCompanies, !shippingCompanies.isEmpty {
                                        ShippingCompanySelectionView(
                                            selectedCompany: $selectedShippingCompany,
                                            availableCompanies: shippingCompanies,
                                            showRadioButtons: false
                                        )
                                        .padding(.top, 8)
                                    }
                                    
                                    if let data = viewModel.offersData {
                                        OfferPriceBreakdownView(offerData: data)
                                    }
                                    
                                    //                                PaymentInfoView(breakdown: PaymentDetails(commission: Double(linkDetails.commissionRatio ?? "0" ) ?? 0, commissionMaxPrice: Double(linkDetails.maxCommissionValue ?? "0") ?? 0),isMerchantOfferDetails: true, itemsPrice: $totalPrice)
                                    
                                }
                                .padding(.bottom,60)
                                .navigationDestination(isPresented: $isNavigateToAddress) {
                                    SavedAddressesView(selectedAddressId: $addressId, selectedAddress: $address,initSelectedAddressId: addressId,isComingFromSelection: true)
                                }
                                .padding(.bottom, 70)
                            }
                            .scrollIndicators(.hidden)
                            VStack (spacing: 8) {
                                
                                if status == 1 {
                                    ReusableButton(buttonText: "stopOffer",buttonColor: .yellow){
                                        viewModel.stopActivateOffer(code: viewModel.offersData?.code ?? "", status: 2)
                                    }
                                }
                                else {
                                    ReusableButton(buttonText: "activateOffer",buttonColor: .yellow){
                                        viewModel.stopActivateOffer(code: viewModel.offersData?.code ?? "", status: 1)
                                    }
                                }
                                
                                ReusableButton(buttonText: "deleteOffer"){
                                    viewModel.deleteOffer(id: viewModel.offersData?.id ?? 0)
                                }
                            }
                        }
                        .padding(24)
                    }
                    Spacer(minLength: 0)
                }
                if let selectedImage = selectedImage, showSelectedImage {
                    ZStack {
                        Color(.black010202.opacity(0.5))
                            .onTapGesture {
                                showSelectedImage = false
                            }
                        WebImage(url: URL(string: selectedImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: UIScreen.main.bounds.width * 0.9)
                            .disabled(true)
                            .cornerRadius(10)
                    }
                    .ignoresSafeArea(.all)
                    
                }
                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView()
                        .hidden()
                }
                
            }
            .onChange(of: viewModel.activeStopSuccess, { _, _ in
            })
            .sheet(isPresented: $showingProductDetails, onDismiss: {
                showingProductDetails = false
            }, content: {
                ProductDetailsPopUp(product: $selectedProduct,isAbleToEdit: true,isMerchant: true)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }).edgesIgnoringSafeArea(.bottom)
                .toastView(toast: $viewModel.toast)
                .toastView(toast: $toast)
            
                .navigationBarHidden(true)
                .onAppear{
                    if let offerData {
                        viewModel.offersData = offerData
                    } else {
                        viewModel.showOffer(code: code)
                    }
                }
                .onReceive(viewModel.$_isSuccess){value in
                    if value {
                        self.presentationMode.wrappedValue.dismiss()
                    }}
                .onChange(of: selectedProduct, { oldValue, newValue in
                    updateOfferData(with: newValue)
                })
                .onChange(of: viewModel.offersData) { oldValue, newValue in
                    if let products = viewModel.offersData?.products {
                        totalPrice = products.reduce(0.0) { (result, product) in
                            let productPrice = product.offerPrice ?? 0 > 0 ? product.offerPrice! : product.price ?? 0
                            let totalProductPrice = productPrice * Double(product.amount ?? 1)
                            return result + totalProductPrice
                        }
                        
                    }
                    status = viewModel.offersData?.status ?? 0
                }
        }
    }
    // Function to calculate the total price
    private func updateOfferData(with selectedProduct: productList) {
        guard var products = viewModel.offersData?.products else { return }
        
        if let index = products.firstIndex(where: { $0.id == selectedProduct.id }) {
            viewModel.offersData?.products?[index] = selectedProduct
            //            offerData?.products = products
        }
    }
    
    private func copyURL() {
        if let _ = viewModel.offersData?.id, let offerCode = viewModel.offersData?.code {
            let urlString = "https://dafea.com.sa/offers/\(offerCode)"
            UIPasteboard.general.string = urlString
            self.toast = FancyToast(type: .info, title:"", message:  "copied successfully".localized())
        }
    }
    
    private func copyCode() {
        if let offerCode = viewModel.offersData?.code {
            UIPasteboard.general.string = offerCode
            self.toast = FancyToast(type: .info, title:"", message: "copied successfully".localized())
        }
    }
    
    private func shareCode() {

        if let _ = viewModel.offersData?.id, let offerCode = viewModel.offersData?.code {
            let urlString = offerCode
            
            // Add delay to allow popover to dismiss completely
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = window.rootViewController {
                    
                    // Get the topmost visible view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController,
                          !presentedViewController.isBeingDismissed {
                        topViewController = presentedViewController
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
                    
                    // iPad support
                    if let popover = activityViewController.popoverPresentationController {
                        popover.sourceView = topViewController.view
                        popover.sourceRect = CGRect(x: topViewController.view.bounds.midX,
                                                   y: topViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    topViewController.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }

    private func shareURL() {
        if let _ = viewModel.offersData?.id, let offerCode = viewModel.offersData?.code {
            let urlString = "https://dafea.com.sa/offers/\(offerCode)"
            
            // Add delay to allow popover to dismiss completely
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = window.rootViewController {
                    
                    // Get the topmost visible view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController,
                          !presentedViewController.isBeingDismissed {
                        topViewController = presentedViewController
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
                    
                    // iPad support
                    if let popover = activityViewController.popoverPresentationController {
                        popover.sourceView = topViewController.view
                        popover.sourceRect = CGRect(x: topViewController.view.bounds.midX,
                                                   y: topViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    topViewController.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }

    private func shareQRCode() {
        guard let offerCode = viewModel.offersData?.code else { return }
        
        // Generate QR Code
        let qrCodeImage = qrcodeImage(string: offerCode)
        
        if let qrCodeImage = qrCodeImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                   let rootViewController = window.rootViewController {
                    
                    // Get the topmost visible view controller
                    var topViewController = rootViewController
                    while let presentedViewController = topViewController.presentedViewController,
                          !presentedViewController.isBeingDismissed {
                        topViewController = presentedViewController
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
                    
                    // iPad support
                    if let popover = activityViewController.popoverPresentationController {
                        popover.sourceView = topViewController.view
                        popover.sourceRect = CGRect(x: topViewController.view.bounds.midX,
                                                   y: topViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    topViewController.present(activityViewController, animated: true, completion: nil)
                }
            }
        } else {
            print("Failed to generate QR code image")
        }
    }

//    private func shareQRCode() {
//        guard let offerCode = viewModel.offersData?.code else { return }
//        
//        // Generate QR Code
//        let qrCodeImage = qrcodeImage(string: offerCode)
//        
//        // Convert UIImage to SwiftUI Image
//        if let qrCodeImage = qrCodeImage {
//            // Share the QR Code Image
//            let activityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
//            
//            // Ensure the activityViewController is presented on the main thread
//            DispatchQueue.main.async {
//                // Get the current view controller from the window scene
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let rootViewController = windowScene.windows.first?.rootViewController {
//                    
//                    // Find the topmost presented view controller
//                    var topViewController = rootViewController
//                    while let presentedViewController = topViewController.presentedViewController {
//                        topViewController = presentedViewController
//                    }
//                    
//                    // Present the activityViewController from the topmost view controller
//                    topViewController.present(activityViewController, animated: true, completion: nil)
//                } else {
//                    print("Root view controller is nil")
//                }
//            }
//        } else {
//            print("Failed to generate QR code image")
//        }
//    }
}

#Preview {
    OrderLinkDetailsView()
}

// MARK: - OfferPriceBreakdownView
struct OfferPriceBreakdownView: View {
    let offerData: ShowOfferData

    @State private var showPriceTooltip: Bool = false

    private var product: productList? { offerData.products?.first }
    private var priceCommission: PriceCommissionV3? { offerData.priceCommission }
    private var seller: SellerV3? { offerData.seller }
    private var isFreeShipping: Bool { offerData.shipmentFree == 1 }

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            // MARK: Title
            Text("payment_info_title".localized())
                .textModifier(.bold, 16, .black222222)
                .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: Card
            VStack(spacing: 10) {
                VStack (spacing: 10){
                    priceRow
                    commissionRow
                    Divider()
                        .padding(.horizontal)
                    netRow
                    Divider()
                        .padding(.horizontal)
                    shippingRow
                    if isFreeShipping {
                        freeShippingHintView
                            .padding(.horizontal,10)
                    }
                }
                .padding(.vertical)
            }
//            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryF9CE29, lineWidth: 1)
            )
            
            // MARK: Free Shipping Hint
            
        }
    }

    // MARK: - Rows

    private var priceRow: some View {
        HStack {
            HStack(spacing: 6) {
                Text("price_label".localized() + " ")
                    .textModifier(.plain, 13, .grayAAAAAA)
                Button {
                    showPriceTooltip.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
                .popover(isPresented: $showPriceTooltip, attachmentAnchor: .point(.top)) {
                    VStack(alignment: .leading, spacing: 10) {
                        if isFreeShipping {
                            tooltipBullet("tooltip_shipping_on_seller".localized())
                            tooltipBullet("tooltip_price_shown_to_buyer".localized())
                            tooltipBullet("tooltip_shipping_deducted".localized())
                        } else {
                            tooltipBullet("tooltip_shipping_on_buyer".localized())
                            tooltipBullet("tooltip_price_shown_with_shipping".localized())
                        }
                    }
                    .padding()
                    .background(Color(.black010202))
                    .presentationCompactAdaptation(.popover)
                }
                Text(":".localized())
                    .textModifier(.plain, 13, .grayAAAAAA)
                
            }

            Spacer()
            // label + tooltip on right
            riyalRow(
                value: product?.offerPrice ?? product?.price ?? 0,
                color: .grayAAAAAA,
                size: 14
            )

        }
        .padding(.horizontal, 14)
//        .padding(.vertical, 14)
    }

    private var commissionRow: some View {
        HStack {
            Text("service_fees_label".localized() + " :")
                .textModifier(.bold, 13, Color(hex: "E53935"))
            Spacer()
            riyalRow(
                value: -(priceCommission?.commission ?? 0),
                color: Color(hex: "E53935"),
                size: 13,
                forceSign: true
            )
        }
        .padding(.horizontal, 14)
//        .padding(.vertical, 14)
    }

    private var netRow: some View {
        HStack {
            Text("net_label".localized() + " :")
                .textModifier(.plain, 14, .black000000)
            Spacer()
            riyalRow(
                value: seller?.sellerNetAmount?.doubleValue ?? 0,
                color: .black000000,
                size: 14,
                bold: true
            )
        }
        .padding(.horizontal, 14)
//        .padding(.vertical, 14)
    }

    private var shippingRow: some View {
        HStack {
            Text("shipping_delivery_label".localized() + ":")
                .textModifier(.plain, 13, .grayAAAAAA)
            
            Spacer()
            
            Text(isFreeShipping
                 ? "shipping_on_seller".localized()
                 : "shipping_on_buyer".localized())
                .textModifier(.plain, 13, .grayAAAAAA)
        }
        .padding(.horizontal, 14)
//        .padding(.vertical, 14)
    }

    private var divider: some View {
        Divider()
            .background(Color.gray.opacity(0.15))
            .padding(.horizontal, 14)
    }

    // MARK: - Free Shipping Hint
    private var freeShippingHintView: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color(hex: "E5A000"))
                .font(.system(size: 15))
            Text("free_shipping_hint".localized())
                .textModifier(.plain, 13, .gray666666)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "FFFDE7"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "E5A000").opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    private func riyalRow(value: Double, color: Color, size: CGFloat, bold: Bool = false, forceSign: Bool = false) -> some View {
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

    @ViewBuilder
    private func tooltipBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").textModifier(.plain, 13, .white)
            Text(text)
                .textModifier(.plain, 13, .white)
                .frame(maxWidth: 220, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
