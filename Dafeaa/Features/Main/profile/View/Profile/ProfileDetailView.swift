//
//  ProfileDetailView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProfileDetailView:  View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    @State private var name : String =  ""
    @State private var email:String = ""
    @State private var selectedProfileImage: UIImage?
    @State private var selectedProfileImageURL: String? = ""
    @State private var showChangePassword : Bool = false
    @FocusState private var focusedField: FormField?
    @State private var isDataLoaded: Bool = false
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                NavigationBarView(title: "profile"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                VStack{
                    VStack(alignment: .leading,spacing: 24) {
                        ScrollView {
                            VStack(alignment:.leading, spacing: 8) {
                                HStack {
                                    Spacer()
                                        ProfileImageView(selectedImage: $selectedProfileImage, imageURL: $selectedProfileImageURL, isShowFromEdit: true)
                                    
                                    Spacer()
                                }.padding(.bottom, 16)
                                CustomMainTextField(text: $name, placeHolder: "Name", image: .nameTFIcon)
                                    .focused($focusedField, equals: .userName)
                               
                                CustomMainTextField(text: $email, placeHolder: "Email", image: .mailTFIcon)
                                    .focused($focusedField, equals: .email)
                                
                                Button(action: {
                                    // Handle forgot password action
                                    showChangePassword = true
                                }) {
                                    Text("changePassword".localized())
                                        .textModifier(.plain, 15, .gray)
                                        .frame(maxWidth:.infinity,alignment: .trailing)
                                }
                            }
                            
                            
                            .navigationDestination(isPresented: $showChangePassword) {
                                ChangePasswordView()
                            }
                            
                        }
                        
                    }
                    Spacer()
                    ReusableButton(buttonText: "saveBtn",isEnabled: (name != viewModel.profileData?.name ?? "")||(email != viewModel.profileData?.email ?? "") || (selectedProfileImage != nil) ){
                        viewModel.validateEditProfile(name: name, email: email, image: selectedProfileImage)
                    }
                }.padding(24)
            }
            .toolbar{
                ToolbarItemGroup(placement: .keyboard){
                    Button("Done".localized()){
                        hideKeyboard()
                    }
                    Spacer()
                    Button(action: {
                           showPerviousTextField()
                    }, label: {
                        Image(systemName: "chevron.up").foregroundColor(.blue)
                    })
                    
                    Button(action: {
                        showNextTextField()
                    }, label: {
                        Image(systemName: "chevron.down").foregroundColor(.blue)
                    })
                }
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
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear(){   viewModel.profile()
                       AppState.shared.swipeEnabled = true }
        .onReceive(viewModel.$_getData){ value in
            if value { name                    = viewModel.profileData?.name ?? ""
                email                   = viewModel.profileData?.email ?? ""
                selectedProfileImageURL = viewModel.profileData?.profileImage ?? ""
                self.isDataLoaded = true
            } }
        .onReceive(viewModel.$_isSuccess){ value in  if value { self.presentationMode.wrappedValue.dismiss()} }
        
    }
    func showNextTextField(){
        switch focusedField {
        case .userName:
            focusedField = .email
            
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .email:
            focusedField = .userName
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case userName, email
    }
    
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

#Preview {
    ProfileDetailView()
}

