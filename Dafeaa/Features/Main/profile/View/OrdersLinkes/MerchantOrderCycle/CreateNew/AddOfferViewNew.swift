//
//  AddOfferViewNew.swift
//  Dafeaa
//
//  Created by AMNY on 16/06/2025.
//

import SwiftUI


struct AddOfferViewNew: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = OrdersVM()
    @State var goToAddOffer = false

    @State private var deliveryPrice: String = ""
    @State private var tax: String = ""
    @FocusState private var focusedField: FormField?
    @State var navigateToAddProduct: Bool = false
    @State var productsAdding: [[String: Any]] = []
    @State var selectedImage: UIImage?
    @State var imageURL: String?
    @State var name: String = ""
    @State var description: String = ""
    @State var quantity: String = ""
    
    @State private var selectedProductImage :[UIImage] = []
    @State private var isShowingImagesSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isShowingImagesPicker = false
    
    @State var price: String = ""
    @State var offerPrice: String = ""
    @State private var showOfferPriceTextField: Bool = false
    
    @State private var descriptionAttributed = NSAttributedString(string: "")
    @State private var weight = ""
    @State private var length = ""
    @State private var width = ""
    @State private var height = ""
    @State private var daysNumber = ""

    @State private var selectedShippingCompanies: [ShippingCompany] = []
    @State private var isShippingDropDownOpen: Bool = false
    
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: "offerContent"){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    ScrollView {
                        VStack(spacing: 17) {
                            VStack(spacing: 8) {
                                CustomMainTextField(text: $name, placeHolder: "Name",showHeader: true)
                                    .focused($focusedField, equals: .name)
                                    .id(FormField.name)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("productDescription".localized())
                                        .textModifier(.plain, 14, .black)
                                    RichTextEditorView(
                                        attributedText: $descriptionAttributed,
                                        placeholder: "productDescription".localized()
                                    )
                                }
                            }
                            
                            CustomMainTextField(text: $price, placeHolder: "productPrice",keyBoardType: .numberPad,fieldType: .price, showHeader: true)
                                .focused($focusedField, equals: .price)
                                .id(FormField.price)
                            
                            if showOfferPriceTextField {
                                CustomMainTextField(text: $offerPrice,
                                                   placeHolder: "offerPrice",
                                                   keyBoardType: .numberPad,
                                                   fieldType: .price,
                                                    showHeader: true)
                                    .focused($focusedField, equals: .offerPrice)
                                    .id(FormField.offerPrice)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.3), value: showOfferPriceTextField)
                            }

                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showOfferPriceTextField.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(showOfferPriceTextField == true ? "hide_discount?".localized() : "apply_discount?".localized())
                                        .textModifier(.plain, 14, .primaryF9CE29)
                                        .underline()
                                    Spacer()
                                }
                                .padding(.top,-10)
                            }

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                                
                                let validateIndex = (selectedProductImage.count)
                                if validateIndex < 4 {
                                    Button {
                                        isShowingImagesSheet = true
                                    } label: {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color(.primaryF9CE29).opacity(0.1))
                                                .cornerRadius(10)
                                                .frame(width: (UIScreen.main.bounds.width - 80 ) / 4 ,height: (UIScreen.main.bounds.width - 80 ) / 4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                                        .foregroundColor(Color(.primaryF9CE29))
                                                )
                                            VStack {
                                                Spacer()
                                                Image(systemName: "plus")
                                                    .foregroundColor(Color(.gray979797))
                                                Text("Image".localized())
                                                    .textModifier(.plain, 12,  .gray979797)
                                                   
                                                Spacer()
                                            }
                                        }
                                        .frame(width: (UIScreen.main.bounds.width - 80 ) / 4 ,height: (UIScreen.main.bounds.width - 80 ) / 4)
                                    }
//                                    .actionSheet(isPresented: $isShowingImagesSheet) {
//                                        ActionSheet(title: Text("Choose the file type you want to upload".localized()), buttons: [
//                                            .default(Text("Image".localized())) {
//                                                sourceType = .photoLibrary
//                                                isShowingImagesPicker = true
//                                            },
//                                            .default(Text("Camera".localized())) {
//                                                sourceType = .camera
//                                                isShowingImagesPicker = true
//                                            },
//                                            .cancel()
//                                        ])
//                                    }
                                    .sheet(isPresented: $isShowingImagesSheet) {
                                        ImagePickerMultiSelection(sourceType: sourceType, isMultiSelection: true, selectedImages: $selectedProductImage, selectionNumber: (4 - (( selectedProductImage.count))))
                                    }
                                }
                                
                                
                                ForEach( 0 ..< selectedProductImage.count, id: \.self) { index in
                                    
                                    ZStack {
                                        Image(uiImage: selectedProductImage[index])
                                            .resizable()
                                            .frame(width: (UIScreen.main.bounds.width - 80 ) / 4 ,height: (UIScreen.main.bounds.width - 80 ) / 4)
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(15)
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Button {
                                                    selectedProductImage.remove(at: (index))
                                                } label: {
                                                    Image(systemName: "multiply.circle")
                                                        .resizable()
                                                        .foregroundColor(.black)
                                                        .frame(width: 17, height: 17)
                                                        .scaledToFit()
                                                        .shadow(radius: 10)
                                                }
                                                .padding(.top,-7)
                                                .padding(.trailing,-7)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(width: (UIScreen.main.bounds.width - 80 ) / 4 ,height: (UIScreen.main.bounds.width - 80 ) / 4)
                                }
                            }
                            .padding([.leading,.trailing],10)
                          
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    CustomMainTextField(text: $weight, placeHolder: "Weight", keyBoardType: .numberPad, fieldType: .weight, showHeader: true)
                                        .focused($focusedField, equals: .weight)
                                        .id(FormField.weight)
                                    CustomMainTextField(text: $length, placeHolder: "Length", keyBoardType: .numberPad, fieldType: .dimensional,showHeader: true)
                                        .focused($focusedField, equals: .length)
                                        .id(FormField.length)
                                }

                                HStack(spacing: 12) {
                                    CustomMainTextField(text: $width, placeHolder: "Width", keyBoardType: .numberPad, fieldType: .dimensional, showHeader: true)
                                        .focused($focusedField, equals: .width)
                                        .id(FormField.width)
                                    CustomMainTextField(text: $height, placeHolder: "Height", keyBoardType: .numberPad, fieldType: .dimensional, showHeader: true)
                                        .focused($focusedField, equals: .height)
                                        .id(FormField.height)
                                }
                            }

                            ShippingCompanyDropdownMulti(
                                titleKey: "shipping_companies_required".localized(),
                                selected: $selectedShippingCompanies,
                                isOpen: $isShippingDropDownOpen
                            )
                            
                            CustomMainTextField(text: $daysNumber, placeHolder: "number_days".localized(), keyBoardType: .numberPad, fieldType: .daysNumber, showHeader: true)
                                .focused($focusedField, equals: .daysNumber)
                                .id(FormField.daysNumber)
                        }
                        .padding(.bottom, focusedField == .daysNumber ? 300 : 0)
                        .animation(.easeOut(duration: 0.25), value: focusedField)
                        .onTapGesture(perform: {
                            hideKeyboard()
                            isShippingDropDownOpen = false
                        })
                        .navigationDestination(isPresented: $navigateToAddProduct) {
                            AddProductView(productsAdding:$productsAdding)
                        }
                    }
                    .padding(24)

                    ReusableButton(buttonText: "saveBtn", action: {
                        viewModel.validateCreateOfferLinkV3(name: name, descriptionAttributed: descriptionAttributed, price: price, images: selectedProductImage, weight: weight, length: length, width: width, height: height, shippingCompanies: selectedShippingCompanies, plannedShippingDateAndTime: daysNumber)
                    })
                    .padding(24)
                }
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
        .onReceive(viewModel.$_isCreateOrderSuccess){value in
            if value {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func showNextTextField(){
        switch focusedField {
        case .name:
            focusedField = .price
        case .price:
            focusedField = showOfferPriceTextField ? .offerPrice : .weight
        case .offerPrice:
            focusedField = .weight
        case .weight:
            focusedField = .length
        case .length:
            focusedField = .width
        case .width:
            focusedField = .height
        case .height:
            focusedField = .daysNumber
        case .daysNumber:
            focusedField = nil
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .daysNumber:
            focusedField = .height
        case .height:
            focusedField = .width
        case .width:
            focusedField = .length
        case .length:
            focusedField = .weight
        case .weight:
            focusedField = showOfferPriceTextField ? .offerPrice : .price
        case .offerPrice:
            focusedField = .price
        case .price:
            focusedField = .name
        case .name:
            focusedField = nil
        default:
            focusedField = nil
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    enum FormField {
        case name, description, quantity, price, offerPrice, weight, length, width, height, daysNumber
    }
}

#Preview {
    AddOfferViewNew()
}
