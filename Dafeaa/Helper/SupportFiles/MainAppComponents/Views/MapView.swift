//
//  MapView.swift
//  Proffer
//
//  Created by M.Magdy on 28/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//


import SwiftUI
import MapKit
import CoreLocation


import SwiftUI
import MapKit
import Combine

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var address: String
    @Binding var latitude: Double
    @Binding var longitude: Double

    @State private var region = MKCoordinateRegion()
    @State private var selectedLocation: IdentifiedCoordinate?
    @State private var isLoadingAddress = false // State for loading address
    @State private var previousCenter: CLLocationCoordinate2D? // Store the previous location for comparison

    var body: some View {
        ZStack {
            ZStack(alignment: .center) {
                // Map View
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                           .onReceive(Just(region.center)) { newCenter in
                               if shouldUpdateLocation(from: previousCenter, to: newCenter) {
                                   previousCenter = newCenter
                                   updateLocation(newCenter)
                               }
                           }
                
                // Pin in Center
                Image(.location)
                    .resizable()
                    .frame(width: 24,height: 30)
                    .offset(y: -17.5)
            }
            
            // Address and Confirm Button View
            VStack {
                Spacer()
                VStack {
                    VStack(spacing: 16) {
                        HStack {
                            Text("confirm_my_location".localized())
                                .textModifier(.plain, 14, .black222222)
                            Spacer()
                        }
                        Divider()
                        
                        HStack {
                            Image(.location)
                            if isLoadingAddress {
                                ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            } else {
                              Text(address.isEmpty ? "fetching_address".localized() : address)
                                    .textModifier(.plain, 19, .gray565656)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                            ReusableButton(buttonText: "confirm_location".localized()){
                                confirmLocation()

                            }
                        
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .padding()
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
            }
        }
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
        .onAppear {
            setInitialRegion()
        }
    }

    // Update location based on pin movement
    private func updateLocation(_ newCenter: CLLocationCoordinate2D) {
        selectedLocation = IdentifiedCoordinate(latitude: newCenter.latitude, longitude: newCenter.longitude)
        fetchAddress(for: newCenter)
    }
    private func shouldUpdateLocation(from oldCenter: CLLocationCoordinate2D?, to newCenter: CLLocationCoordinate2D) -> Bool {
        guard let oldCenter = oldCenter else { return true }
        let threshold: Double = 0.0001 // Sensitivity for movement
        let latitudeDifference = abs(oldCenter.latitude - newCenter.latitude)
        let longitudeDifference = abs(oldCenter.longitude - newCenter.longitude)
        return latitudeDifference > threshold || longitudeDifference > threshold
    }
    // Confirm and update the bindings
    private func confirmLocation() {
        guard let location = selectedLocation else { return }
        latitude = location.latitude
        longitude = location.longitude
        presentationMode.wrappedValue.dismiss()
    }

    // Set initial region to user's current location
    private func setInitialRegion() {
        guard let userLocation = CLLocationManager().location?.coordinate else { return }
        region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        updateLocation(userLocation)
    }

    // Fetch address for the given coordinates
    private func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        isLoadingAddress = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
          let geocoder = CLGeocoder()

        let localeIdentifier = Constants.shared.isAR ? "ar" : "en"
          let locale = Locale(identifier: localeIdentifier)
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            DispatchQueue.main.async {
                isLoadingAddress = false
                if let placemark = placemarks?.first {
                    address = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.postalCode]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                } else {
                  address = "unable_fetch_address".localized()
                }
            }
        }
    }
}

struct IdentifiedCoordinate: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}



