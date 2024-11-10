//
//  urlExtension.swift
//  Dafeaa
//
//  Created by AMNY on 09/11/2024.
//


import Foundation
import SwiftUI

extension URL {
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}

extension URL {
    func params() -> [String:Any] {
        var dict = [String:Any]()
        
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            return dict
        } else {
            return [:]
        }
    }
}