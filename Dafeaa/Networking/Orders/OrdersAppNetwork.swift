//
//  OrdersAppNetwork.swift
//

//

import Foundation
import Alamofire

enum OrdersNetwork {
    case orders(skip: Int, status: String, type: String)
    case getOrder(id: Int)
    case changeStatus(id:Int,status:Int)
    case completeOrder(id:Int,qrCode:String)
    case createClientOrder(dic: [String:Any])
    //merchantOffers
    case dynamicLinks(skip: Int)
    case showDynamicLinks(code: String)
    case deleteDynamicLinks(id: Int)
    case createDynamicLinks(dic: [String:Any])
    case activateStopLink(code: String,status: Int)
    case updateQuantity(productId:Int,newQuantity:Int)
}

extension OrdersNetwork: TargetType {
    var baseURL: String {
        // To do if return to v2
        let source = Constants.shared.baseURL
        return source
    }
    
    var path: String {
        switch self {
        case .orders(let skip,let status, let type):   return"orders/\(type)?skip=\(skip)&filter[status]=\(status)"//1
        case .getOrder(let id):              return "orders/\(id)"//2
        case .changeStatus(let id, _):       return "orders/\(id)"
        case .completeOrder(let id, _):      return "orders/\(id)"
        case .createClientOrder:             return "orders"
            
        //merchantOffers
        case .dynamicLinks(skip: let skip):  return "links?skip=\(skip)"//1
        case .showDynamicLinks(code: let code)://1
            return "links/\(code)"
        case .deleteDynamicLinks(id: let id)://6
            return "links/\(id)"
        case .createDynamicLinks :           return "links"//3
        case .activateStopLink(code: let code,_)://4
            return "links/\(code)"
        case .updateQuantity(productId: let id,_)://5
            return "links/products/\(id)"
        }
    }
    
    var methods: HTTPMethod {
        switch self  {
        case .changeStatus,.createClientOrder,
                .createDynamicLinks, .completeOrder, .activateStopLink, .updateQuantity:                               return .post
        case .deleteDynamicLinks :              return .delete
        default:                                return .get
        }
    }
    
    var task: Task {
        switch self{
        case .changeStatus( _, let  status): return .requestParameters(Parameters: ["_method": "put", "status": status], encoding: JSONEncoding.default)
        case .completeOrder( _, let  qrCode): return .requestParameters(Parameters: ["qr_code": qrCode], encoding: JSONEncoding.default)
        case .createDynamicLinks(let dic),.createClientOrder(let dic):    return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case .activateStopLink(_,let status):
            return .requestParameters(Parameters: ["_method": "put","status": status], encoding: JSONEncoding.default)
        case .updateQuantity(_, let quantity):
            let param : [String: Any] = ["_method": "put",
                                         "quantity": quantity]
            return .requestParameters(Parameters: param, encoding: JSONEncoding.default)
        default:                              return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:                             return NetWorkHelper.shared.Headers()
        }
    }
}


enum OrdersNetworkV3 {
    case orders(skip: Int, status: String, type: String)
    case getOrder(id: Int)
    case changeStatus(id:Int,status:Int)
    case completeOrder(id:Int,qrCode:String)
    case createClientOrder(dic: [String:Any])
    //merchantOffers
    case dynamicLinks(skip: Int)
    case showDynamicLinks(code: String)
    case deleteDynamicLinks(id: Int)
    case createDynamicLinks(dic: [String:Any])
    case activateStopLink(code: String,status: Int)
    case updateQuantity(productId:Int,newQuantity:Int)
    case shippingRates(company: String, parm: [String: Any])
}

extension OrdersNetworkV3: TargetType {
    var baseURL: String {
        switch self {
        case .shippingRates:
            let source = Constants.shared.baseURLV1
            return source
        default: 
            let source = Constants.shared.basURLV3
            return source
        }
    }
    
    var path: String {
        switch self {
        case .orders(let skip,let status, let type):   return"orders/\(type)?skip=\(skip)&filter[status]=\(status)"//1
        case .getOrder(let id):              return "orders/\(id)"//2
        case .changeStatus(let id, _):       return "orders/\(id)"
        case .completeOrder(let id, _):      return "orders/\(id)"
        case .createClientOrder:             return "orders"
            
        //merchantOffers
        case .dynamicLinks(skip: let skip):  return "links?skip=\(skip)"//1
        case .showDynamicLinks(code: let code)://1
            return "links/\(code)"
        case .deleteDynamicLinks(id: let id)://6
            return "links/\(id)"
        case .createDynamicLinks :           return "links"//3
        case .activateStopLink(code: let code,_)://4
            return "links/\(code)"
        case .updateQuantity(productId: let id,_)://5
            return "links/products/\(id)"
        case .shippingRates(company: let company, _):
            return "\(company)/rates"
        }
    }
    
    var methods: HTTPMethod {
        switch self  {
        case .changeStatus,.createClientOrder,
                .createDynamicLinks, .completeOrder, .activateStopLink, .updateQuantity:                               return .post
        case .deleteDynamicLinks :              return .delete
        default:                                return .get
        }
    }
    
    var task: Task {
        switch self{
        case .changeStatus( _, let  status): return .requestParameters(Parameters: ["_method": "put", "status": status], encoding: JSONEncoding.default)
        case .completeOrder( _, let  qrCode): return .requestParameters(Parameters: ["qr_code": qrCode], encoding: JSONEncoding.default)
        case .createDynamicLinks(let dic),.createClientOrder(let dic):    return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case .activateStopLink(_,let status):
            return .requestParameters(Parameters: ["_method": "put","status": status], encoding: JSONEncoding.default)
        case .updateQuantity(_, let quantity):
            let param : [String: Any] = ["_method": "put",
                                         "quantity": quantity]
            return .requestParameters(Parameters: param, encoding: JSONEncoding.default)
        case .shippingRates(_, let parameters):
            
            return .requestParameters(Parameters: parameters, encoding: URLEncoding.default)
        default:                              return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:                             return NetWorkHelper.shared.Headers()
        }
    }
}
