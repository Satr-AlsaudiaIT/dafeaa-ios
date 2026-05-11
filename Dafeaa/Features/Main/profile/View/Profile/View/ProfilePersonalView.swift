//
//  ProfilePersonalView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProfilePersonalView:  View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    
    // MARK: - State Variables
    @State private var firstName: String = ""
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedCountryCode: String = "" 
    
    @State private var selectedProfileImage: UIImage?
    @State private var selectedProfileImageURL: String? = ""
    @State private var showChangePassword : Bool = false
    @FocusState private var focusedField: FormField?
    @State private var isDataLoaded: Bool = false
    @State private var showDeveloperKeyBottomSheet : Bool = false
    @State var profileId : String = ""
    @State var secretKey : String = ""
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                NavigationBarView(title: "profile"){
                    self.presentationMode.wrappedValue.dismiss()
                }
                VStack{
                    VStack(alignment: .leading,spacing: 24) {
                        ScrollView {
                            VStack(alignment:.leading, spacing: 16) {
                                HStack {
                                    Spacer()
                                    ProfileImageView(selectedImage: $selectedProfileImage, imageURL: $selectedProfileImageURL, isShowFromEdit: true)
                                    Spacer()
                                }.padding(.bottom, 16)
                                
                                // MARK: - Name Fields
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("firstName".localized())
                                        .textModifier(.bold, 15, .black000000)
                                    CustomMainTextField(text: $firstName, placeHolder: "firstName".localized(), image: .nameTFIcon)
                                        .focused($focusedField, equals: .firstName)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("middleName".localized())
                                        .textModifier(.bold, 15, .black000000)
                                    CustomMainTextField(text: $middleName, placeHolder: "middleName".localized(), image: .nameTFIcon)
                                        .focused($focusedField, equals: .middleName)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("lastName".localized())
                                        .textModifier(.bold, 15, .black000000)
                                    CustomMainTextField(text: $lastName, placeHolder: "lastName".localized(), image: .nameTFIcon)
                                        .focused($focusedField, equals: .lastName)
                                }
                                
                                if email != "" {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Email".localized())
                                            .textModifier(.bold, 15, .black000000)

                                        CustomMainTextField(text: $email, placeHolder: "Email", image: .mailTFIcon)
                                            .focused($focusedField, equals: .email)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("phoneNumber".localized())
                                        .textModifier(.bold, 15, .black000000)

                                    PhoneNumberField(
                                        phoneNumber: $phoneNumber,
                                        selectedCountryCode: $selectedCountryCode,
                                        image: .mobile
                                    )
                                    .focused($focusedField, equals: .phone)
                                    .id(FormField.phone)
                                    .disabled(true)
                                    .opacity(0.6)
                                }
                            }
                        }
                    }
                    Spacer()
                    ReusableButton(buttonText: "saveBtn", isEnabled:
                        firstName  != (viewModel.profileData?.firstName  ?? "") ||
                        middleName != (viewModel.profileData?.middleName ?? "") ||
                        lastName   != (viewModel.profileData?.lastName   ?? "") ||
                        email      != (viewModel.profileData?.email      ?? "") ||
                        selectedProfileImage != nil
                    ) {
                        viewModel.validateEditProfile(firstName: firstName, middleName: middleName, lastName: lastName, email: email, image: selectedProfileImage)
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
        .onReceive(viewModel.$_getData) { value in
            if value {
                firstName               = viewModel.profileData?.firstName  ?? ""
                middleName              = viewModel.profileData?.middleName ?? ""
                lastName                = viewModel.profileData?.lastName   ?? ""
                email                   = viewModel.profileData?.email      ?? ""
                phoneNumber             = viewModel.profileData?.phone      ?? ""
                selectedProfileImageURL = viewModel.profileData?.profileImage ?? ""
                self.isDataLoaded = true
            }
        }
        .onReceive(viewModel.$_isSuccess){ value in  if value { self.presentationMode.wrappedValue.dismiss()} }
        .onChange(of: viewModel.profileData?.secretKey ?? "", { _, newValue in
            secretKey = newValue
        })
        .customBottomSheet(isPresented: $showDeveloperKeyBottomSheet, detents: [.medium,.large]){
            DeveloperKeyBottomSheet(isSheetPresented: $showDeveloperKeyBottomSheet, profileID: $profileId, secretKey: $secretKey )
        }
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
    }
    
    func showNextTextField() {
        switch focusedField {
        case .firstName:    focusedField = .middleName
        case .middleName:   focusedField = .lastName
        case .lastName:     focusedField = .email
        default:            focusedField = nil
        }
    }

    func showPerviousTextField() {
        switch focusedField {
        case .email:        focusedField = .lastName
        case .lastName:     focusedField = .middleName
        case .middleName:   focusedField = .firstName
        default:            focusedField = nil
        }
    }

    enum FormField {
        case firstName, middleName, lastName, email, phone
    }
    
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

#Preview {
    ProfilePersonalView()
}
