//
//  OrdersAppNetwork.swift
//

//

import Foundation
import Alamofire

enum OrdersNetwork {
    case orders(skip: Int, status: String)
    case getOrder(id: Int)
    case changeStatus(id:Int,status:Int)
    case completeOrder(id:Int,qrCode:String)
    case createClientOrder(dic: [String:Any])
    //merchantOffers
    case dynamicLinks(skip: Int)
    case showDynamicLinks(id: Int)
    case deleteDynamicLinks(id: Int)
    case createDynamicLinks(dic: [String:Any])
}

extension OrdersNetwork: TargetType {
    var baseURL: String {
        let source = Constants.shared.baseURL
        return source
    }
    
    var path: String {
        switch self {
        case .orders(let skip,let status):   return"orders?skip=\(skip)&filter[status]=\(status)"
        case .getOrder(let id):              return "orders/\(id)"
        case .changeStatus(let id, _):       return "orders/\(id)"
        case .completeOrder(let id, _):      return "orders/\(id)"
        case .createClientOrder:             return "orders"
            
        //merchantOffers
        case .dynamicLinks(skip: let skip):  return "links?skip=\(skip)"
        case .showDynamicLinks(id: let id),.deleteDynamicLinks(id: let id):
            return "links/\(id)"
        case .createDynamicLinks :           return "links"
            
        }
    }
    
    var methods: HTTPMethod {
        switch self  {
        case .changeStatus,.createClientOrder,
             .createDynamicLinks,.completeOrder:  return .post
        case .deleteDynamicLinks :              return .delete
        default:                                return .get
        }
    }
    
    var task: Task {
        switch self{
        case .changeStatus( _, let  status): return .requestParameters(Parameters: ["_method": "put", "status": status], encoding: JSONEncoding.default)
        case .completeOrder( _, let  qrCode): return .requestParameters(Parameters: ["qr_code": qrCode], encoding: JSONEncoding.default)
        case .createDynamicLinks(let dic),.createClientOrder(let dic):    return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
            
        default:                              return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:                             return NetWorkHelper.shared.Headers()
        }
    }
}

