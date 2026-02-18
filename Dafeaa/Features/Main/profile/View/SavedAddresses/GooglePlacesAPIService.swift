//
//  GooglePlacesAPIService.swift
//  Dafeaa
//
//  Created by AMNY on 25/01/2026.
//


import Foundation
import Combine

class GooglePlacesAPIService: ObservableObject {
    private let apiKey = "AIzaSyAsii5qK2U6xsP39ahyNOoDjXDfHIzH9yU"
    private let baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    func fetchAutocompleteSuggestions(query: String, completion: @escaping ([PlaceSuggestion]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "language", value: "en"),  // Force English
            URLQueryItem(name: "components", value: "country:sa"),  // Restrict to Saudi Arabia
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching autocomplete: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
                let suggestions = result.predictions.map { prediction in
                    PlaceSuggestion(
                        placeID: prediction.placeID,
                        description: prediction.description,
                        mainText: prediction.structuredFormatting.mainText,
                        secondaryText: prediction.structuredFormatting.secondaryText
                    )
                }
                DispatchQueue.main.async {
                    completion(suggestions)
                }
            } catch {
                print("Error decoding: \(error)")
                completion([])
            }
        }.resume()
    }
    
    func fetchPlaceDetails(placeID: String, completion: @escaping (PlaceDetails?) -> Void) {
        let detailsURL = "https://maps.googleapis.com/maps/api/place/details/json"
        
        var components = URLComponents(string: detailsURL)
        components?.queryItems = [
            URLQueryItem(name: "place_id", value: placeID),
            URLQueryItem(name: "language", value: "en"),  // Force English
            URLQueryItem(name: "fields", value: "geometry,address_component,formatted_address,name"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching place details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.result)
                }
            } catch {
                print("Error decoding place details: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - Models

struct AutocompleteResponse: Codable {
    let predictions: [Prediction]
    let status: String
}

struct Prediction: Codable {
    let description: String
    let placeID: String
    let structuredFormatting: StructuredFormatting
    
    enum CodingKeys: String, CodingKey {
        case description
        case placeID = "place_id"
        case structuredFormatting = "structured_formatting"
    }
}

struct StructuredFormatting: Codable {
    let mainText: String
    let secondaryText: String?
    
    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }
}

struct PlaceSuggestion: Identifiable {
    let id = UUID()
    let placeID: String
    let description: String
    let mainText: String
    let secondaryText: String?
}

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetails
    let status: String
}

struct PlaceDetails: Codable {
    let geometry: Geometry
    let addressComponents: [AddressComponent]
    let formattedAddress: String
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case geometry
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case name
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct AddressComponent: Codable {
    let longName: String
    let shortName: String
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}
