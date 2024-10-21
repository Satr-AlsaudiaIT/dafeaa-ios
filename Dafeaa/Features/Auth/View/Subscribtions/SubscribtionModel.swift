//
//  SubscribtionModel.swift
//  Dafeaa
//
//  Created by M.Magdy on 20/10/2024.
//

import SwiftUI


// MARK: - Welcome
struct SubscribtionModel: Codable {
    let status: Bool
    let message: String
    let data: [SubscribtionModelData]
}

// MARK: - SubscribtionModelData
struct SubscribtionModelData: Codable {
    let id: Int
    let price: Int?
    let percentage: Double?
    let forUse: String?
    let description: String?
}
