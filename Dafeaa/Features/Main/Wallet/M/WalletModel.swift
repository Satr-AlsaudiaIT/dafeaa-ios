//
//  WalletModel.swift
//  Dafeaa
//
//  Created by M.Magdy on 25/10/2024.
//

import Foundation

struct WalletModel: Codable {
    let status: Bool
    let message: String
    let data: [HomeModelData]
    let outstandingBalance, availableBalance: Float?
    let currency: String?
    let count: Int?
}
