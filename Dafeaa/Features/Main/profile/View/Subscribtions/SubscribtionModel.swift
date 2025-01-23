//
//  SubscribtionModel.swift
//  Dafeaa
//
//  Created by M.Magdy on 20/10/2024.
//

import SwiftUI


// MARK: - Welcome
struct SubscriptionModel: Codable {
    let status: Bool?
    let message: String?
    let data: [SubscriptionModelData]?
    let count: Int?
}

// MARK: - SubscribtionModelData
struct SubscriptionModelData: Codable,Equatable {
    let id: Int
    let price: Double?
    let text: String?
    let minProduct, maxProduct: Int?
}



