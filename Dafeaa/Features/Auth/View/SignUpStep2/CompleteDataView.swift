//
//  CompleteDataView 2.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//

import SwiftUI

struct CompleteDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isCountryDropDownOpen: Bool? = false
    @State private var isCityDropDownOpen: Bool? = false
    @State private var selectedCountryName: String = ""
    @State private var shopName: String = ""
    @State private var area: String = ""
    @State private var selectedCityName: String = ""
    @State private var selectedCommercialLicense: UIImage?
    @State private var selectedCommercialLicenseUrl: String?
    @State private var testOptions: [String] = ["ssss","aaaa"]
    @State private var endDateString: String = ""
    @State var endDate : Date?
    var selectedOption: AccountTypeOption = .none
    @StateObject var viewModel = AuthVM()
    //    @FocusState private var focusedField: FormField?
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading , spacing: 16) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }
                    }) {
                        Image(.arrowLeft)
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
                            
                            CustomMainTextField(text: $shopName, placeHolder: "commercialName".localized(), image: .shop)
                            //                            .focused($focusedField, equals: .userName)
                            
                            DropdownSearchTF(placeHolder:"CountryField".localized(),
                                             isOpen: $isCountryDropDownOpen,
                                             text: $selectedCountryName, title: "CountryField".localized(),
                                             options: $testOptions,
                                             submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                            DropdownSearchTF(placeHolder:"CityField".localized(),
                                             isOpen: $isCityDropDownOpen,
                                             text: $selectedCityName, title: "CityField".localized(),
                                             options: $testOptions,
                                             submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                            CustomMainTextField(text: $area, placeHolder: "area".localized(), image: .location)
                            Text("CommLecs".localized())
                                .textModifier(.plain, 19, .black222222)
                                .padding(.top,8)
                            UploadFileView(selectedImage: $selectedCommercialLicense, imageURL: $selectedCommercialLicenseUrl,title: "CommLecs".localized())
                                .frame(height: 127)
                                .padding([.top,.bottom],7)
                            DateTF(title: "endDate".localized(), image: .calendar, currentIsMinDate: true, submitLabel: .next, placeHolder: "endDate".localized(), text: $endDateString, date: $endDate)
//                                .padding(.leading,-10)
                                
                        }
                        Spacer()
                    }
                    ReusableButton(buttonText: "sendData".localized(), isEnabled: true) {
                        
                        
                    }
                   
                   
                }
                .padding(24)
                if viewModel.isLoading {
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                } else if viewModel.isFailed {
                    ProgressView()
                        .hidden()
                }
            }
            .navigationBarHidden(true)
            .toastView(toast: $viewModel.toast)
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

//        func showNextTextField(){
//            switch focusedField {
//            case .userName:
//                focusedField = .email
//            case .email:
//                focusedField = .phone
//            case .phone:
//                focusedField = .password
//            case .password:
//                focusedField = .confirmPassword
//            default:
//                focusedField = nil
//            }
//        }
        
//        func showPerviousTextField(){
//            switch focusedField {
//            case .confirmPassword:
//                focusedField = .password
//            case .password:
//                focusedField = .phone
//            case .phone:
//                focusedField = .email
//            case .email:
//                focusedField = .userName
//            default:
//                focusedField = nil
//            }
//        }
        
//        enum FormField {
//            case userName, email, phone, password, confirmPassword
//        }
        
        
    
    }
    func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CompleteDataView()
}
