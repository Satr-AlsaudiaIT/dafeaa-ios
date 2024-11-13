//
//  AddProductView.swift
//  Dafeaa
//
//  Created by AMNY on 10/11/2024.
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = OrdersVM()
    @State var selectedImage: UIImage?
    @State var imageURL: String?
    @State var nameAr: String = ""
    @State var nameEn: String = ""
    @State var descriptionAr: String = ""
    @State var descriptionEn: String = ""
    @State var price: String = ""
    @State var offerPrice: String = ""
    @Binding var productsAdding: [[String:Any]]
    @FocusState private var focusedField: FormField?

    var body: some View {
        
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: "addProductTitle"){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    UploadFileView(selectedImage: $selectedImage, imageURL: $imageURL)
                        .padding(.top,24)
                    VStack(spacing: 20) {
                        CustomMainTextField(text: $nameAr, placeHolder: "nameAr", fieldType: .arabicOnly)
                            .focused($focusedField, equals: .nameAr)
                            .id(FormField.nameAr)
                        CustomMainTextField(text: $nameEn, placeHolder: "nameEn",fieldType: .englishOnly)
                            .focused($focusedField, equals: .nameEn)
                            .id(FormField.nameEn)
                        CustomMainTextField(text: $descriptionAr, placeHolder: "descriptionAr", fieldType:.arabicOnly)
                            .focused($focusedField, equals: .descriptionAr)
                            .id(FormField.descriptionAr)
                        CustomMainTextField(text: $descriptionEn, placeHolder: "descriptionEn", fieldType: .englishOnly)
                            .focused($focusedField, equals: .descriptionEn)
                            .id(FormField.descriptionEn)
                        HStack(spacing: 20) {
                            CustomMainTextField(text: $price, placeHolder: "productPrice",keyBoardType: .numberPad,fieldType: .price)
                                .focused($focusedField, equals: .price)
                                .id(FormField.price)
                            CustomMainTextField(text: $offerPrice, placeHolder: "offerPrice",keyBoardType: .numberPad,fieldType: .price)
                                .focused($focusedField, equals: .offerPrice)
                                .id(FormField.offerPrice)
                        }
                        Spacer()
                        ReusableButton(buttonText: "addProductTitle") {
                            if let product = viewModel.validateAddOrder(image: selectedImage, nameAr: nameAr, nameEn: nameEn, descriptionAr: descriptionAr, descriptionEn: descriptionEn, price: price, offerPrice: offerPrice) {
                                productsAdding.append(product)  // Update the binding array
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.top,10)
                    
                    
                }
                .onChange(of: viewModel._isAddProDuctValid) { oldValue, newValue in
                    if newValue {
                        self.presentationMode.wrappedValue.dismiss()
                        viewModel._isAddProDuctValid = false
                    }
                }
                Spacer()
                
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
        .edgesIgnoringSafeArea(.bottom)
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
            .onAppear(){
                AppState.shared.swipeEnabled = true
            }
    }
    
    func showNextTextField(){
        switch focusedField {
        case .nameAr:
            focusedField = .nameEn
        case .nameEn:
            focusedField = .descriptionAr
        case .descriptionEn:
            focusedField = .price
        case .price:
            focusedField = .offerPrice
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .offerPrice:
            focusedField = .price
        case .price:
            focusedField = .descriptionEn
        case .descriptionEn:
            focusedField = .descriptionAr
        case .descriptionAr:
            focusedField = .nameEn
        case .nameEn:
            focusedField = .nameAr
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case nameAr, nameEn, descriptionAr, descriptionEn, price, offerPrice
    }
}

#Preview {
    AddProductView(productsAdding: .constant([[:]]))
}
