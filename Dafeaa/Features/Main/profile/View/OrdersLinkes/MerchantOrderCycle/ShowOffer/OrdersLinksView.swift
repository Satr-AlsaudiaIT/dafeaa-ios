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
    @StateObject var moreViewModel = MoreVM()

    @State var goToAddOffer = false
    @State var goToDetails = false
    @State var toast: FancyToast? = nil
    @State var selectedOffer: OffersData?
    @State var isShowActionBottomSheet: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack {
                    NavigationBarView(title: "offers") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    ZStack(alignment: .bottom) {
                        if viewModel.offersList.isEmpty {
                            VStack {
                                Spacer()
                                VStack {
                                    Image(.empty)
                                    Text("noOffers".localized())
                                        .textModifier(.plain, 16, .black222222)
                                }
                                .padding(.top, -60)
                                Spacer()
                            }
                        }
                        else {
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 17) {
                                // Bind directly to viewModel._offersList
                                ForEach(viewModel.offersList, id: \.id) { offer in
                                    OfferComponent(offer: offer, onThreeDotsTap: {
                                        self.isShowActionBottomSheet = true
                                        selectedOffer = offer
                                    })
                                    .onAppear {
                                        if offer.id == viewModel.offersList.last?.id {
                                            loadMoreOrdersIfNeeded()
                                        }
                                    }
                                    .onTapGesture {
                                        selectedOffer = offer
                                        goToDetails = true
                                    }
                                }
                            }
                            .padding(.bottom, 60)
                        }
                    }
                        ReusableButton(buttonText: "addOffer", action: {
                            
                            if moreViewModel.addressList.count != 0 {
                                goToAddOffer = true
                            } else {
                                toast = FancyToast(type: .error, title: "error", message: "noAddressValidation".localized())
                            }
                        })
                            .navigationDestination(isPresented: $goToAddOffer, destination: { AddOfferViewNew() })
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
        .navigationDestination(isPresented: $goToDetails, destination: { OrderLinkDetailsViewNew(code: selectedOffer?.code ?? "") })
        .onChange(of: viewModel._isSuccess, { _, newValue in
            isShowActionBottomSheet = false
            viewModel._isSuccess = false
        })
            .customBottomSheet(isPresented: $isShowActionBottomSheet, detents: [.fraction(0.32)]) {
            BottomSheetLinkActionsView(offer: selectedOffer, toast: $toast, isShow: $isShowActionBottomSheet, onDelete: {
                viewModel.deleteOffer(id: selectedOffer?.id ?? 0)
            }
           )
        }
        .onAppear {
            moreViewModel.addressesList(isLoading: false)
            viewModel.offers(skip: 0,animated: true)
            AppState.shared.swipeEnabled = true
        }
//        .onDisappear {
//            viewModel._offersList.removeAll()
//        }
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

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct OfferComponent: View {
    @State var offer: OffersData?
    var onThreeDotsTap: (() -> Void)
    
    var body: some View {
        HStack(alignment: .top) {
            HStack(alignment: .center) {
                Image(.process)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .cornerRadius(24)
                VStack(alignment: .leading, spacing: 0) {
                    Text(offer?.name ?? "")
                        .textModifier(.plain, 15, .black1E1E1E)
                        .lineLimit(1)
                    HTMLDescriptionPreviewView(html: offer?.description  ?? "")
//                    HTMLDescriptionView(html: offer?.description  ?? "")
                }
            }
            Spacer()
            
//                // Three dots  Button
                Button(action: { onThreeDotsTap() }, label: {
                    Image(.threeDots).resizable()
                        .frame(width: 20, height: 20)
                })
//            }
        }
    }
    
    
}
