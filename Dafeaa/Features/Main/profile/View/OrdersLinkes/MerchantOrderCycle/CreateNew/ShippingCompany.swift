//
//  ShippingCompany.swift
//  Dafeaa
//
//  Created by AMNY on 11/01/2026.
//


enum ShippingCompany: String, CaseIterable, Identifiable {
    case dhl, aramex, smsa

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dhl: return "DHL"
        case .aramex: return "Aramex"
        case .smsa: return "SMSA"
        }
    }

    // Image + color assets are named exactly: dhl, aramex, smsa
    var assetName: String { rawValue }
}
