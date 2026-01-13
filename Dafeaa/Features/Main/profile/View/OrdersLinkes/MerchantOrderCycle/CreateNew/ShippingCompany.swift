//
//  ShippingCompany.swift
//  Dafeaa
//
//  Created by AMNY on 11/01/2026.
//


enum ShippingCompany: String, CaseIterable, Identifiable {
    case dhl, aramex, samsa

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dhl: return "DHL"
        case .aramex: return "Aramex"
        case .samsa: return "SMSA"
        }
    }

    // Image + color assets are named exactly: dhl, aramex, samsa
    var assetName: String { rawValue }
}
