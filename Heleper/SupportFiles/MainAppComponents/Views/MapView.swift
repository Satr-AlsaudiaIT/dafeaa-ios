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



struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var address: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    @State private var region = MKCoordinateRegion()
    @State private var selectedLocation: IdentifiedCoordinate?
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                    .edgesIgnoringSafeArea(.all)
                
                if let location = selectedLocation {
                    PinAnnotationView(coordinate: location.coordinate)
                }
            }
            
            Button(action: {
                guard let location = selectedLocation else {
                    // Handle case when no location is selected
                    return
                }
                let geocoder = CLGeocoder()
                let locale = Locale(identifier: Constants.shared.isAR ? "ar": "en" ) // Set to the current app locale
                let selectedLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                geocoder.reverseGeocodeLocation(selectedLocation, preferredLocale: locale) { placemarks, error in
                    if let placemark = placemarks?.first {
                        address = placemark.name ?? ""
                        latitude = selectedLocation.coordinate.latitude
                        longitude = selectedLocation.coordinate.longitude
                        // You can also access other address components like city and country here
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Select Location".localized())
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            setInitialRegion()
        }
        .onTapGesture {
            let mapCenter = self.region.center
            selectedLocation = IdentifiedCoordinate(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        }
    }
    
    private func setInitialRegion() {
        guard let userLocation = CLLocationManager().location?.coordinate else {
            return
        }
        
        region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        selectedLocation = IdentifiedCoordinate(latitude: userLocation.latitude, longitude: userLocation.longitude)
    }
    
    struct PinAnnotationView: View {
        var coordinate: CLLocationCoordinate2D
        
        var body: some View {
            //MARK: - mapIcon image
            Image(".mapIcon")
                .resizable()
                .frame(width: 25, height: 35)
                .foregroundColor(.red)
                .offset(y: -20)     
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

struct MapView_Previews: PreviewProvider {
    @State static var address = ""
    @State static var latitude = 0.0
    @State static var longitude = 0.0
    
    static var previews: some View {
        MapView(address: $address, latitude: $latitude, longitude: $longitude)
    }
}

