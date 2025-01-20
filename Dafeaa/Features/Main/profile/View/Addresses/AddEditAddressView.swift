//
//  AddEditAddressView.swift
//  Dafeaa
//
//  Created by AMNY on 30/10/2024.
//

import SwiftUI

struct AddEditAddressView: View {
    @StateObject var viewModel = MoreVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isEdit: Bool = false
    @State var area: String = ""
    @State var streetName: String = ""
    @State var buildingNum: String = ""
    @State var floatNum: String = ""
    @State var address: String = ""
    @State var editedAddress: AddressesData?
    @FocusState private var focusedField: FormField?
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {

        VStack {
            // MARK: - Navigation Bar
            NavigationBarView(title: isEdit ? "editAddress".localized():"addNewAddress".localized() ) {
                presentationMode.wrappedValue.dismiss()
            }
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false){
                VStack(spacing: 12) {
                    CustomMainTextField(text: $area, placeHolder: "area")
                        .focused($focusedField, equals: .area)
                        .id(FormField.area)
                    CustomMainTextField(text: $streetName, placeHolder: "streetName")
                        .focused($focusedField, equals: .streetName)
                        .id(FormField.streetName)
                    CustomMainTextField(text: $buildingNum, placeHolder: "buildingNum", keyBoardType: .numberPad)
                        .focused($focusedField, equals: .buildingNum)
                        .id(FormField.buildingNum)
                    CustomMainTextField(text: $floatNum, placeHolder: "FloatNum", keyBoardType: .numberPad)
                        .focused($focusedField, equals: .floatNum)
                        .id(FormField.floatNum)
                    CustomMainTextField(text: $address, placeHolder: "address")
                        .focused($focusedField, equals: .address)
                        .id(FormField.address)
                    
                   
                }
                .padding([.leading,.trailing,.top],24)
              
            }
                .onChange(of: focusedField) { oldField,newField in
                    withAnimation {
                        if let newField = newField {
                            proxy.scrollTo(newField, anchor: .center)
                        }
                    }
                }
            }
            .padding(.bottom, keyboardHeight)
            .onReceive(viewModel.$_isCreateSuccess) { newValue in
               if newValue { presentationMode.wrappedValue.dismiss()}
            }
            Spacer()
            ReusableButton(buttonText: editedAddress != nil ? "Save".localized() : "Add".localized()) {
                viewModel.validateCreateAddress(id: editedAddress?.id, area: area, streetName: streetName, buildingNum: buildingNum, floatNum: floatNum, address: address)
                               
            }
            .padding([.leading,.trailing,.top],24)
        }
        .onAppear { subscribeToKeyboardEvents(keyboardHeight: keyboardHeight) }
        .onDisappear { unsubscribeFromKeyboardEvents() }
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

            // MARK: - Loading Indicator
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
        .onAppear(){
            setData()
        }
    }
    
    // MARK: - Function to Set Data
    private func setData() {
        if let address = editedAddress {
            area = address.area ?? ""
            streetName = address.streetName ?? ""
            buildingNum = address.buildingNum ?? ""
            floatNum = address.floatNum ?? ""
            self.address = address.address ?? ""
        }
    }

    func showNextTextField(){
        switch focusedField {
        case .area:
            focusedField = .streetName
        case .streetName:
            focusedField = .buildingNum
        case .buildingNum:
            focusedField = .floatNum
        case .floatNum:
            focusedField = .address
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .address:
            focusedField = .floatNum
        case .floatNum:
            focusedField = .buildingNum
        case .buildingNum:
            focusedField = .streetName
        case .streetName:
            focusedField = .area
        default:
            focusedField = nil
        }
    }
    enum FormField {
        case area, streetName, buildingNum, floatNum, address
    }
}

#Preview {
    AddEditAddressView()
}
