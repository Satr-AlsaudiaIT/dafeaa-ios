//
//  ProfileDetailView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProfileDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    
    // MARK: - Navigation States
    @State private var showChangePassword: Bool = false
    @State private var showDeveloperKeyBottomSheet: Bool = false
    @State private var navigateToPersonalProfile: Bool = false
    @State private var navigateToFinancials: Bool = false
    @State private var navigateToAddresses: Bool = false
    @State private var showChangeQuickPasscode: Bool = false

    // Bottom Sheet States
    @State var profileId: String = ""
    @State var secretKey: String = ""
    
    // Address States (Moved from ProfileList)
    @State private var selectedAddressId: Int = Constants.selectedAddressId
    @State private var selectedAddress: String = Constants.selectedAddress
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "profile") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Personal Profile Button
                        NavigationLinkComponent(
                            destination: ProfilePersonalView(profileId: viewModel.profileData?.profileId ?? "", secretKey: viewModel.profileData?.secretKey ?? ""),
                            label: "profile",
                            image: Image(.iconProfile)
                        )
                        
                        // MARK: - Financials Button
                        
                        Button {
                            navigateToFinancials = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(.financials)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                let isVerify: Bool = viewModel.profileData?.isFinancialInfoCompleted ?? false
                                
                                HStack(alignment: .lastTextBaseline, spacing: 0) {
                                    Text("financials".localized())
                                        .textModifier(.plain, 16, .black000000)
                                    
                                    if !isVerify {
                                        Text(" (\("not_verified".localized()))")
                                            .textModifier(.plain, 8, .black000000)
                                    }
                                }
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                        
                        // MARK: - Saved Addresses Button (Moved Here)
                        Button {
                            navigateToAddresses = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(.iconAddress)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                
                                Text("Saved Addresses".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                        
                        // MARK: - Change Password Button
                        Button {
                            showChangePassword = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(.changePassword)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 28, height: 28)
                                
                                Text("changePassword".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                        
                        // MARK: - Change Quick Passcode Button
                        Button {
                            showChangeQuickPasscode = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield")
                                    .resizable()
                                    .foregroundColor(.yellow)
                                    .frame(width: 22, height: 26)
                                
                                Text("changeQuickPasscode".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                        // MARK: - Developer Keys Button
                        Button {
                            showDeveloperKeyBottomSheet = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(.developersKey)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 28, height: 28)
                                
                                Text("developerKeys".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                }
            }
            
            // MARK: - Loaders
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView().hidden()
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.profile()
            AppState.shared.swipeEnabled = true
        }
        .onChange(of: viewModel.profileData?.secretKey ?? "") { _, newValue in
            secretKey = newValue
        }
        
        // MARK: - Navigations & Bottom Sheets
        
        .navigationDestination(isPresented: $navigateToAddresses) {
            SavedAddressesView(
                selectedAddressId: $selectedAddressId,
                selectedAddress: $selectedAddress,
                initSelectedAddressId: selectedAddressId
            )
        }
        .navigationDestination(isPresented: $navigateToFinancials) {
            ProfileFinancialsView()
        }
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .navigationDestination(isPresented: $showChangeQuickPasscode) {
            SettingsQuickPasscodeSetupView(isQuickPasscodeOn: .constant(true))
        }
        .customBottomSheet(isPresented: $showDeveloperKeyBottomSheet, detents: [.medium, .large]) {
            DeveloperKeyBottomSheet(isSheetPresented: $showDeveloperKeyBottomSheet, profileID: $profileId, secretKey: $secretKey)
        }
    }
}

#Preview {
    ProfileDetailView()
}
