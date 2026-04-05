//
//  ClientLinkDetailsNew.swift
//  Dafeaa
//
//  Created by AMNY on 07/11/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ClientLinkDetailsNew: View {
    let code: String = Constants.clientOrderCode
    @State var offerData: ShowOfferData?
    @StateObject var viewModel = OrdersVM()
    @State var productAmountDic: [[String:Any]] = []
    @State var amount : Int = 0
    @State var totalPrice: Double = 0
    @State var amountChanged: Bool = false
    @State var addressId:Int = Constants.selectedAddressId
    @State var address: String = Constants.selectedAddress
    @State var isNavigateToAddress: Bool = false
    @State var showingProductDetails: Bool = false
    @State var isAmountInCellDisabled: Bool = false
    @State var showOrderDetails: Bool = false
    @State private var  selectedImage: String?
    @State private var showSelectedImage: Bool = false
    @State var selectedShippingCompany: String? = "DHL"
    @State var showDescription: Bool = false
    @State var quantity : String = ""
    @State var shippingPrice: Double = 0

//MARK: - properties for loginSheet
    @State private var loginPhone: String = ""
    @State private var loginPassword: String = ""
    @State private var loginCountryCode: String = ""
    @State private var loginShowForgetPassword: Bool = false
    @State private var loginShowSignUp: Bool = false
    @StateObject private var loginViewModel = AuthVM()
    @FocusState private var loginFocusedField: LoginFormField?

    enum LoginFormField { case phone, password }

    
     var isAbleToEdit : Bool = false
     var isMerchant : Bool = false
    var isLogedIn : Bool {
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        return token != "" ? true : false
    }
    @State private var showAlertToLogin: Bool = false
    
    @State var selectedProduct: productList = productList(id: 3, images: [ImageModel(file: "ww")], name: "phone", description: "good phones and very helpful ones that is very harm full", price: 1000,amount: 1, offerPrice: 950, totalQuantity: 1, paiedQuantity: 0, remainingQuantity: 1)
    var linkDetails: ShowOfferData  {
        return viewModel.offersData ?? ShowOfferData(
            id: 0,
            name: "",
            code: "",
            description: "",
            clientId: 1,
            deliveryPrice: 1,
            taxPrice: 1,
            products: [],
            status: 0,
            commissionRatio: "",
            maxCommissionValue: "",
            shippingCompanies: [],
            address: nil,
            shipmentFree: nil,
            hasTaxRecord: nil,
            priceCommission: nil,
            shippingCommission: nil,
            seller: nil
        )
    }
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(alignment: .leading) {
                    NavigationBarView(title: "offerDetails".localized()) {
                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                        
                        MOLH.reset()
                    }
//                    if !viewModel.isLoading {
                        ScrollView {
                            VStack(alignment: .leading,spacing: 19) {
                                //                            Text(linkDetails.name ?? "")
                                //                                .textModifier(.plain, 16, .black010202)
                                //                            Text(linkDetails.description ?? "")
                                //                                .textModifier(.plain, 15, .black222222)
                                //                                .padding(.top,-10)
                                if viewModel.offersData?.status == 2 {
                                    Text("orderNotAvailable".localized())
                                        .textModifier(.plain, 15, .redFA4248)
                                }
                                if linkDetails.products?.count ?? 0 > 0, let product = linkDetails.products?.first  {
                                    VStack(alignment: .leading) {
                                        VStack {
                                            InfiniteCarouselView(listOfPages: .constant(product.images ?? []),onImageTap: { file in
                                                selectedImage = file
                                                showSelectedImage = true
                                            }).onAppear{
                                                showDescription = true
                                            }
                                            HStack{
                                                Text(product.name ?? "")
                                                    .textModifier(.plain, 15, .black222222)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            HStack {
                                                HStack {
                                                    HStack(spacing: 5){
                                                        Text(String(format: "%.1f", product.price ?? 0))
                                                            .textModifier(.plain, 14, .black010202)
                                                            .strikethrough((product.offerPrice == 0 || product.offerPrice == nil) ? false : true, color: .black010202)
                                                            .fixedSize()
                                                        Image(.riyal)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .foregroundColor(.gray8B8C86)
                                                            .frame(width: 20)
                                                            .padding(.trailing, 10)
                                                    }
                                                    .environment(\.layoutDirection, .rightToLeft)
                                                    if product.offerPrice != 0, product.offerPrice != nil {
                                                        HStack(spacing: 5){
                                                            Text(String(format: "%.1f", product.offerPrice ?? 0))
                                                                .textModifier(.plain, 14, .black010202)
                                                                .fixedSize()
                                                            Image(.riyal)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .foregroundColor(.gray8B8C86)
                                                                .frame(width: 20)
                                                                .padding(.trailing, 10)
                                                        }
                                                        .environment(\.layoutDirection, .rightToLeft)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            if showDescription {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    HStack {
                                                        
                                                        HTMLDescriptionView(html: product.description ?? "")
                                                        Spacer()
                                                    }
                                                }
                                            }
                                        }
                                        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                                    }
                                    .onAppear {
                                        let initialAmount = 1
                                        productAmountDic.append(["product_id": product.id ?? 0, "amount": "\(initialAmount)"])
                                        calculateTotalPrice()
                                    }
                                }
                                
                                
                                
                                if isLogedIn {
                                    HStack {
                                        Text("deliveryAddress".localized())
                                            .textModifier(.plain, 15, .black010202)
                                        Spacer()
                                        Button(action: {
                                            isNavigateToAddress = true
                                        }) {
                                            Text(addressId == 0 ? "select".localized() : "edit".localized())
                                                .textModifier(.plain, 15, Color(.primary))
                                        }
                                    }
                                }
                                if addressId != 0, isLogedIn  {
                                    ZStack {
                                        HStack {
                                            Text(address)
                                                .textModifier(.plain, 12, .grayAAAAAA)
                                            Spacer()
                                        }
                                        .padding(.all, 10)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.grayAAAAAA), lineWidth: 0.4)
                                    )
                                    
                                }
                                if let shippingCompanies = linkDetails.shippingCompanies, !shippingCompanies.isEmpty,  isLogedIn  {
                                    ShippingCompanySelectionView(
                                        selectedCompany: $selectedShippingCompany,
                                        availableCompanies: shippingCompanies,
                                        showRadioButtons: true
                                    )
                                    .padding(.top, 8)
                                }
                                
                                if let offersData = viewModel.offersData {
                                    ClientPaymentInfoView(
                                        offerData: offersData,
                                        shippingPrice: $shippingPrice,
                                        isLoggedIn: isLogedIn
                                    )
                                }
                                
                                ReusableButton(buttonText: "orderNow",
                                               isEnabled: viewModel.offersData?.status == 1 ? true : false){
                                    if isLogedIn {
                                        viewModel.validations(dynamicLinkId: viewModel.offersData?.id ?? 0, addressId: addressId, products: productAmountDic)
                                    }else {
                                        showAlertToLogin = true
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.all,24)
                            .navigationDestination(isPresented: $isNavigateToAddress) {
                                SavedAddressesView(selectedAddressId: $addressId, selectedAddress: $address,initSelectedAddressId: addressId,isComingFromSelection: true)
                            }
                            .onChange(of: viewModel.isOrderSuccess) { _, newValue in
                                if newValue {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                                        MOLH.reset()
                                    }
                                }
                            }
                          
                        }
//                    }
                    Spacer(minLength: 0)
                }
                if let selectedImage = selectedImage, showSelectedImage {
                    ZStack {
                        Color(.black010202.opacity(0.5))
                            .onTapGesture {
                                showSelectedImage = false
                            }
                        WebImage(url: URL(string: selectedImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: UIScreen.main.bounds.width * 0.9)
                            .disabled(true)
                            .cornerRadius(10)
                    }
                    .ignoresSafeArea(.all)
                    
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
            .onChange(of: viewModel.offersData, { oldValue, newValue in
                isAmountInCellDisabled = viewModel.offersData?.status == 2 ? true : false
            })
            .sheet(isPresented: $showingProductDetails, onDismiss: {
                showingProductDetails = false
            }, content: {
                ProductDetailsPopUp(product: $selectedProduct)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            })
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
            
            .onAppear{
                Constants.resetFromLinkLogin = false
                
                //                Constants.offerDataAfterLoginResetFromLink = nil
                UserDefaults.standard.set(nil, forKey:  Constants.shared.offerDataAfterLoginResetFromLink)
                
                if let offerData {
                    viewModel.offersData = offerData
                } else { viewModel.showOffer(code: code) }
            }
            .onChange(of: viewModel.offersData) { _, _ in
                selectedShippingCompany = viewModel.offersData?.shippingCompanies?.first
            }
            .onChange(of: selectedShippingCompany, { _, _ in
                viewModel.getShippingRates(company: /*selectedShippingCompany ??*/  "dhl", for: viewModel.offersData?.products?.first?.id ?? 1,/* from: viewModel.offersData?.address?.id ?? 1,*/ to: addressId)
            })
            .onChange(of: addressId) { _, newValue in
                viewModel.getShippingRates(company: /*selectedShippingCompany ??*/ "dhl", for: viewModel.offersData?.products?.first?.id ?? 1, /*from: viewModel.offersData?.address?.id ?? 1,*/ to: addressId)
            }
            .onChange(of: viewModel.shippingRatePrice) { _, _ in
                shippingPrice = viewModel.shippingRatePrice ?? 0
            }
            .sheet(isPresented: $showAlertToLogin) {
                loginSheetContent()
            }
            .navigationDestination(isPresented: $loginShowForgetPassword) {
                ForgotPasswordView()
            }
            .navigationDestination(isPresented: $loginShowSignUp) {
                SignUpStep2View()
            }
            .navigationDestination(isPresented: $loginViewModel._isSendCodeSuccess) {
//                showAlertToLogin = false
                OTPConfirmationView(phone: loginPhone.normalizePhoneNumber)
            }
            .navigationDestination(isPresented: $loginViewModel._hasUnCompletedData) {
//                showAlertToLogin = false
                CompleteDataView(phone: loginPhone.normalizePhoneNumber)
            }
            
        }
        
    }
    // Function to calculate the total price
     private func calculateTotalPrice() {
         totalPrice = productAmountDic.reduce(0) { result, dict in
             guard
                 let productId = dict["product_id"] as? Int,
                 let amount = dict["amount"] as? String,
                 let product = linkDetails.products?.first(where: { $0.id == productId })
             else {
                 return result
             }
             
             let price = product.offerPrice ?? product.price
             return result + (Double(price ?? 0) * (Double(amount) ?? 0))
         }
     }
    private func resetAppAfterLogin() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
    
        let code = Constants.clientOrderCode
        Constants.resetFromLinkLogin = true
//        Constants.offerUserIdAfterLoginResetFromLink = viewModel.offersData?.id ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // If the offer data is already loaded, go directly
            if let offerData = viewModel.offersData {
                appDelegate.navToOffer(
                    offerData: offerData,
                    offerUserId: offerData.clientId ?? 0
                )
            } else {
                appDelegate.handleDeepLinkNav(code: code)
            }
        }
    }
    
    
    // MARK: - Login Sheet
    @ViewBuilder
    private func loginSheetContent() -> some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12) {
                    VStack(spacing: 5) {
                        Text("loginWelcome".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("loginWelcomeSubtitle".localized())
                            .textModifier(.plain, 15, .grayAAAAAA)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal,24)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            PhoneNumberField(
                                phoneNumber: $loginPhone,
                                selectedCountryCode: $loginCountryCode,
                                image: .mobile)
                            .focused($loginFocusedField, equals: .phone)

                            CustomPasswordField(password: $loginPassword)
                                .focused($loginFocusedField, equals: .password)

                            ReusableButton(buttonText: "login") {
                                loginViewModel.validateLogin(
                                    phone: loginPhone.normalizePhoneNumber,
                                    password: loginPassword,
                                    isFromGuestMode: true)
                            }
                            .padding(.top, 4)

                            Button {
                                loginShowForgetPassword = true
                                showAlertToLogin = false
                            } label: {
                                Text("forgetPassword".localized())
                                    .textModifier(.plain, 15, .gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    HStack {
                        Text("haventAccount".localized())
                            .textModifier(.plain, 16, .black222222)
                        Button {
                            loginShowSignUp = true
                            showAlertToLogin = false
                        } label: {
                            Text("openAccount".localized())
                                .textModifier(.plain, 16, Color(.primary))
                        }
                    }
                    .padding(.bottom, 20)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Done".localized()) {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        Spacer()
                        Button { loginFocusedField = .phone } label: {
                            Image(systemName: "chevron.up").foregroundColor(.blue)
                        }
                        Button { loginFocusedField = .password } label: {
                            Image(systemName: "chevron.down").foregroundColor(.blue)
                        }
                    }
                }
               

                if loginViewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if loginViewModel.isFailed {
                    ProgressView().hidden()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loginPhone = ""
                loginPassword = ""
            }
            .onChange(of: loginViewModel.isLoginSuccess) { _, success in
                if success {
                    showAlertToLogin = false
                    Constants.resetFromLinkLogin = true
                    if let encoded = try? JSONEncoder().encode(offerData) {
                        UserDefaults.standard.set(
                            encoded,
                            forKey: Constants.shared.offerDataAfterLoginResetFromLink)
                    }
                    MOLH.reset()
                }
            }
            .toastView(toast: $loginViewModel.toast)
        }
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large])
        .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
    }


}

#Preview {
    ClientLinkDetails()
}



