//
//  LocationSearchService.swift
//  Dafeaa
//
//  Created by AMNY on 06/01/2026.
//

import Foundation
import MapKit
import Combine

class LocationSearchService: NSObject, ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedLocation: LocationResult?
    
    private let completer: MKLocalSearchCompleter
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func searchLocation(query: String) {
        searchQuery = query
        completer.queryFragment = query
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let mapItem = response?.mapItems.first else {
                return
            }
            
            let placemark = mapItem.placemark
            
            self.selectedLocation = LocationResult(
                coordinate: placemark.coordinate,
                placemark: placemark
            )
        }
    }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

struct LocationResult: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let placemark: MKPlacemark
    
    // Equatable conformance
    static func == (lhs: LocationResult, rhs: LocationResult) -> Bool {
        return lhs.id == rhs.id &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    var formattedAddress: String {
        let components = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ].compactMap { $0 }
        return components.joined(separator: ", ")
    }
    
    var countryName: String {
        return placemark.country ?? ""
    }
    
    var cityName: String {
        return placemark.locality ?? ""
    }
    
    var districtName: String {
        return placemark.subLocality ?? ""
    }
    
    var streetName: String {
        return placemark.thoroughfare ?? ""
    }
    
    var postalCode: String {
        return placemark.postalCode ?? ""
    }
    
    var latitude: Double {
        return coordinate.latitude
    }
    
    var longitude: Double {
        return coordinate.longitude
    }
}
