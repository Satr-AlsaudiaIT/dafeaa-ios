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
    @State private var price: String = ""
    @State private var tax: String? = ""
    @FocusState private var focusedField: FormField?
    
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
                                        CustomMainTextField(text: $description, placeHolder: "delivery", keyBoardType: .numberPad)
                                            .focused($focusedField, equals: .delivery)
                                            .id(FormField.delivery)
                                        CustomMainTextField(text: $description, placeHolder: "tax",  keyBoardType: .numberPad)
                                            .focused($focusedField, equals: .tax)
                                            .id(FormField.tax)
                                    }
                                }
                            }
                        }                    .padding(24)

                        ReusableButton(buttonText: "saveBtn", action: {})
                    
                    .padding(24)

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
        
    }
   
    enum FormField {
        case name, description, delivery ,tax
    }
}

#Preview {
    AddOfferView()
}

