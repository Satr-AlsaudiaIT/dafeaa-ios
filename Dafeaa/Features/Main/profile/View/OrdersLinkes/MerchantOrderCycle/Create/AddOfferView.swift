//
//  AddOfferView.swift
//  Dafeaa
//
//  Created by AMNY on 09/11/2024.
//

import SwiftUI

struct AddOfferView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = OrdersVM()
    @State var goToAddOffer = false
    @State private var name : String =  ""
    @State private var description:String = ""
    @State private var deliveryPrice: String = ""
    @State private var tax: String = ""
    @FocusState private var focusedField: FormField?
    @State var navigateToAddProduct: Bool = false
    @State var productsAdding: [[String: Any]] = []

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
                                    CustomMainTextField(text: $name, placeHolder: "Name")
                                        .focused($focusedField, equals: .name)
                                        .id(FormField.name)
                                    CustomMainTextField(text: $description, placeHolder: "description")
                                        .focused($focusedField, equals: .description)
                                        .id(FormField.description)
                                    HStack{
                                        CustomMainTextField(text: $deliveryPrice, placeHolder: "deliveryPriceTitle", keyBoardType: .numberPad,fieldType: .price)
                                            .focused($focusedField, equals: .delivery)
                                            .id(FormField.delivery)
                                        CustomMainTextField(text: $tax, placeHolder: "taxPriceTitle",  keyBoardType: .numberPad,fieldType: .percentage)
                                            .focused($focusedField, equals: .tax)
                                            .id(FormField.tax)
                                    }
                                }
                                ForEach (0..<productsAdding.count, id: \.self) { index in
                                    BusinessCreateLinkCellView(product: productsAdding[index])
                                    
                                }
                                
                                Button(action: {
                                    navigateToAddProduct = true 
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("+ " + "addProductTitle".localized())
                                            .textModifier(.plain, 18, .grayAAAAAA)
                                        Spacer()
                                    }
                                    .padding(.all,20)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.grayAAAAAA),style: StrokeStyle(lineWidth: 1, dash:  [12]))
                                )
                                .padding(.top,10)
                                
                            }
                            .navigationDestination(isPresented: $navigateToAddProduct) {
                                AddProductView(productsAdding:$productsAdding)
                            }
                        }                    .padding(24)

                        ReusableButton(buttonText: "saveBtn", action: {
                            viewModel.validateAddOffer(offerName: name, offerDescription: description, deliveryPrice: deliveryPrice, tax: tax, productsAdding:productsAdding )
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
        }.edgesIgnoringSafeArea(.bottom)
            .toastView(toast: $viewModel.toast)
            .navigationBarHidden(true)
            .onAppear(){
                AppState.shared.swipeEnabled = true
            }
            .onReceive(viewModel.$_isCreateOrderSuccess){value in
                if value {
                    self.presentationMode.wrappedValue.dismiss()
            }}
    }
    func showNextTextField(){
        switch focusedField {
        case .name:
            focusedField = .description
        case .description:
            focusedField = .delivery
        case .delivery:
            focusedField = .tax
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .tax:
            focusedField = .delivery
        case .delivery:
            focusedField = .description
        case .description:
            focusedField = .name
        default:
            focusedField = nil
        }
    }
    enum FormField {
        case name, description, delivery ,tax
    }
}

#Preview {
    AddOfferView()
}

