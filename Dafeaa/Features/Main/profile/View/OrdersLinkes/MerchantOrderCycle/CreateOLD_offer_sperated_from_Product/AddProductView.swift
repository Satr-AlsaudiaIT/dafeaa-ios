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
    @State var name: String = ""
    @State var description: String = ""
    @State var quantity: String = ""
    
    @State private var selectedProductImage :[UIImage] = []
    @State private var isShowingImagesSheet = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isShowingImagesPicker = false
    
    @State var price: String = ""
    @State var offerPrice: String = ""
    @Binding var productsAdding: [[String:Any]]
    @FocusState private var focusedField: FormField?
    @State private var showOfferPriceTextField: Bool = false
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: "addProductTitle"){
                        self.presentationMode.wrappedValue.dismiss()
                    }

                    ScrollView {
                        VStack(spacing: 20) {
                            CustomMainTextField(text: $name, placeHolder: "productName", fieldType: .none)
                                .focused($focusedField, equals: .name)
                                .id(FormField.name)
                  
                            CustomMainTextField(text: $description, placeHolder: "productDescription", fieldType:.none)
                                .focused($focusedField, equals: .description)
                                .id(FormField.description)
                     
                            CustomMainTextField(text: $quantity, placeHolder: "quantity", keyBoardType:.numberPad,fieldType: .none)
                                .focused($focusedField, equals: .quantity)
                                .id(FormField.quantity)
                                CustomMainTextField(text: $price, placeHolder: "productPrice",keyBoardType: .numberPad,fieldType: .price)
                                    .focused($focusedField, equals: .price)
                                    .id(FormField.price)
                            if showOfferPriceTextField {
                                CustomMainTextField(text: $offerPrice,
                                                   placeHolder: "offerPrice",
                                                   keyBoardType: .numberPad,
                                                   fieldType: .price)
                                    .focused($focusedField, equals: .offerPrice)
                                    .id(FormField.offerPrice)
                                    .transition(.move(edge: .trailing).combined(with: .opacity)) // Slide in from right
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
                                    .actionSheet(isPresented: $isShowingImagesSheet) {
                                        ActionSheet(title: Text("Choose the file type you want to upload".localized()), buttons: [
                                            .default(Text("Image".localized())) {
                                                sourceType = .photoLibrary
                                                isShowingImagesPicker = true
                                            },
                                            .default(Text("Camera".localized())) {
                                                sourceType = .camera
                                                isShowingImagesPicker = true
                                            },
                                            .cancel()
                                        ])
                                    }
                                    .sheet(isPresented: $isShowingImagesPicker) {
                                        ImagePickerMultiSelection(sourceType: .photoLibrary, isMultiSelection: true, selectedImages: $selectedProductImage, selectionNumber: (4 - (( selectedProductImage.count))))
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
                                                    //Delete image from array
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
                            .padding(.bottom,50)
                            Spacer()
                            ReusableButton(buttonText: "addProductTitle") {
                                if let product = viewModel.validateAddOrderOLD(images: selectedProductImage, name: name, description: description,quantity: quantity, price: price, offerPrice: offerPrice,haveOffer: showOfferPriceTextField) {
                                    productsAdding.append(product)  // Update the binding array
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .padding(.horizontal,20)
                        .padding(.top,10)
                        
                    }
                    
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
        case .name:
            focusedField = .description
        case .description:
            focusedField = .quantity
        case .quantity:
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
            focusedField = .quantity
        case .quantity:
            focusedField = .description
        case .description:
            focusedField = .name
        default:
            focusedField = nil
        }
    }
    
    enum FormField {
        case name,  description, quantity, price, offerPrice
    }
}

#Preview {
    AddProductView(productsAdding: .constant([[:]]))
}
