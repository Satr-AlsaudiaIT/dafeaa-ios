//
//  ProfileView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MoreVM()
    @State private var name =  ""
    @State private var phone = ""
    let type = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @State private var showingLogOutActionSheet = false
    @State private var showingDeleteAccountActionSheet = false
    @State private var showingChangePhone = false

    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "myAccount")
                ScrollView(.vertical,showsIndicators: false){
                    
                    VStack(alignment: .leading,spacing: 24){
                        HStack(spacing: 12){
                            WebImage(url: URL(string: viewModel.profileData?.profileImage ?? ""))
                                .resizable()
                                .frame(width: 72,height: 72)
                                .clipShape(Circle())
                                .overlay(   Circle()
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)  )
                            
                            
                            VStack(alignment:.leading, spacing: 2){
                                Text("Hello,".localized() + " \(name)")
                                    .textModifier(.plain, 16, .black222222)
                                HStack{
                                    Text("\(phone)")
                                        .textModifier(.plain, 12, .gray888888)
                                    Spacer()
                                    Button(action:{
                                        showingChangePhone = true
                                    }){
                                        Text("changePhone".localized())
                                            .textModifier(.plain, 12, Color(.primary))
                                    }
                                    
                                }
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
                                label: "profile",
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
                            Button(action:{
                                showingDeleteAccountActionSheet = true
                                
                            }){
                                Text("deleteAccount".localized())
                                    .textModifier(.plain, 16, .redFA4248)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }                        }
                    
                }.padding(24)
                Button(action: {
                    showingLogOutActionSheet = true
                }) {
                    Text("logout".localized())
                        .textModifier(.semiBold, 15, .redFA4248)
                        .frame(maxWidth:.infinity)
                        .frame(height:51)
                        .background(.redFA4248.opacity(0.1))
                        .cornerRadius(5)
                }.padding(24)
            }.navigationDestination(isPresented: $showingChangePhone) {
                ChangePhoneView()
            }
            .actionSheet(isPresented: $showingLogOutActionSheet) {
                ActionSheet(title: Text("logout".localized()), message: Text("logOutAlert".localized()), buttons: [
                    .default(Text("logout".localized())) { viewModel.logOut() },
                    .cancel(Text("Cancel".localized()))])}
            .actionSheet(isPresented: $showingDeleteAccountActionSheet) {
                ActionSheet(title: Text("deleteAccount".localized()), message: Text("deleteAccountAlert".localized()), buttons: [
                    .default(Text("delete".localized())) { viewModel.deleteAccount() },
                    .cancel(Text("Cancel".localized()))])}
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
            .onAppear(){
                viewModel.profile()
                AppState.shared.swipeEnabled = true
            }
            .onReceive(viewModel.$_getData){ value in
                if value {
                    name         = viewModel.profileData?.name ?? ""
                    phone        = viewModel.profileData?.phone ?? ""
//                    selectedProfileImageURL = viewModel.profileData?.profileImage ?? ""
                }
            }
    }
}

#Preview {
    ProfileView()
}

import SwiftUI
import SDWebImageSwiftUI

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
//actionSheet(isPresented: $showingLogOutActionSheet) {
//    ActionSheet(title: Text("Logout".localized()), message: Text("logOutAlert".localized()), buttons: [
//        .default(Text("Logout".localized())) {
//            viewModel.logOut()
//        },
//        .destructive(Text("Cancel".localized())){return}
//    ])
//}
