//
//  OrdersLinksView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct OrdersOffersLinksView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = OrdersVM()
    @State var goToAddOffer = false
    @State var goToDetails = false
    @State var toast: FancyToast? = nil
    @State var selectedOffer: OffersData?
    var offerList: [OffersData] {
        return viewModel._offersList
    }
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: "offers"){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    ZStack(alignment: .bottom){
                        
                        ScrollView {
                            VStack(spacing: 17) {
//                                LazyVStack(spacing: 8) {
                                    ForEach(0..<offerList.count,id: \.self){ index in
                                         OfferComponent(offer: offerList[index],onDelete: {viewModel.deleteOffer(id: offerList[safe: index]?.id ?? 0)}, toast: $toast)
                                                .onAppear {
                                                    if index == offerList.count - 1 {
                                                        loadMoreOrdersIfNeeded()
                                                    }
                                                }.onTapGesture{
                                                    selectedOffer = offerList[safe: index]
                                                    goToDetails = true
                                                    
                                                }
                                        }
//                                }
                            }
                            .padding(.bottom,60)
                        }
                        ReusableButton(buttonText: "addOffer", action: {goToAddOffer = true})
                            .navigationDestination(isPresented: $goToAddOffer, destination: {AddOfferView()})
                    }
                    .padding(24)

                }
                
                
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
        .edgesIgnoringSafeArea(.bottom)
        .toastView(toast: $viewModel.toast)
        .toastView(toast: $toast)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToDetails, destination: {OrderLinkDetailsView(id:selectedOffer?.id ?? 0)})
        .onAppear(){
                viewModel.offers(skip: 0)
                AppState.shared.swipeEnabled = true
            }
        .onDisappear{
            viewModel._offersList.removeAll()
        }
    }
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.offers(skip: offerList.count)
        }
    }
}

#Preview {
    OrdersOffersLinksView()
}

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct OfferComponent: View {
    @State var offer: OffersData?
    var onDelete: (() -> Void)
    @Binding var toast: FancyToast?
    
    var body: some View {
        HStack(alignment: .center) {
            Image(.process)
                .resizable()
                .frame(width: 48, height: 48)
                .cornerRadius(24)
            VStack(alignment: .leading, spacing: 8) {
                Text(offer?.name ?? "")
                    .textModifier(.plain, 15, .black1E1E1E)
                Text(offer?.description ?? "")
                    .textModifier(.bold, 14, .gray616161)
                    .lineLimit(2)
            }
            Spacer()
            HStack(spacing: 2) {
                // Copy Button
                Button(action: { copyURL() }, label: {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                        .foregroundColor(.black222222)
                })
                
                // Share Link Button
                let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
                if let offerID = offer?.id, let offerCode = offer?.code, let url = URL(string: "https://dafeaa-backend.deplanagency.com/offers/\(offerID)/\(offerCode)/\(userId)") {
                    ShareLink(item: url) {
                        Image(.share)
                            .resizable()
                            .frame(width: 25, height: 20)
                    }
                }
                
                // QR Code Share Button
                Button(action: { shareQRCode() }, label: {
                    Image(systemName: "qrcode")
                        .foregroundColor(.black222222)
                })
                
                // Delete Button
                Button(action: { onDelete() }, label: {
                    Image(.trash)
                })
            }
        }
    }
    
    private func copyURL() {
        let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
        if let offerID = offer?.id, let offerCode = offer?.code {
            let urlString = "https://dafeaa-backend.deplanagency.com/offers/\(offerID)/\(offerCode)/\(userId)"
            UIPasteboard.general.string = urlString
            self.toast = FancyToast(type: .info, title: "copied successfully".localized(), message: "")
        }
    }
    
    private func shareQRCode() {
        guard let offerID = offer?.id else { return }
        
        // Generate QR Code
        let qrCodeImage = generateQRCode(from: "\(offerID)")
        
        // Convert UIImage to SwiftUI Image
        if let qrCodeImage = qrCodeImage {
            let image = Image(uiImage: qrCodeImage)
            
            // Share the QR Code Image
            let activityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}
