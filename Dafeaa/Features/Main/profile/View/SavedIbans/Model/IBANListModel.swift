//
//  IBANListModel.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//

import Foundation

// MARK: - IBANListModel
struct IBANListModel: Codable {
    let status: Bool?
    let message: String?
    let data: [IBANData]?
    let count: Int?
}

// MARK: - IBANData
struct IBANData: Codable, Identifiable, Equatable {
    let id: Int?
    let name: String?
    let iban: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, iban
        case createdAt = "created_at"
    }
}
