//
//  AddEditAddressView.swift
//  Dafeaa
//
//  Created by AMNY on 30/10/2024.
//
import SwiftUI
import GoogleMaps
import CoreLocation
import GooglePlaces

struct AddEditAddressView: View {

    @StateObject var viewModel = MoreVM()
    @Environment(\.presentationMode) private var presentationMode

    @State private var governorate: String = ""
    @State private var countyCode: String = ""
    @State private var city: String = ""
    @State private var postalCode: String = ""
    @State private var address: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0

    @State var isEdit: Bool = false
    @State var editedAddress: AddressesData?

    @State private var searchText: String = ""
    @State private var suggestions: [GMSAutocompleteSuggestion] = []
    private let placesClient = GMSPlacesClient.shared()
    private let allowedCountryCode = "SA"
    @State private var placesToken = GMSAutocompleteSessionToken()

    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: GMSCameraPosition = .camera(withLatitude: 24.7136, longitude: 46.6753, zoom: 12)
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var currentZoom: Float = 12

    @State private var lastSaudiCoordinate: CLLocationCoordinate2D?
    @State private var lastSaudiCamera: GMSCameraPosition = .camera(withLatitude: 24.7136, longitude: 46.6753, zoom: 12)
    
    @FocusState private var focusedField: FormField?

    var body: some View {
        ZStack {
            mainContent

            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear { onAppearSetup() }
        .onReceive(viewModel.$_isCreateSuccess) { success in
            if success { presentationMode.wrappedValue.dismiss() }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            NavigationBarView(
                title: isEdit ? "editAddress".localized() : "addNewAddress".localized()
            ) {
                presentationMode.wrappedValue.dismiss()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    searchSection
                    mapSection
                    formSection
                }
                .padding(.bottom, 100)
            }

            Spacer()

            ReusableButton(
                buttonText: editedAddress != nil ? "Save".localized() : "Add".localized()
            ) {
                saveAddress()
            }
            .padding(24)
        }
        .toolbar { keyboardToolbar }
    }


    private var searchSection: some View {
        ZStack(alignment: .top) {
            searchField

            if !suggestions.isEmpty {
                suggestionsList
                    .padding(.top, 60)
            }
        }
        .zIndex(1000)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)

            TextField("search_location".localized(), text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    fetchSuggestions(query: newValue)
                }

            if !searchText.isEmpty {
                Button { clearSearch() } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2)
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var suggestionsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(suggestions.prefix(5).enumerated()), id: \.offset) { index, suggestion in
                    Button {
                        selectSuggestion(suggestion)
                    } label: {
                        suggestionRow(suggestion)
                    }
                    .buttonStyle(.plain)

                    if index != min(4, suggestions.count - 1) {
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 250)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.15), radius: 4)
        .padding(.horizontal, 24)
    }

    private func suggestionRow(_ suggestion: GMSAutocompleteSuggestion) -> some View {
        let primary = suggestion.placeSuggestion?.attributedPrimaryText.string ?? ""
        let secondary = suggestion.placeSuggestion?.attributedSecondaryText?.string ?? ""

        return VStack(alignment: .leading, spacing: 4) {
            Text(primary)
                .font(.body)
                .foregroundColor(.black)

            if !secondary.isEmpty {
                Text(secondary)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }


    private var mapSection: some View {
        ZStack(alignment: .topTrailing) {
            GoogleMapView(
                selectedCoordinate: $selectedCoordinate,
                cameraPosition: $cameraPosition,
                onTap: handleMapTap
            )
            .frame(height: 200)
            .cornerRadius(12)

            VStack(spacing: 1) {
                mapButton(icon: "dot.scope") { centerOnUser() }
                Spacer()
                mapButton(icon: "plus") { zoomIn() }
                mapButton(icon: "minus") { zoomOut() }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private func mapButton(icon: String, color: Color = .gray, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(color)
                .frame(width: 35, height: 35)
                .background(Color.white.opacity(0.9))
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.2), radius: 1)
        }
    }


    private var formSection: some View {
        VStack(spacing: 12) {
            CustomMainTextField(text: $governorate, placeHolder: "governorate")
                .focused($focusedField, equals: .governorate)

            CustomMainTextField(text: $city, placeHolder: "CityField")
                .focused($focusedField, equals: .city)

            CustomMainTextField(text: $postalCode, placeHolder: "postal_code")
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .postalCode)

            CustomMainTextField(text: $address, placeHolder: "full_address")
                .focused($focusedField, equals: .address)
        }
        .padding(.horizontal, 24)
    }


    private func fetchSuggestions(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            suggestions = []
            placesToken = GMSAutocompleteSessionToken()
            return
        }

        let request = GMSAutocompleteRequest(query: q)
        request.sessionToken = placesToken
        let filter = GMSAutocompleteFilter()
           filter.countries = ["SA"]
           request.filter = filter
        placesClient.fetchAutocompleteSuggestions(from: request) { results, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.suggestions = []
                    return
                }
                self.suggestions = results ?? []
            }
        }
    }

    private func selectSuggestion(_ suggestion: GMSAutocompleteSuggestion) {
        guard let placeID = suggestion.placeSuggestion?.placeID else { return }

        let cachedPrimary = suggestion.placeSuggestion?.attributedPrimaryText.string ?? ""
        if !cachedPrimary.isEmpty { searchText = cachedPrimary }

        // Fetch ONLY coordinate from Place ID
        let props = [GMSPlaceProperty.coordinate.rawValue]
        let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: props, sessionToken: placesToken)

        placesClient.fetchPlace(with: request) { place, error in
            DispatchQueue.main.async {
                self.suggestions = []
                self.placesToken = GMSAutocompleteSessionToken()
                hideKeyboard()

                guard error == nil, let c = place?.coordinate else { return }

                self.handleMapTap(c)
            }
        }
    }

    private func apply(place: GMSPlace) {
        let c = place.coordinate

        var extractedCountry = ""

        if let comps = place.addressComponents {
            extractedCountry = comps.first(where: { $0.types.contains("country") })?.shortName ?? ""
        }

        guard validateSaudiOrToast(extractedCountry) else {
            return
        }

        if let name = place.name, !name.isEmpty {
            searchText = name
        } else if let formatted = place.formattedAddress {
            searchText = formatted
        }

        selectedCoordinate = c
        latitude = c.latitude
        longitude = c.longitude
        moveCamera(to: c, zoom: 16)

        if let comps = place.addressComponents {
            governorate = comps.first(where: { $0.types.contains("administrative_area_level_1") })?.name ?? ""
            city = comps.first(where: { $0.types.contains("locality") })?.name
                ?? comps.first(where: { $0.types.contains("administrative_area_level_2") })?.name
                ?? ""
            postalCode = comps.first(where: { $0.types.contains("postal_code") })?.name ?? ""
            countyCode = extractedCountry

            let route = comps.first(where: { $0.types.contains("route") })?.name ?? ""
            let streetNumber = comps.first(where: { $0.types.contains("street_number") })?.name ?? ""
            let sublocality = comps.first(where: { $0.types.contains("sublocality") })?.name ?? ""

            let parts = [streetNumber, route, sublocality].filter { !$0.isEmpty }
            address = parts.isEmpty ? (place.formattedAddress ?? "") : parts.joined(separator: ", ")
        } else {
            address = place.formattedAddress ?? ""
        }
    }

    private func focusFromSavedTextIfNeeded() {
        if latitude != 0, longitude != 0 {
            let c = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            selectedCoordinate = c
            moveCamera(to: c, zoom: 16)
            lastSaudiCoordinate = c
            lastSaudiCamera = cameraPosition
            return
        }

        let query = [address, city, governorate, countyCode]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        guard !query.isEmpty else { return }

        CLGeocoder().geocodeAddressString(query) { placemarks, error in
            guard error == nil, let pm = placemarks?.first,
                  let c = pm.location?.coordinate else { return }

            let iso = pm.isoCountryCode?.uppercased()

            DispatchQueue.main.async {
                guard iso == self.allowedCountryCode else {
                    self.showOutsideSaudiToast()
                    self.revertToLastSaudiPoint()
                    return
                }

                self.latitude = c.latitude
                self.longitude = c.longitude
                self.selectedCoordinate = c
                self.moveCamera(to: c, zoom: 16)

                self.fillFields(from: pm)

                self.lastSaudiCoordinate = c
                self.lastSaudiCamera = self.cameraPosition
            }
        }
    }

    private func clearSearch() {
        searchText = ""
        suggestions = []
        placesToken = GMSAutocompleteSessionToken()
    }

    private func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        validateCoordinateIsSaudi(coordinate) { isAllowed, placemark in
            guard isAllowed else {
                showOutsideSaudiToast()
                revertToLastSaudiPoint()
                return
            }

            DispatchQueue.main.async {
                self.selectedCoordinate = coordinate
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude

                self.fillFields(from: placemark)
                self.moveCamera(to: coordinate, zoom: 16)

                self.lastSaudiCoordinate = coordinate
                self.lastSaudiCamera = self.cameraPosition
            }
        }
    }

    private func validateCoordinateIsSaudi(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (_ isAllowed: Bool, _ placemark: CLPlacemark?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, _ in
            let pm = placemarks?.first
            let iso = pm?.isoCountryCode?.uppercased()
            completion(iso == self.allowedCountryCode, pm)
        }
    }

    private func fillFields(from placemark: CLPlacemark?) {
        guard let placemark else { return }
        governorate = placemark.administrativeArea ?? ""
        city = placemark.locality ?? ""
        postalCode = placemark.postalCode ?? ""
        countyCode = placemark.isoCountryCode ?? ""

        let parts = [placemark.subThoroughfare, placemark.thoroughfare, placemark.subLocality]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        address = parts.joined(separator: ", ")
    }

    
    private func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: Float) {
        currentZoom = zoom
        cameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        lastSaudiCamera = cameraPosition

    }

    private func zoomIn() {
        updateZoom(by: 1)
    }

    private func zoomOut() {
        updateZoom(by: -1)
    }

    private func updateZoom(by delta: Float) {
        let newZoom = max(2, min(20, currentZoom + delta))
        currentZoom = newZoom
        let target = selectedCoordinate ?? cameraPosition.target
        cameraPosition = GMSCameraPosition.camera(withTarget: target, zoom: newZoom)
        lastSaudiCamera = cameraPosition

    }

    private func centerOnUser() {
        guard let userLocation = locationManager.currentLocation else { return }
        cameraPosition = GMSCameraPosition.camera(withTarget: userLocation, zoom: currentZoom)
        lastSaudiCamera = cameraPosition
    }

    
    private func showOutsideSaudiToast() {
        viewModel.toast = FancyToast(type: .error, title: "error".localized(), message: "location_outside_saudi".localized())
    }

    private func revertToLastSaudiPoint() {
        if let last = lastSaudiCoordinate {
            selectedCoordinate = last
        }
        cameraPosition = lastSaudiCamera
    }

    

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, _ in
            guard let placemark = placemarks?.first else { return }

            DispatchQueue.main.async {
                let iso = placemark.isoCountryCode
                guard validateSaudiOrToast(iso) else {
                    selectedCoordinate = nil
                    latitude = 0
                    longitude = 0
                    return
                }

                governorate = placemark.administrativeArea ?? ""
                city = placemark.locality ?? ""
                postalCode = placemark.postalCode ?? ""
                countyCode = iso ?? ""

                let parts = [placemark.subThoroughfare, placemark.thoroughfare, placemark.subLocality]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }

                address = parts.joined(separator: ", ")
            }
        }
    }

    // MARK: - Save

    private func saveAddress() {
        viewModel.validateCreateAddress(
            countyCode: countyCode,
            governorate: governorate,
            city: city,
            postalCode: postalCode,
            address: address,
            lat: latitude,
            lng: longitude,
            addressId: editedAddress?.id
        )
    }
    private func validateSaudiOrToast(_ country: String?) -> Bool {
        if country?.uppercased() == allowedCountryCode { return true }

        viewModel.toast = FancyToast(type: .error, title: "error".localized(), message: "location_outside_saudi".localized())
    
        return false
    }

    // MARK: - Lifecycle

    private func onAppearSetup() {
        if let editData = editedAddress {
            loadEditData(editData)
        } else if let userLocation = locationManager.currentLocation {
            cameraPosition = .camera(withTarget: userLocation, zoom: 12)
            lastSaudiCamera = cameraPosition
            lastSaudiCoordinate = userLocation
        } else {
            lastSaudiCamera = cameraPosition
        }
    }


    private func loadEditData(_ data: AddressesData) {
        governorate = data.provinceCode ?? ""
        city = data.cityName ?? ""
        postalCode = data.postalCode ?? ""
        address = data.address ?? ""


        focusFromSavedTextIfNeeded()
    }

    // MARK: - Keyboard toolbar

    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Done".localized(), action: hideKeyboard)
            Spacer()
            Button { showPreviousField() } label: { Image(systemName: "chevron.up").foregroundColor(.blue) }
            Button { showNextField() } label: { Image(systemName: "chevron.down").foregroundColor(.blue) }
        }
    }

    private func showNextField() {
        switch focusedField {
        case .governorate: focusedField = .city
        case .city: focusedField = .postalCode
        case .postalCode: focusedField = .address
        default: focusedField = nil
        }
    }

    private func showPreviousField() {
        switch focusedField {
        case .address: focusedField = .postalCode
        case .postalCode: focusedField = .city
        case .city: focusedField = .governorate
        default: focusedField = nil
        }
    }

    private enum FormField {
        case governorate, city, postalCode, address
    }
}


#Preview {
    AddEditAddressView()
}
