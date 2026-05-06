//
//  FinancialInfoResponse.swift
//  Dafeaa
//
//  Created by AMNY on 27/04/2026.
//


import Foundation

struct FinancialInfoResponse: Codable {
    let status: Bool?
    let message: String?
    let data: FinancialInfoData?
}

struct FinancialInfoData: Codable {
    let id: Int?
    let incomeSource: Int?
    let incomeSourceLabel: String?
    let incomeRange: Int?
    let incomeRangeLabel: String?
    let taxResidency: Bool?
    let isPep: Bool?
    let isCompleted: Bool?
}

// Structs for the DropDowns
struct DropDownOption: Identifiable, Hashable {
    let id: Int
    let label: String
}
