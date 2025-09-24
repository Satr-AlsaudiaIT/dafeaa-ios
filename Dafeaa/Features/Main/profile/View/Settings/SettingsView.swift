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
                        .padding(.leading, 24)
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
    
        .actionSheet(isPresented: $isActiveActionSheet) {
            switch activeActionSheet {
                       case .deleteAccount:
                           return ActionSheet(
                               title: Text("deleteAccount".localized()),
                               message: Text("deleteAccountAlert".localized()),
                               buttons: [
                                   .default(Text("deleteAccount".localized())) { viewModel.deleteAccount() },
                                   .cancel(Text("Cancel".localized()))
                               ]
                           )
            case .changeLanguage:
                return ActionSheet(
                    title: Text("languageApp".localized()),
                    message: Text("Select your preferred language".localized()),
                    buttons: [
                        .default(Text("English")) { changeLanguage(to: "en") },
                        .default(Text("عربي")) {
                            changeLanguage(to: "ar")
                        }
                    ])
               
            case .none:
                return ActionSheet(
                    title: Text("".localized()),
                    message: Text("".localized()),
                    buttons: [
                        .default(Text("".localized())) { },
                        .cancel(Text("".localized()))
                    ]
                )
            }
                   }
//        .sheet(isPresented: $showDeveloperKeyBottomSheet, content: {
//            DeveloperKeyBottomSheet(isSheetPresented: $showDeveloperKeyBottomSheet, profileID: viewModel.profileData?.profileId ?? "", secretKey: viewModel.profileData?.secretKey ?? "")
//                .presentationDetents([.medium,.large])
//                .presentationCornerRadius(24)
//                .presentationDragIndicator(.visible)
//        })
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear(){
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
