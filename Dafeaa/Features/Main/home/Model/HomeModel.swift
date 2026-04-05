//
//  HomeModel.swift
//  Dafeaa
//
//  Created by M.Magdy on 25/10/2024.
//

import Foundation

// MARK: - Welcome
struct HomeModel: Codable {
    let status: Bool?
    let message: String?
    let data: [HomeModelData]?
    let availableBalance: Double?
    let currency: String?
   
}

// MARK: - HomeModelData
struct HomeModelData: Codable {
    let id: Int?
        let status: Int?
        let toName: String?
        let toPhone: String?
        let description: String?
        let amount: String?
        let date: String?
        let type: Int?
        let value: String?
        let orderId: FlexibleStringOrInt?
        let transactionId: String?
}


enum FlexibleStringOrInt: Codable, Equatable {
    case string(String)
    case int(Int)
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        case .none:
            try container.encodeNil()
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let val): return val
        case .int(let val): return String(val)
        case .none: return nil
        }
    }
}


struct GetNameFromPhoneModel: Codable {
    let status: Bool?
    let message: String?
    let data: String?
}

struct ConfirmTransferModel: Codable {
    let status: Bool?
    let message: String?
    let data: ConfirmTransferData?
    let errors: ConfirmTransferData?
}

struct ConfirmTransferData: Codable {
    var createdAt : String?
    var transId: String?
}



import Foundation

struct ApplePayResponse: Codable {
    let success: Bool?
    let message: String?
    let transactionId: String?
    let status: String?
    let amount: Int?
    let currency: String?
    let walletCharged: Bool?
    
}
