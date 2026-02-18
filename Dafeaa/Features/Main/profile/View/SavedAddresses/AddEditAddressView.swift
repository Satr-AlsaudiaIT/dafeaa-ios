//
//  AddEditAddressView.swift
//  Dafeaa
//
//  Created by AMNY on 30/10/2024.
//
import SwiftUI
import GoogleMaps
import CoreLocation

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
    @State private var suggestions: [PlaceSuggestion] = []
    @StateObject private var placesAPI = GooglePlacesAPIService()
    private let allowedCountryCode = "SA"

    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: GMSCameraPosition = .camera(withLatitude: 24.7136, longitude: 46.6753, zoom: 12)
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var currentZoom: Float = 12

    @State private var lastSaudiCoordinate: CLLocationCoordinate2D?
    @State private var lastSaudiCamera: GMSCameraPosition = .camera(withLatitude: 24.7136, longitude: 46.6753, zoom: 12)
    
    @FocusState private var focusedField: FormField?
    
    private let englishLocale = Locale(identifier: "en_US")
    @State private var isSelectingSuggestion = false

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
                .onChange(of: searchText) { oldValue, newValue in
                    // Only trigger search if user is typing (not selecting)
                    if !isSelectingSuggestion {
                        fetchSuggestions(query: newValue)
                    }
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
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func suggestionRow(_ suggestion: PlaceSuggestion) -> some View {
        let primary = suggestion.mainText
        let secondary = suggestion.secondaryText ?? ""

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
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .postalCode)

            CustomMainTextField(text: $address, placeHolder: "full_address")
                .focused($focusedField, equals: .address)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Fetch Suggestions (REST API)
    private func fetchSuggestions(query: String) {
        // Don't fetch if we're in the middle of selecting a suggestion
        guard !isSelectingSuggestion else { return }
        
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            suggestions = []
            return
        }

        placesAPI.fetchAutocompleteSuggestions(query: q) { apiSuggestions in
            DispatchQueue.main.async {
                self.suggestions = apiSuggestions
                
            }
        }
    }


    // MARK: - Select Suggestion (REST API)
    // MARK: - Select Suggestion (REST API)
    private func selectSuggestion(_ suggestion: PlaceSuggestion) {
        // Set flag to prevent fetchSuggestions from triggering
        isSelectingSuggestion = true
        
        // Clear suggestions immediately
        suggestions = []
        
        // Update search text WITHOUT triggering onChange
        let tempText = suggestion.mainText
        
        hideKeyboard()

        placesAPI.fetchPlaceDetails(placeID: suggestion.placeID) { details in
            guard let details = details else {
                DispatchQueue.main.async {
                    self.searchText = tempText
                    self.isSelectingSuggestion = false
                }
                return
            }
            
            // Extract country code
            let country = details.addressComponents.first { $0.types.contains("country") }?.shortName ?? ""
            
            // Validate Saudi Arabia
            guard self.validateSaudiOrToast(country) else {
                DispatchQueue.main.async {
                    self.searchText = tempText
                    self.isSelectingSuggestion = false
                }
                return
            }
            
            let coordinate = CLLocationCoordinate2D(
                latitude: details.geometry.location.lat,
                longitude: details.geometry.location.lng
            )
            
            // Extract address components in English
            let city = details.addressComponents.first { $0.types.contains("locality") }?.longName ?? ""
            let governorate = details.addressComponents.first { $0.types.contains("administrative_area_level_1") }?.longName ?? ""
            let postalCode = details.addressComponents.first { $0.types.contains("postal_code") }?.longName ?? ""
            let route = details.addressComponents.first { $0.types.contains("route") }?.longName ?? ""
            let streetNumber = details.addressComponents.first { $0.types.contains("street_number") }?.longName ?? ""
            let sublocality = details.addressComponents.first { $0.types.contains("sublocality") }?.longName ?? ""
            
            DispatchQueue.main.async {
                self.city = city
                self.governorate = governorate
                self.postalCode = postalCode
                self.countyCode = country
                
                let parts = [streetNumber, route, sublocality].filter { !$0.isEmpty }
                self.address = parts.isEmpty ? details.formattedAddress : parts.joined(separator: ", ")
                
                // Update search text LAST and keep flag active
                self.searchText = details.name ?? details.formattedAddress
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                self.selectedCoordinate = coordinate
                self.moveCamera(to: coordinate, zoom: 16)
                
                self.lastSaudiCoordinate = coordinate
                self.lastSaudiCamera = self.cameraPosition
                
                // Reset flag AFTER a delay to ensure onChange doesn't trigger
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isSelectingSuggestion = false
                }
            }
        }
    }

    private func clearSearch() {
        isSelectingSuggestion = false
        searchText = ""
        suggestions = []
    }


    // MARK: - Handle Map Tap
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
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        if #available(iOS 15.0, *) {
            geocoder.reverseGeocodeLocation(location, preferredLocale: englishLocale) { placemarks, _ in
                let pm = placemarks?.first
                let iso = pm?.isoCountryCode?.uppercased()
                completion(iso == self.allowedCountryCode, pm)
            }
        } else {
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                let pm = placemarks?.first
                let iso = pm?.isoCountryCode?.uppercased()
                completion(iso == self.allowedCountryCode, pm)
            }
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

    // MARK: - Camera Movement
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

    // MARK: - Validation & Toasts
    private func showOutsideSaudiToast() {
        viewModel.toast = FancyToast(type: .error, title: "error".localized(), message: "location_outside_saudi".localized())
    }

    private func revertToLastSaudiPoint() {
        if let last = lastSaudiCoordinate {
            selectedCoordinate = last
        }
        cameraPosition = lastSaudiCamera
    }

    private func validateSaudiOrToast(_ country: String?) -> Bool {
        if country?.uppercased() == allowedCountryCode { return true }

        viewModel.toast = FancyToast(type: .error, title: "error".localized(), message: "location_outside_saudi".localized())
        return false
    }

    // MARK: - Geocoding Fallback
    private func tryGeocodeWithFallback(queries: [String], index: Int, retryCount: Int = 0) {
        guard index < queries.count else {
            print("All geocoding attempts failed")
            return
        }
        
        let query = queries[index]
        let maxRetries = 2
        
        let geocoder = CLGeocoder()
        
        if #available(iOS 15.0, *) {
            // FIXED: Correct syntax with preferredLocale
            geocoder.geocodeAddressString(query, in: nil, preferredLocale: self.englishLocale) { placemarks, error in
                self.handleGeocodeResult(placemarks: placemarks, error: error, queries: queries, index: index, retryCount: retryCount, maxRetries: maxRetries)
            }
        } else {
            geocoder.geocodeAddressString(query) { placemarks, error in
                self.handleGeocodeResult(placemarks: placemarks, error: error, queries: queries, index: index, retryCount: retryCount, maxRetries: maxRetries)
            }
        }
    }

    private func handleGeocodeResult(placemarks: [CLPlacemark]?, error: Error?, queries: [String], index: Int, retryCount: Int, maxRetries: Int) {
        let query = queries[index]
        
        if let error = error {
            print("Geocoding failed for '\(query)' (attempt \(retryCount + 1)): \(error.localizedDescription)")
            
            if retryCount < maxRetries {
                DispatchQueue.main.async {
                    self.tryGeocodeWithFallback(queries: queries, index: index, retryCount: retryCount + 1)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.tryGeocodeWithFallback(queries: queries, index: index + 1, retryCount: 0)
            }
            return
        }
        
        guard let pm = placemarks?.first,
              let c = pm.location?.coordinate else {
            print("No placemarks found for '\(query)'")
            
            if retryCount < maxRetries {
                DispatchQueue.main.async {
                    self.tryGeocodeWithFallback(queries: queries, index: index, retryCount: retryCount + 1)
                }
            } else {
                DispatchQueue.main.async {
                    self.tryGeocodeWithFallback(queries: queries, index: index + 1, retryCount: 0)
                }
            }
            return
        }

        let iso = pm.isoCountryCode?.uppercased()

        DispatchQueue.main.async {
            guard iso == self.allowedCountryCode else {
                print("Location outside Saudi Arabia for '\(query)'")
                self.tryGeocodeWithFallback(queries: queries, index: index + 1, retryCount: 0)
                return
            }

            self.latitude = c.latitude
            self.longitude = c.longitude
            self.selectedCoordinate = c
            
            let zoom: Float = index == 0 ? 16 : (index == 1 ? 13 : (index == 2 ? 12 : 11))
            self.moveCamera(to: c, zoom: zoom)

            self.fillFields(from: pm)

            self.lastSaudiCoordinate = c
            self.lastSaudiCamera = self.cameraPosition
            
            print("✅ Successfully geocoded '\(query)' to \(c.latitude), \(c.longitude)")
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
        
        let queries = [
            [address, city, postalCode, governorate, countyCode]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", "),
            
            [city, postalCode, governorate, countyCode]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", "),
            
            [city, governorate, countyCode]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        ]
        
        tryGeocodeWithFallback(queries: queries.filter { !$0.isEmpty }, index: 0)
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






