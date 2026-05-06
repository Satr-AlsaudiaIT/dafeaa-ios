//
//  ProfileList.swift
//  Dafeaa
//
//  Created by AMNY on 23/02/2025.
//

import SwiftUI

struct ProfileList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    @State private var selectedAddressId: Int = Constants.selectedAddressId
    @State private var selectedAddress: String = Constants.selectedAddress
    @State private var showChangePassword : Bool = false
    @State private var showDeveloperKeyBottomSheet : Bool = false
    @State var profileId : String = ""
    @State var secretKey : String = ""
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "accounts_address"){
                    self.presentationMode.wrappedValue.dismiss()
                }

                VStack() {
                    VStack(spacing: 16) {
//                        NavigationLinkComponent(
//                            destination: ProfileDetailView(),
//                            label: "profile",
//                            image: Image(.iconProfile)
//                        )
                        
//                        NavigationLinkComponent(
//                            destination: SavedAddressesView(selectedAddressId: $selectedAddressId, selectedAddress: $selectedAddress,initSelectedAddressId: selectedAddressId),
//                            label: "Saved Addresses",
//                            image: Image(.iconAddress)
//                        )
                        NavigationLinkComponent(
                            destination: SavedIBANsView(),
                            label: "Saved IBANs",
                            image: Image(.iconAddress)
                        )
//                        Button {
//                            showChangePassword = true
//                        } label: {
//                            HStack(spacing:12) {
//                                Image(.changePassword)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 28, height: 28)
//                                
//                                Text("changePassword".localized())
//                                    .textModifier(.plain, 16, .black194558)
//                                Spacer()
//                                
//                                Image(.iconArrowNav)
//                                    .frame(width: 32, height: 32)
//                                    .foregroundColor(Color(.black194558))
//                            }
//                            .frame(height: 32)
//                        }
//                        Button {
//                            showDeveloperKeyBottomSheet = true
//                        } label: {
//                            HStack(spacing:12) {
//                                Image(.developersKey)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 28, height: 28)
//                                
//                                Text("developerKeys".localized())
//                                    .textModifier(.plain, 16, .black194558)
//                                Spacer()
//                                
//                                Image(.iconArrowNav)
//                                    .frame(width: 32, height: 32)
//                                    .foregroundColor(Color(.black194558))
//                            }
//                            .frame(height: 32)
//                        }

                        Button {
                            viewModel.showAddTaxRecordBottomSheet = true
                        } label: {
                            HStack(spacing:12) {
                                Image(.developersKey)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 28, height: 28)
                                
                                Text("tax_record".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                        
                        
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .onAppear(){
            AppState.shared.swipeEnabled = true
            viewModel.getTaxRecord()
        }
        .onChange(of: viewModel.profileData?.profileId, { _, newValue in
            profileId = newValue ?? ""
        })
        .onChange(of: viewModel.profileData?.secretKey ?? "", { _, newValue in
            secretKey = newValue
        })
//        .sheet(isPresented: $showDeveloperKeyBottomSheet, content: {
//            DeveloperKeyBottomSheet(isSheetPresented: $showDeveloperKeyBottomSheet, profileID: $profileId, secretKey: $secretKey )
//                .presentationDetents([.medium,.large])
//                .presentationCornerRadius(24)
//                .presentationDragIndicator(.visible)
//        })
        .customBottomSheet(isPresented: $viewModel.showAddTaxRecordBottomSheet, detents: [.fraction(0.45)]){
            TaxRecordBottomSheet(viewModel: viewModel, taxInput: viewModel.taxRecordNumber, dismiss: $viewModel.showAddTaxRecordBottomSheet)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }

    }
    
}

#Preview {
    ProfileList()
}
