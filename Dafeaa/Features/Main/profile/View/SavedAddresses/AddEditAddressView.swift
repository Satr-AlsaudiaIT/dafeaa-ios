//
//  AddEditAddressView.swift
//  Dafeaa
//
//  Created by AMNY on 30/10/2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddEditAddressView: View {
    @StateObject var viewModel = MoreVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isEdit: Bool = false
    @State var selectedAreaName: String = ""
    @State var selectedAreaId: Int = 0
    @State var selectedCityName: String = ""
    @State var selectedCityId: Int = 0
    
    @State var streetName: String = ""
    @State var neighborhoodName: String = ""

    @State var buildingNum: String = ""
    @State var floatNum: String = ""
    @State var address: String = ""
    @State var pickedAddress: String = ""

    @State var editedAddress: AddressesData?
    @State var latitude: Double = 0
    @State var longitude: Double = 0
    @State var isMapViewPresented: Bool = false
    @State var selectedLocation: CLLocationCoordinate2D?
    @State private var userLocation: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManager()
    @FocusState private var focusedField: FormField?
    @State private var keyboardHeight: CGFloat = 0
    @State private var isAreaDropDownOpen: Bool? = false
    @State private var isCityDropDownOpen: Bool? = false
    
    
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
                    
                    DropdownSearchTF(placeHolder:"area".localized(),
                                     isOpen: $isAreaDropDownOpen,
                                     text: $selectedAreaName, title: "area".localized(),
                                     options: $viewModel.areaNames,
                                     submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                    .focused($focusedField, equals: .area)
                    .onChange(of: selectedAreaName) { _, newValue in
                            selectedAreaId = viewModel.getAreaId(areaName: selectedAreaName)
                            viewModel.getCities(countryId: selectedAreaId)
                       
                    }
                    DropdownSearchTF(placeHolder:"CityField".localized(),
                                     isOpen: $isCityDropDownOpen,
                                     text: $selectedCityName, title: "CityField".localized(),
                                     options: $viewModel.cityNames,
                                     submitLabel: .done,titleSize: 17,image: UIImage(resource: .location))
                    .focused($focusedField, equals: .city)
                    .onChange(of: selectedCityName) { _, newValue in
                         let selectedId = viewModel.getCityId(cityName: selectedCityName)
                            selectedCityId = selectedId
                        
                    }
                    CustomMainTextField(text: $neighborhoodName, placeHolder: "neighborhoodName")
                        .focused($focusedField, equals: .neighborhoodName)
                        .id(FormField.neighborhoodName)
                    CustomMainTextField(text: $streetName, placeHolder: "streetName",fieldType:.optional)
                        .focused($focusedField, equals: .streetName)
                        .id(FormField.streetName)
                    CustomMainTextField(text: $address, placeHolder: "shortAddress",fieldType:.optional)
                        .focused($focusedField, equals: .address)
                        .id(FormField.address)
                    HStack {
                        Button(action: {
                            isMapViewPresented = true
                        }) {
                            Image(.location)
                                
                            Text( pickedAddress == "" ? "pick_location".localized() : pickedAddress)
                                .textModifier(.plain, 14, .black222222)
                                .underline()
                        }
                        Spacer()
                    }
                    
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
                viewModel.validateCreateAddress(id: editedAddress?.id, areaId: selectedAreaId, cityId: selectedCityId, streetName: streetName, neighborhoodName: neighborhoodName, address: address,lat: latitude, lng:  longitude)
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
            viewModel.getAreas()
            
        }
        .onChange(of: viewModel.cityNames, { _, _ in
            selectedCityId = editedAddress?.cityId ?? 0
            selectedCityName = viewModel.cities.first(where: { $0.id == selectedCityId })?.name ?? ""
        })
        .onChange(of: viewModel.areaNames, { _, _ in
            setData()
        })
        .sheet(isPresented: $isMapViewPresented) {
            MapView(
                        address: $pickedAddress,
                        latitude: $latitude,
                        longitude: $longitude
                    )
        }

    }
        
    // MARK: - Function to Set Data
    private func setData() {
        if let editedAddress = editedAddress {
            selectedAreaId = editedAddress.countryId ?? 0
            selectedAreaName = viewModel.areas.first(where: { $0.id == selectedAreaId })?.name ?? ""
            viewModel.getCities(countryId: selectedAreaId)
            streetName = editedAddress.streetName ?? ""
            neighborhoodName = editedAddress.districtName ?? ""
            address = editedAddress.address ?? ""
            latitude = Double(editedAddress.lat ?? "0" ) ?? 0
            longitude = Double(editedAddress.lng ?? "0") ?? 0

            // Reverse geocode the coordinates to get the address
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Failed to reverse geocode location: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let addressString = [
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    DispatchQueue.main.async {
                        self.pickedAddress = addressString
                    }
                }
            }
        }
    }

    func showNextTextField(){
        switch focusedField {
        case .area:
            focusedField = .city
        case .city:
            focusedField = .neighborhoodName
        case .neighborhoodName:
            focusedField = .streetName
        case .streetName:
            focusedField = .address
        default:
            focusedField = nil
        }
    }
    
    func showPerviousTextField(){
        switch focusedField {
        case .address:
            focusedField = .streetName
        case .streetName:
            focusedField = .neighborhoodName
        case .neighborhoodName:
            focusedField = .city
        case .city:
            focusedField = .area
        default:
            focusedField = nil
        }
    }
    enum FormField {
        case area,city ,neighborhoodName, streetName, address
    }
}
// MARK: - Location Manager
import Foundation
import CoreLocation
import Combine


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = true

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestAuthorization()
    }

    func requestAuthorization() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        handleAuthorizationStatus(authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.isLoading = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
        default:
            break
        }
    }
}




#Preview {
    AddEditAddressView()
}
