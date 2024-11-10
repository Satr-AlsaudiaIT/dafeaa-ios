//
//  CompleteDataView 2.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//

import SwiftUI

struct CompleteDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var phone: String
    @State private var isCountryDropDownOpen: Bool? = false
    @State private var isCityDropDownOpen: Bool? = false
    @State private var selectedCountryName: String = ""
    @State private var commercialName: String = ""
    @State private var area: String = ""
    @State private var taxNumber: String = ""
    @State private var selectedCityName: String = ""
    @State private var selectedCommercialLicense: UIImage?
    @State private var selectedCommercialLicenseUrl: String?
    @State private var testOptions: [String] = ["ssss","aaaa"]
    @State private var endDateString: String = ""
    @State var endDate : Date?
    var selectedOption: AccountTypeOption = .none
    @StateObject var viewModel = AuthVM()
    @FocusState private var focusedField: FormField?
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading , spacing: 16) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }
                    }) {
                        Image(.arrowRight)
                            .resizable()
                            .frame(width: 32,height: 32)
                            .foregroundColor(.black222222)
                    }
                    Spacer()
                    
                }
                .padding(.horizontal)
                VStack(alignment:.leading,spacing:8){
                    Text("أضف بيانات نشاطك التجاري".localized())
                        .textModifier(.plain, 19, .black222222)
                    
                    // Subtitle
                    Text("لإنشاء حساب جديد معنا برجاء اضافة بعض معلومات نشاطك التجاري ليتم التعرف اليكم.".localized())
                        .textModifier(.plain, 15, .gray666666)
                    
                }
                .padding(.horizontal)
                ScrollView (showsIndicators: false){
                    VStack(alignment:.leading, spacing: 8) {
                        VStack(alignment:.leading,spacing:8){
                            Text("CommercialInfo".localized())
                                .textModifier(.plain, 19, .black222222)
                            
                            CustomMainTextField(text: $commercialName, placeHolder: "commercialName".localized(), image: .shop)
                                .focused($focusedField, equals: .commercialName)
                            
                            DropdownSearchTF(placeHolder:"CountryField".localized(),
                                             isOpen: $isCountryDropDownOpen,
                                             text: $selectedCountryName, title: "CountryField".localized(),
                                             options: $viewModel.countriesNames,
                                             submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                            .focused($focusedField, equals: .countryField)
                            .onChange(of: selectedCountryName) { _, newValue in
                                let countryId = viewModel.getCountryId(countryName: selectedCountryName)
                                viewModel.getCities(countryId: countryId)
                            }
                            DropdownSearchTF(placeHolder:"CityField".localized(),
                                             isOpen: $isCityDropDownOpen,
                                             text: $selectedCityName, title: "CityField".localized(),
                                             options: $viewModel.cityNames,
                                             submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                            .focused($focusedField, equals: .cityField)

                            CustomMainTextField(text: $area, placeHolder: "area".localized(), image: .location)
                                .focused($focusedField, equals: .areaField)

                            CustomMainTextField(text: $taxNumber, placeHolder: "taxNumber".localized(), image: .tax)
                                .focused($focusedField, equals: .taxField)

                            Text("CommLecs".localized())
                                .textModifier(.plain, 19, .black222222)
                                .padding(.top,8)
                            UploadFileView(selectedImage: $selectedCommercialLicense, imageURL: $selectedCommercialLicenseUrl,title: "CommLecs".localized())
                                .frame(height: 127)
                                .padding([.top,.bottom],7)
                            DateTF(title: "endDate".localized(), image: .calendar, currentIsMinDate: true, submitLabel: .next, placeHolder: "endDate".localized(), text: $endDateString, date: $endDate)
                                .focused($focusedField, equals: .dateField)

                            
                        }
                        Spacer()
                    }
                    ReusableButton(buttonText: "sendData", isEnabled: true) {
                        
                        viewModel.validateBusiness(phone: phone, commLecs: selectedCommercialLicense, name: commercialName, country: selectedCountryName, city: selectedCityName, area: area, taxNum: taxNumber, endDate: endDateString)
                    }.navigationDestination(isPresented: $viewModel._isSignUpSuccess) {
                        PendingView()
                    }
                    
                    
                }
                .padding(24)
                
            }
            .navigationBarHidden(true)
            .toastView(toast: $viewModel.toast)
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard){
                Button("Done".localized()){
                    hideKeyboard()
                }
                Spacer()
                Button(action: {
                    //                    showPerviousTextField()
                }, label: {
                    Image(systemName: "chevron.up").foregroundColor(.blue)
                })
                
                Button(action: {
                    //                    showNextTextField()
                }, label: {
                    Image(systemName: "chevron.down").foregroundColor(.blue)
                })
            }
        }
        .onAppear{
            viewModel.getCountries()
        }
    }
        func showNextTextField(){
            switch focusedField {
            case .commercialName:
                focusedField = .countryField
            case .countryField:
                focusedField = .cityField
            case .cityField:
                focusedField = .areaField
            case .areaField:
                focusedField = .taxField
            case .taxField:
                focusedField = .dateField
            default:
                focusedField = nil
            }
        }
        
        func showPerviousTextField(){
            switch focusedField {
            case .dateField:
                focusedField = .taxField
            case .taxField:
                focusedField = .areaField
            case .areaField:
                focusedField = .cityField
            case .countryField:
                focusedField = .commercialName
            default:
                focusedField = nil
            }
        }
        
        enum FormField {
            case commercialName, countryField, cityField, areaField, taxField, dateField
        }
        
        
    
    
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CompleteDataView(phone: "")
}
