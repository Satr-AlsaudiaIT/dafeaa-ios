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
    @State var isShowActionBottomSheet: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack {
                    NavigationBarView(title: "offers") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(spacing: 17) {
                                // Bind directly to viewModel._offersList
                                ForEach(viewModel._offersList, id: \.id) { offer in
                                    OfferComponent(offer: offer, onThreeDotsTap: {
                                        self.isShowActionBottomSheet = true
                                        selectedOffer = offer
                                    })
                                    .onAppear {
                                        if offer.id == viewModel._offersList.last?.id {
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
                        ReusableButton(buttonText: "addOffer", action: { goToAddOffer = true })
                            .navigationDestination(isPresented: $goToAddOffer, destination: { AddOfferView() })
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
        .navigationDestination(isPresented: $goToDetails, destination: { OrderLinkDetailsView(code: selectedOffer?.code ?? "") })
        .onChange(of: viewModel._isSuccess, { _, newValue in
            isShowActionBottomSheet = false
            viewModel._isSuccess = false
        })
        .sheet(isPresented: $isShowActionBottomSheet, content: {
            BottomSheetLinkActionsView(offer: selectedOffer, toast: $toast, isShow: $isShowActionBottomSheet, onDelete: {
                viewModel.deleteOffer(id: selectedOffer?.id ?? 0)
            })
            .presentationDetents([.fraction(0.3)])
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
        })
        .onAppear {
            viewModel.offers(skip: 0)
            AppState.shared.swipeEnabled = true
        }
        .onDisappear {
            viewModel._offersList.removeAll()
        }
    }

    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.offers(skip: viewModel._offersList.count)
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
        HStack(alignment: .center) {
            Image(.process)
                .resizable()
                .frame(width: 48, height: 48)
                .cornerRadius(24)
            VStack(alignment: .leading, spacing: 8) {
                Text(offer?.name ?? "")
                    .textModifier(.plain, 15, .black1E1E1E)
                Text(offer?.description ?? "")
                    .textModifier(.plain, 14, .gray616161)
                    .lineLimit(2)
            }
            Spacer()
            
//                // Three dots  Button
                Button(action: { onThreeDotsTap() }, label: {
                    Image(.threeDots)
                })
//            }
        }
    }
    
    
}
