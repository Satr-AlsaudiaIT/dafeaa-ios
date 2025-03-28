//
//  ProfileView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MoreVM()
    @State private var name =  ""
    @State private var phone = ""
    let type = GenericUserDefault.shared.getValue(Constants.shared.userType) as? Int ?? 0
    @State private var showingLogOutActionSheet = false
    @State private var isActiveActionSheet = false
    @State private var showingChangePhone = false
    @State private var activeActionSheet: ActiveSheet?
    @State private var showCompleteDataPopup: Bool = false
    @State private var navigateToPendingView: Bool = false
    @State private var navigateToOffers: Bool = false
    @State private var navigateToCompleteProfileView: Bool = false
    @State private var businessInfo: BusinessInfo = .noFilesUploaded
    @State private var navigateToSubscriptionView = false
    enum ActiveSheet {
           case logOut, deleteAccount
       }
    
    var body: some View {
        ZStack{
            VStack() {
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
                                destination: ProfileList(),
                                label: "profile",
                                image: Image(.iconProfile)
                            )
                            
                            
                            
                            NavigationLinkComponent(
                                destination: StaticPagesList(),
                                label: "About Dafeaa",
                                image: Image(.iconAbout)
                            )
                            NavigationLinkComponent(
                                destination: WithdrawsView(),
                                label: "withdrawsProcess",
                                image: Image(.withdrawBalance)
                            )
                            
                            HStack(spacing:12) {
                                Image(.inviteFriend)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 28, height: 28)
                                
                                Text("invite_friend".localized())
                                    .textModifier(.plain, 16, .black194558)
                                Spacer()
                                
                                Image(.iconArrowNav)
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(Color(.black194558))
                            }
                            .frame(height: 32)
                            .onTapGesture {
                             
                            }
                            
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
                                isActiveActionSheet = true
                                activeActionSheet = .deleteAccount
                                
                            }){
                                Text("deleteAccount".localized())
                                    .textModifier(.plain, 16, .redFA4248)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }
                    }
                    
                }.padding([.top,.trailing,.leading],24)
                Button(action: {
                    isActiveActionSheet = true
                    activeActionSheet = .logOut
                }) {
                    Text("logout".localized())
                        .textModifier(.semiBold, 15, .redFA4248)
                        .frame(maxWidth:.infinity)
                        .frame(height:51)
                        .background(.redFA4248.opacity(0.1))
                        .cornerRadius(5)
                }
                .padding(20)
                
            }.navigationDestination(isPresented: $showingChangePhone) {
                ChangePhoneView()
            }
            .actionSheet(isPresented: $isActiveActionSheet) {
                switch activeActionSheet {
                           case .logOut:
                               return ActionSheet(
                                   title: Text("logout".localized()),
                                   message: Text("logOutAlert".localized()),
                                   buttons: [
                                       .default(Text("logout".localized())) { viewModel.logOut() },
                                       .cancel(Text("Cancel".localized()))
                                   ]
                               )
                           case .deleteAccount:
                               return ActionSheet(
                                   title: Text("deleteAccount".localized()),
                                   message: Text("deleteAccountAlert".localized()),
                                   buttons: [
                                       .default(Text("deleteAccount".localized())) { viewModel.deleteAccount() },
                                       .cancel(Text("Cancel".localized()))
                                   ]
                               )
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
            .navigationDestination(isPresented: $navigateToCompleteProfileView, destination: {
                CompleteDataView(phone:phone)
            })
            .navigationDestination(isPresented: $navigateToPendingView) {
                PendingView()
            }
            .navigationDestination(isPresented: $navigateToOffers, destination: {
                OrdersOffersLinksView()
            })
            .navigationDestination(isPresented: $navigateToSubscriptionView) {
                SubscribtionView()
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
            .onAppear(){
                viewModel.profile()
                AppState.shared.swipeEnabled = true
            }
            .onReceive(viewModel.$_getData){ value in
                if value {
                    name         = viewModel.profileData?.name ?? ""
                    phone        = viewModel.profileData?.phone?.convertDigitsToEng ?? ""
                    
                    businessInfo = BusinessInfo(rawValue: viewModel.profileData?.businessInformationStatus ?? 0) ?? .noFilesUploaded
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

enum BusinessInfo: Int {
    case noFilesUploaded = 0
    case pending = 1
    case accepted = 2
}
