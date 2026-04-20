//
//  QRCodeModel.swift
//  Dafeaa
//
//  Created by AMNY on 08/04/2026.
//

import Foundation

struct QRCodeModel: Codable {
    var qrCode      : String?
    var expiresTime : Int?
}

struct QRStatusModel: Codable {
    var id :Int?
    var amount:String?
    var status  : String?
    var remaingTime,expiresAt :String?
    var message : String?
}
