//
//  SavedAddressesView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct SavedAddressesView: View {
    @StateObject var viewModel = MoreVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var selectedAddressId: Int
    @Binding var selectedAddress: String
    @State private var isNavigatingToAddEdit = false
    @State private var addressToEdit: AddressesData?
    @State var isComingFromSelection: Bool = false
    @State var address:String = ""
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                NavigationBarView(title: "Saved Addresses".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // MARK: - Content
                VStack(alignment: .center, spacing: 24) {
                    if viewModel.addressList.isEmpty {
                        EmptyCostumeView()
                                ReusableButton(buttonText: "saveSelectedAddress".localized(),buttonColor: .yellow) {
                                    Constants.selectedAddressId = selectedAddressId
                                    Constants.selectedAddress = selectedAddress
                                    presentationMode.wrappedValue.dismiss()
                                }
                            
                            ReusableButton(buttonText: "AddAddress".localized()) {
                                addressToEdit = nil
                                isNavigatingToAddEdit = true
                                
                            }
                        

                    } else {
                        addressListView
                        
                    }
                }
                .padding(24)
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
        .onAppear {
            viewModel.addressesList()
        }
    
        .navigationDestination(isPresented: $isNavigatingToAddEdit) {
            if let address = addressToEdit {
                AddEditAddressView(isEdit: true, editedAddress: address)
            } else {
                AddEditAddressView()
            }
        }
        
    }
    
 
    
    // MARK: - Address List View
    private var addressListView: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.addressList.indices, id: \.self) { index in
                        let addressItem = viewModel.addressList[index]
                        addressRow(for: addressItem)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.bottom,120)
            VStack {
                
                Spacer()
                    ReusableButton(buttonText: "saveSelectedAddress".localized(),buttonColor: .yellow) {
                        Constants.selectedAddressId = selectedAddressId
                        Constants.selectedAddress = selectedAddress
                        presentationMode.wrappedValue.dismiss()
                    }
                
                ReusableButton(buttonText: "AddAddress".localized()) {
                    addressToEdit = nil
                    isNavigatingToAddEdit = true
                    
                }
            }
        }
    }
    
    // MARK: - Address Row
    private func addressRow(for address: AddressesData) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 8)
                .stroke(selectedAddressId == address.id ? Color(.primary):Color(.black).opacity(0.1), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill( selectedAddressId == address.id ? Color(.primary).opacity(0.1) : Color.white)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    withAnimation {
                        selectedAddressId = address.id ?? 0
                        selectedAddress   = "address".localized() + ": \(address.countryName ?? "")," + " \(address.cityName ?? "")" + ", " + " \(address.address ?? "")" + ", " + " \(address.districtName ?? "")"
                        
                    }
                }) {
                    HStack(alignment: .top) {
                        
                        Image(systemName: selectedAddressId == address.id ? "circle.inset.filled" : "circle")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(selectedAddressId == address.id ? Color(.primary) : Color.gray8B8C86)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(Constants.userName )
                                    .textModifier(.plain, 14, .black1E1E1E)
                                // Edit Button
                                Button(action: {
                                    addressToEdit = address
                                    isNavigatingToAddEdit = true
                                }) {
                                        Image(.editIcon)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.trailing, 8)
                                
                                // Delete Button
                                Button(action: {
                                    deleteAddress(address)
                                }) {
                                    Image(.trash)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                }
                            }
                            Text("phoneNumber".localized() + " : " + Constants.phone )
                                .textModifier(.plain, 12, .gray979797)
                            
                            let country = address.countryName != "" ? ("area".localized() + ": \(address.countryName ?? "")") : ""
                            let city = address.cityName != "" ? ( ", " + "CityField".localized() + ": \(address.cityName ?? "")") : ""
                            let naiborhood = address.districtName != "" ? (", " + "neighborhoodName".localized() + ": \(address.districtName ?? "")") : ""
                            let streetName = address.districtName != "" ? ( ", " + "streetName".localized() + ": \(address.streetName ?? "")") : ""
                            let addressShort = address.address != "" ? ( "," + "shortAddress".localized() + ": \(address.address ?? "")") : ""
                            let fullAddress = "\(country)" + "\(city)" + "\(naiborhood)" + "\(streetName)" + "\(addressShort)"
                            Text(fullAddress)
                                .textModifier(.plain, 12, .gray979797)
                                .multilineTextAlignment(.leading)
                        }
//                        Spacer()
                        
                        
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            
        }
    }
    
    // MARK: - Delete Address Function
    private func deleteAddress(_ address: AddressesData) {
        viewModel.address(id: address.id ?? 0, method: .delete, dic: [:])
    }
}
