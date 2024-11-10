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
}

extension HomeNetwork: TargetType {
    var baseURL: String {
        let source = Constants.shared.baseURL
        return source
    }
    
    var path: String {
        switch self {
        case .home                          :return "home"
        case .wallet(let skip)              :return "wallet/transaction?skip=\(skip)"
        case .operations(let skip)          :return "wallet/operation?skip=\(skip)" }
    }
    
    var methods: HTTPMethod {
        switch self  {
        default                             :return .get }
    }
    
    var task: Task {
        switch self{
        default                             :return .requestPlain  }
    }
    
    var headers: [String : String]? {
        switch self {
        default                             :return NetWorkHelper.shared.Headers()  }
    }
}

