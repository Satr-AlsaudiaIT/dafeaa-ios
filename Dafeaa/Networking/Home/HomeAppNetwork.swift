//
//  HomeAppNetwork.swift
//

//

import Foundation
import Alamofire

enum HomeNetwork {
    case home
    case wallet(skip: Int)
    case operations(skip: Int)
    case applePay(amount: Int, token: String)
    case generateQR(amount: String)
    case cancelQR(qrCode: String)
    case checkQRStatus(qrCode: String)
    case acceptQR(qrCode: String)
}

extension HomeNetwork: TargetType {
    var baseURL: String {
        switch self {
            
        case .applePay, .generateQR, .cancelQR, .checkQRStatus, .acceptQR:
            return Constants.shared.baseURLV1
        default  :
            return Constants.shared.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .home                          :return "home"
        case .wallet(let skip)              :return "wallet?skip=\(skip)"
        case .operations(let skip)          :return "wallet/operation?skip=\(skip)"
        case .applePay                      :return "payments/apple-pay"
        case .generateQR:                   return "wallet-transfer"
        case .cancelQR(let qrCode):         return "wallet-transfers/cancel/\(qrCode)"
        case .checkQRStatus(let qrCode):    return "wallet-transfer/\(qrCode)"
        case .acceptQR(qrCode: let qrCode): return "wallet-transfer/accept/\(qrCode)"
        }
    }
    
    var methods: HTTPMethod {
        switch self {
        case .applePay , .generateQR, .cancelQR,.acceptQR:
            return .post
                     
        default  :return .get
        }
    }
    
    var task: Task {
        switch self {
        case .applePay(let amount, let token):
            // Create request body
            let parameters: [String: Any] = [
                "amount": amount,
                "token": token
            ]
            return .requestParameters(Parameters:  parameters, encoding: JSONEncoding.default)
        case .generateQR(let amount):
            return .requestParameters(Parameters: ["amount": amount], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return NetWorkHelper.shared.Headers()
        }
    }
}
