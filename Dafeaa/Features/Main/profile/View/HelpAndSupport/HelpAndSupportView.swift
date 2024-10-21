//
//  HelpAndSupportView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 20){
                
                NavigationBarView(title: "Help and Support"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                VStack(alignment: .leading,spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text("helpTitle".localized())
                            .textModifier(.plain, 14, .black292D32)
                            .frame(maxWidth:.infinity,alignment: .leading)
                        Text("helpSubTitle".localized())
                            .textModifier(.plain, 14, .gray919191)
                            .frame(maxWidth:.infinity,alignment: .leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("keepContactWithUs".localized())
                            .textModifier(.plain, 14, .black292D32)
                            .frame(height:23)
                        // Button to make a phone call
                        ButtonWithImageView(imageName: .callCalling, text: "contactClientsServices".localized()){
                            let phoneNumber = "tel://\(viewModel.contactData?.contactPhone ?? "")"
                            if let url = URL(string: phoneNumber) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        // Button to open WhatsApp chat
                        ButtonWithImageView(imageName: .chat, text: "chatClientsServices".localized()){
                            let phoneNumber = viewModel.contactData?.whatsappNum ?? ""
                            let whatsappURL = "whatsapp://send?phone=\(phoneNumber)"
                            if let url = URL(string: whatsappURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        // Button to send an email
                        ButtonWithImageView(imageName: .email, text: "contactWithEmail".localized()){
                            let email = "mailto:\(viewModel.contactData?.contactEmail ?? "")" // replace with actual email
                            if let url = URL(string: email) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }.padding(.horizontal,24)
                
                Spacer()
                
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear(){
            AppState.shared.swipeEnabled = true
        }
        
    }
}

#Preview {
    HelpAndSupportView()
}
