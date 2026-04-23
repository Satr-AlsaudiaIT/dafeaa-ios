//
//  TransferReason.swift
//  Dafeaa
//
//  Created by AMNY on 21/04/2026.
//

import Foundation

struct TransferReason: Identifiable, Hashable {
    let id: Int
    let key: String

    var localized: String {
        key.localized()
    }

    static let all: [TransferReason] = [
        TransferReason(id: 1, key: "transfer_reason_personal"),
        TransferReason(id: 2, key: "transfer_reason_friend_family"),
        TransferReason(id: 3, key: "transfer_reason_debt"       ),
        TransferReason(id: 4, key: "transfer_reason_service"),
        TransferReason(id: 5, key: "transfer_reason_gift"),
        TransferReason(id: 6, key: "transfer_reason_other"),
    ]

    static var displayList: [String] {
        all.map { $0.localized }
    }

    static func reason(for displayText: String) -> TransferReason? {
        all.first { $0.localized == displayText }
    }
}
