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
}

extension HomeNetwork: TargetType {
    var baseURL: String {
        switch self {
            
        case .applePay:
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
        }
    }
    
    var methods: HTTPMethod {
        switch self {
        case .applePay                      :return .post  
        default                             :return .get
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
