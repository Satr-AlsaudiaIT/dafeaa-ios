//
//  SettingsView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    @State private var showingLanguageActionSheet = false
    @State private var isSwitchOn: Bool = false
    @State private var isBiometricOn: Bool = false
    @State private var isQuickPasscodeOn: Bool = false
    @State private var showQuickPasscodeSetup: Bool = false
    @State private var showBiometricNotAvailableAlert: Bool = false

    @State private var isActiveActionSheet = false
    @State private var activeActionSheet: ActiveSheet?
    @State private var showChangePassword : Bool = false
    @State private var showDeveloperKeyBottomSheet : Bool = false


    enum ActiveSheet {
           case deleteAccount
          case changeLanguage
       }
    var body: some View {
        
        ZStack{
            VStack(spacing: 20){
                
                NavigationBarView(title: "Settings"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                VStack(alignment: .leading,spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 8){
                        ButtonWithImageView(imageName: .global, trailingImageName:.sideArrow, text: "languageApp".localized()){
                            isActiveActionSheet = true
                            activeActionSheet = .changeLanguage
                        }
                        
                        HStack {
                            Image(.notificationBing)
                                .frame(width: 20, height: 20)
                            
                            Text("notifications".localized())
                                .textModifier(.plain, 14, .black292D32)
                            
                            Spacer()
                           
                            Button {
                                isSwitchOn = !isSwitchOn
                                toggleNotification(newValue: isSwitchOn)
                            } label: {
                                Image(isSwitchOn ? .toggleOn:.toggleOff)
                                    .padding(.trailing, isSwitchOn ? 16:12)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(5)
                        
                        // MARK: - Quick Passcode Toggle
                        HStack {
                            Image(systemName: "lock.shield")
                                .resizable()
                                .foregroundColor(.yellow)
                                .frame(width: 17, height: 20)
                            
                            Text("enable_quick_passcode".localized())
                                .textModifier(.plain, 14, .black292D32)
                            
                            Spacer()
                           
                            Button {
                                if isQuickPasscodeOn {
                                    isQuickPasscodeOn = false
                                    QuickPasscodeManager.shared.isEnabled = false
                                } else {
                                    if QuickPasscodeManager.shared.hasPasscode {
                                        isQuickPasscodeOn = true
                                        QuickPasscodeManager.shared.isEnabled = true
                                    } else {
                                        showQuickPasscodeSetup = true
                                    }
                                }
                            } label: {
                                Image(isQuickPasscodeOn ? .toggleOn:.toggleOff)
                                    .padding(.trailing, isQuickPasscodeOn ? 16:12)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(5)
                        
                        // MARK: - Biometric Toggle
                        HStack {
                            Image(systemName: "lock.shield")
                                .resizable()
                                .foregroundColor(.yellow)
                                .frame(width: 17, height: 20)
                            
                            Text("enable_biometric_authentication".localized())
                                .textModifier(.plain, 14, .black292D32)
                            
                            Spacer()
                           
                            Button {
                                if isBiometricOn {
                                    // Turning OFF — no auth needed
                                    isBiometricOn = false
                                    QuickPasscodeManager.shared.isBiometricEnabled = false
                                } else {
                                    // Turning ON — check device support first
                                    guard BiometricAuthManager.shared.isBiometricAvailable else {
                                        showBiometricNotAvailableAlert = true
                                        return
                                    }
                                    // Authenticate to verify it works
                                    BiometricAuthManager.shared.authenticate { success, _ in
                                        if success {
                                            isBiometricOn = true
                                            QuickPasscodeManager.shared.isBiometricEnabled = true
                                        }
                                    }
                                }
                            } label: {
                                Image(isBiometricOn ? .toggleOn:.toggleOff)
                                    .padding(.trailing, isBiometricOn ? 16:12)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(5)
//                        ButtonWithImageView(imageName: .changePassword, trailingImageName:.sideArrow, text: "changePassword".localized()){
//                            showChangePassword = true
//                        }
//                        ButtonWithImageView(imageName: .developersKey, trailingImageName:.sideArrow, text: "developerKeys".localized()){
//                            showDeveloperKeyBottomSheet = true
//                        }
                        
                        Spacer()
                        Button(action: {
                            isActiveActionSheet = true
                            activeActionSheet = .deleteAccount
                        }) {
                            Text("deleteAccount".localized())
                                .textModifier(.semiBold, 15, .redFA4248)
                                .frame(maxWidth:.infinity)
                                .frame(height:51)
                                .background(.redFA4248.opacity(0.1))
                                .cornerRadius(5)
                        }
//                        .padding(20)
                    }
                }.padding(.horizontal,24)
                
                Spacer()
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
//        .navigationDestination(isPresented: $showChangePassword) {
//            ChangePasswordView()
//        }
    
        .appActionSheet(
            isPresented: Binding(
                get: { isActiveActionSheet && activeActionSheet == .deleteAccount },
                set: { if !$0 { isActiveActionSheet = false } }
            ),
            case: .deleteAccount,
            onConfirm: { viewModel.deleteAccount() }
        )
        .appActionSheet(
            isPresented: Binding(
                get: { isActiveActionSheet && activeActionSheet == .changeLanguage },
                set: { if !$0 { isActiveActionSheet = false } }
            ),
            case: .changeLanguage,
            onExtraAction: { languageCode in
                changeLanguage(to: languageCode)
            }
        )//        .sheet(isPresented: $showDeveloperKeyBottomSheet, content: {
//            DeveloperKeyBottomSheet(isSheetPresented: $showDeveloperKeyBottomSheet, profileID: viewModel.profileData?.profileId ?? "", secretKey: viewModel.profileData?.secretKey ?? "")
//                .presentationDetents([.medium,.large])
//                .presentationCornerRadius(24)
//                .presentationDragIndicator(.visible)
//        })
        .toastView(toast: $viewModel.toast)
        .alert("biometric_not_available_title".localized(), isPresented: $showBiometricNotAvailableAlert) {
            Button("go_to_settings".localized()) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel".localized(), role: .cancel) {}
        } message: {
            Text("biometric_not_available_message".localized())
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showQuickPasscodeSetup) {
            SettingsQuickPasscodeSetupView(isQuickPasscodeOn: $isQuickPasscodeOn)
        }
        .onAppear(){
            isBiometricOn = QuickPasscodeManager.shared.isBiometricEnabled
            isQuickPasscodeOn = QuickPasscodeManager.shared.isEnabled && QuickPasscodeManager.shared.hasPasscode
            isSwitchOn =  UserDefaults.standard.value(forKey: Constants.shared.activeNotification) as? Int ?? 0 == 1 ? true : false
            AppState.shared.swipeEnabled = true
            viewModel.profile(false)

        }
        .onChange(of: showDeveloperKeyBottomSheet) { value, new in
            if !new{
                viewModel.profile(false)
            }
            
        }
        
    }
    
    func toggleNotification(newValue: Bool) {
        viewModel.activeNotification(active: newValue ? 1:0)
        }
    
    func changeLanguage(to languageCode: String) {
        if Constants.shared.isAR , languageCode == "en"{
            UserDefaults.standard.set(true, forKey:  Constants.shared.resetLanguage)
            MOLH.setLanguageTo("en")
            MOLH.reset()
        }else if !Constants.shared.isAR , languageCode == "ar"{
            UserDefaults.standard.set(true, forKey:  Constants.shared.resetLanguage)
            MOLH.setLanguageTo("ar")
            MOLH.reset()
        }else {
            
        }
       
    }
}

#Preview {
    SettingsView()
}
