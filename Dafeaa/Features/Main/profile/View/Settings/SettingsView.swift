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
    var body: some View {
        
        ZStack{
            VStack(spacing: 20){
                
                NavigationBarView(title: "Settings"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                VStack(alignment: .leading,spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 8){
                        
                        ButtonWithImageView(imageName: .global, trailingImageName:.sideArrow, text: "languageApp".localized()){
                            showingLanguageActionSheet = true

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
        }.actionSheet(isPresented: $showingLanguageActionSheet) {
            ActionSheet(title: Text("languageApp".localized()), message: Text("Select your preferred language".localized()), buttons: [
                .default(Text("English")) {
                    changeLanguage(to: "en")
                },
                .default(Text("عربي")) {
                    changeLanguage(to: "ar")
                },
                .cancel()
            ])
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear(){
            isSwitchOn =  UserDefaults.standard.value(forKey: Constants.shared.activeNotification) as? Int ?? 0 == 1 ? true : false
            AppState.shared.swipeEnabled = true
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
