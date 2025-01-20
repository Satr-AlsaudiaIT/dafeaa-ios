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
    let description, amount, date: String?
}

