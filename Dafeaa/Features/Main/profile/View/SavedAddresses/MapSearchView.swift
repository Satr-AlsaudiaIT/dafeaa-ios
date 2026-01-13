//
//  MapSearchView.swift
//  Dafeaa
//
//  Created by AMNY on 06/01/2026.
//

import SwiftUI
import MapKit

struct MapSearchView: View {
    @StateObject private var searchService = LocationSearchService()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLocation: LocationResult?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedMapItem: MKMapItem?
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition, selection: $selectedMapItem) {
                if let location = searchService.selectedLocation {
                    Marker(location.formattedAddress, coordinate: location.coordinate)
                        .tint(.red)
                }
                
                if let userLocation = locationManager.currentLocation {
                    UserAnnotation()
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    TextField("search_location".localized(), text: $searchService.searchQuery)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .onChange(of: searchService.searchQuery) { _, newValue in
                            searchService.searchLocation(query: newValue)
                        }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
                .padding()
                
                if !searchService.searchResults.isEmpty {
                    List(searchService.searchResults, id: \.self) { result in
                        Button(action: {
                            searchService.selectCompletion(result)
                            searchService.searchResults = []
                            searchService.searchQuery = ""
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title)
                                    .font(.body)
                                    .foregroundColor(.black)
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 300)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                if searchService.selectedLocation != nil {
                    VStack {
                        ReusableButton(buttonText: "confirm_location".localized()) {
                            selectedLocation = searchService.selectedLocation
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                    }
                    .background(Color.white)
                }
            }
        }
        .onChange(of: searchService.selectedLocation) { _, newLocation in
            if let location = newLocation {
                withAnimation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
        }
        .onAppear {
            if let userLocation = locationManager.currentLocation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
    }
}
