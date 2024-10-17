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
                
                NavigationBarView(title: "Settings".localized()){
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
            isSwitchOn = GenericUserDefault.shared.getValue(Constants.shared.notificationOnOrOff) as? String == "1" ? true : false
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
/*
//  SettingView.swift
//  MRCPartner
//
//  Created by AMN on 28/08/2023.
//

import SwiftUI

    Image(Asset.settingNotification.name)
                            .resizable()
                            .frame(width: 40,height: 40)
                        Text("Notification".localized())
                            .padding(.trailing,20)
                            .font(.custom(AppFonts.shared.name(AppFontsTypes.regular), size: 17))
                            .foregroundColor(.black)
                        Spacer()
                        Button {
                            isSwitchOn = !isSwitchOn
                            switchValueChanged(isSwitchOn)
                        } label: {
                            
                            if isSwitchOn {
                                Image(.toggleOn)
                                    .resizable()
                                    .frame(width: 34,height: 17)
                                    .flipped( Constants.shared.isAR ? .horizontal:nil)
                                    .padding(.trailing,5)
                                    
                            }
                            else {
                                Image(.toggleOff)
                                    .resizable()
                                    .frame(width: 34,height: 17)
                                    .flipped( Constants.shared.isAR ? .horizontal:nil)
                                    .padding(.trailing,5)
                            }
                        }

//                        Toggle("", isOn: $isSwitchOn)
//                            .toggleStyle(SwitchToggleStyle(tint: Color(Asset.mainOrangeColor.name)))
//                            .flipped( Constants.shared.isAR ? .horizontal:nil)
//                            .frame(width: 10, height: 10)
//                            .controlSize(.mini)
//                            .padding(.trailing,5)
//                            .scaleEffect(0.7)
//                            .onChange(of: isSwitchOn) { _,new in
//                                if !isInitialAppear  {
//                                    switchValueChanged(new)
//                                }
//                                isInitialAppear = false
//                            }
//                            .padding(.trailing,5)
                    }
                    
                    NavigationLink(destination: ChangeLanguageView(), label:{
                        
                        HStack{
                            Image(Asset.language.name)
                                .resizable()
                                .frame(width: 40,height: 40)
                                
                            Text("Language".localized())
                                .padding(.trailing,20)
                                .font(.custom(AppFonts.shared.name(AppFontsTypes.regular), size: 17))
                                .foregroundColor(.black)
                            Spacer()
                            Image(Asset.detailsArrow.name).resizable()
                                .frame(width: 10,height: 16)
                        }
                    })
                    NavigationLink(destination: ChangePasswordView(), label:{
                        ZStack{
                            
                            HStack{
                                Image(Asset.resetPassword.name).resizable()
                                    
                                    .resizable()
                                    .frame(width: 40,height: 40)
                                    
                                Text("Change Password".localized())
                                    .padding(.trailing,20)
                                    .font(.custom(AppFonts.shared.name(AppFontsTypes.regular), size: 17))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(Asset.detailsArrow.name).resizable()
                                    .frame(width: 10,height: 16)
                            }
                        }
                    })
                }
                .padding([.leading,.trailing],20)
                Spacer()
            }
            
            .padding(.bottom)
            if  moreVM.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if moreVM.isFailed{
                ProgressView()
                    .hidden()
            }
        }
        
//        .allowsHitTesting(mainVM.isLoading ? false : true)
        .allowsHitTesting(moreVM.isLoading ? false : true)
//        .toastView(toast: $mainVM.toast)
        .toastView(toast: $moreVM.toast)
//        .edgesIgnoringSafeArea(.all)
        .background(Color(Asset.mainBGColor.color))
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)//.clipped()
        .onAppear(){
            isSwitchOn = GenericUserDefault.shared.getValue(Constants.shared.notificationOnOrOff) as? String == "1" ? true : false
            AppState.shared.swipeEnabled = true
        }
        
    }
    func switchValueChanged(_ active: Bool){
        moreVM.activeNotification(active: active ? 1:0)
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView( isSwitchOn: .constant)
//    }
//}
//struct NotificationToggleStyle: ToggleStyle {
//
//    func makeBody(configuration: Configuration) -> some View {
//        HStack {
//            if configuration.isOn {
//                Image(Asset.onSwitch.name)
//                    .resizable()
//                    .frame(width: 46.8, height: 23.4)
//                    .foregroundColor(Color(Asset.secondColor.name))
//            } else {
//                Image(Asset.offSwitch.name)
//                    .resizable()
//                    .frame(width: 46.8, height: 23.4)
////                    .foregroundColor(Color(Asset.secondColor.name))
//            }
//
//            configuration.label
//        }
//        .onTapGesture {
//            configuration.isOn.toggle()
//        }
//    }
//}
*/
