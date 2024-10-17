//
//  ProfileView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = AuthVM()
    let name = GenericUserDefault.shared.getValue(Constants.shared.userName) as? String ?? ""
    let phone = GenericUserDefault.shared.getValue(Constants.shared.phone) as? String ?? ""
    let type = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0

    var body: some View {
            ZStack{
                VStack {
                    NavigationBarView(title: "myAccount".localized()){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    ScrollView(.vertical,showsIndicators: false){
                        
                        VStack(alignment: .leading,spacing: 24){
                            HStack(spacing: 12){
                                Image(.profile)
                                    .resizable()
                                    .frame(width: 72,height: 72)
                                    .clipShape(Circle())
                                    .overlay(   Circle()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)  )


                                VStack(spacing: 2){
                                    Text("Hello,".localized() + " \(name)")
                                        .textModifier(.plain, 16, .black222222)
                                    Text("\(phone)")
                                        .textModifier(.plain, 12, .gray888888)
                                }
                                Spacer()
                            }.padding(8)
                                .padding(.leading,8)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(   RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)  )
                            
                            VStack(spacing: 16) {
                                NavigationLinkComponent(
                                    destination: ProfileDetailView(),
                                    label: "Profile",
                                    image: Image(.iconProfile)
                                )
                                
                                if type == 1{
                                    NavigationLinkComponent(
                                        destination: SavedAddressesView(),
                                        label: "Saved Addresses",
                                        image: Image(.iconAddress)
                                    )
                                }else{
                                    NavigationLinkComponent(
                                        destination: SubscriptionManagementView(),
                                        label: "Subscription Management",
                                        image: Image(.iconAddress)
                                    )
                                }
                                NavigationLinkComponent(
                                    destination: StaticPagesView(type: .constant(.aboutApp)),
                                    label: "About Dafeaa",
                                    image: Image(.iconAbout)
                                )
                                NavigationLinkComponent(
                                    destination: FAQView(),
                                    label: "FAQ",
                                    image: Image(.iconFAQ)
                                )
                                NavigationLinkComponent(
                                    destination: HelpAndSupportView(),
                                    label: "Help and Support",
                                    image: Image(.iconHelp)
                                )
                                NavigationLinkComponent(
                                    destination: SettingsView(),
                                    label: "Settings",
                                    image: Image(.iconSettings)
                                )
                            }                        }
                            
                        }.padding(24)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView()
                        .hidden()
                }
            }.navigationBarHidden(true)
                .toastView(toast: $viewModel.toast)
    }
}
 
#Preview {
    ProfileView()
}

import SwiftUI

struct NavigationLinkComponent<Destination: View>: View {
    var destination: Destination
    var label: String
    var image: Image
    @Environment(\.layoutDirection) var layoutDirection  // Detect the language direction
    
    var body: some View {
        NavigationLink(destination:  destination, label:
        {
            HStack(spacing:12) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 28, height: 28)
            
                Text(label.localized())
                .textModifier(.plain, 16, .black194558)
            Spacer()
            
            Image(.iconArrowNav)
                .frame(width: 32, height: 32)
                .foregroundColor(Color(.black194558))
        }
        .frame(height: 32)
        })
    }
}
