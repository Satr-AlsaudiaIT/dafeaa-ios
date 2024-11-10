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
                                VStack(spacing: 8) {
                                    ForEach(0..<viewModel.offersList.count,id: \.self){ index in
                                        OfferComponent(offer: viewModel.offersList[index],onDelete: {viewModel.deleteOffer(id: viewModel.offersList[safe: index]?.id ?? 0)})
                                            .onAppear {
                                                if index == viewModel.offersList.count - 1 {
                                                    loadMoreOrdersIfNeeded()
                                                }
                                            }
                                    }
                                }
                            }
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
        }.edgesIgnoringSafeArea(.bottom)
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
        
            .onAppear(){
                viewModel.offers(skip: 0)
                AppState.shared.swipeEnabled = true
            }
        
    }
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.offers(skip: viewModel.offersList.count)
        }
    }
}

#Preview {
    OrdersOffersLinksView()
}

struct OfferComponent: View {
    @State var offer: OffersData?
    var onDelete: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center) {
            Image(.process)
                .resizable()
                .frame(width: 48,height: 48)
                .cornerRadius(24)
            VStack(alignment: .leading, spacing: 8) {
                Text(offer?.name ?? "")
                    .textModifier(.plain, 15, .black1E1E1E)
                Text(offer?.description ?? "")
                    .textModifier(.bold, 14, .gray616161)
            }
            Spacer()
            HStack(spacing: 2) {
                Button(action: {copyURL()}, label: { Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                    .foregroundColor(.black222222)})
                if let offerID = offer?.id , let offerCode = offer?.code, let url = URL(string: "\(Constants.shared.baseURL)offers/\(offerID)/\(offerCode)"){
                    ShareLink(item: url) { Label("", image: "share")}  }
                Button(action: {onDelete()}, label: { Image(.trash)})
            }
        }
    }
    private func copyURL() {
        if let offerID = offer?.id , let offerCode = offer?.code{
            let urlString = "\(Constants.shared.baseURL)offers/\(offerID)/\(offerCode)"
            UIPasteboard.general.string = urlString
        }
    }

}
