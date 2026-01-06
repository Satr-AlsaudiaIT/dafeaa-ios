//
//  IBANNetwork.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//
import Foundation
import Alamofire

enum IBANNetwork {
    case getIBANs
    case createIBAN(dic: [String: Any])
    case updateIBAN(id: Int, dic: [String: Any])
    case deleteIBAN(id: Int)
}

extension IBANNetwork: TargetType {
    var baseURL: String {
        let source = Constants.shared.baseURLV1
        return source
    }
    
    var path: String {
        switch self {
        case .getIBANs:                     return "client-ibans"
        case .createIBAN:                   return "client-ibans"
        case .updateIBAN(let id, _):        return "client-ibans/\(id)"
        case .deleteIBAN(let id):           return "client-ibans/\(id)"
        }
    }
    
    var methods: HTTPMethod {
        switch self {
        case .createIBAN:                   return .post
        case .updateIBAN:                   return .put
        case .deleteIBAN:                   return .delete
        default:                            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .createIBAN(dic):
            return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case let .updateIBAN(_, dic):
            return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
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
