//
//  MoreAppNetwork.swift
//

//

import Foundation
import Alamofire

enum MoreNetwork
{
   
    case profile
    case changePassword(dic: [String: Any])
    case contactUs(dic: [String: Any])
    case logOut
    case deleteAccount
    case notifyOnOff(active: Int)
    case notificationList(skip: Int)
    case getStaticPages(type: String)
    case questions(skip: Int)
    case contacts
    case addresses
    case address(id: Int, method: HTTPMethod, dic: [String: Any])
    case createAddress(dic:[String:Any])
    case withDraw(amount: Double)
    case getWithdraws(skip:Int)
    case addAmountToWallet(amount: Double)
    case getSubScriptionPlans
}

extension MoreNetwork: TargetType
{
    var baseURL: String {
        let source = Constants.shared.baseURL
        return source
    }
    
    var path: String {
        switch self {
        case .profile:                      return "auth/profile"
        case .changePassword:               return "auth/change-password"
        case .contactUs:                    return "contact-us"
        case .logOut:                       return "auth/logout"
        case .deleteAccount:                return "auth/delete-account"
        case .notifyOnOff:                  return "notifications/active"
        case .notificationList(let skip):   return "notifications?skip=\(skip)"
        case .getStaticPages(let type):     return "\(type)"
        case .questions(let skip):          return"settings/faq?skip=\(skip)"
        case .contacts:                     return "settings/contact"
        case .addresses:                    return "addresses"
        case .createAddress:                return "addresses"
        case .address(let id,_,_):          return "addresses/\(id)"
        case .withDraw:                     return "withdraws"
        case .getWithdraws(let skip):       return "withdraws?skip=\(skip)&take=10"
        case .addAmountToWallet:            return "payments/submit"
        case .getSubScriptionPlans:          return "subscription-plans"
        }
    }
    
    var methods: HTTPMethod
    {
        switch self  {
        case.changePassword, .contactUs, .logOut, .notifyOnOff,.createAddress,
                .withDraw, .addAmountToWallet:                                    return .post
        case .address(_, let method, _):                                          return method
        case .deleteAccount:                                                      return .delete
        default:                                                                  return .get
        }
    }
    
    var task: Task
    {
        switch self{

        case let .changePassword(dic):
            return.requestParameters(Parameters: dic , encoding: JSONEncoding.default)
        case let .contactUs(dic):
            return.requestParameters(Parameters: dic , encoding: JSONEncoding.default)
        case let .notifyOnOff(active):
            return .requestParameters(Parameters: ["active_notification":active], encoding: JSONEncoding.default)
        case let .address(_, _, dic):
            return.requestParameters(Parameters: dic , encoding: JSONEncoding.default)
        case let .createAddress(dic):
            return.requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case let .withDraw(amount):
            return.requestParameters(Parameters: ["amount":amount], encoding: JSONEncoding.default)
        case let .addAmountToWallet(amount):
            return.requestParameters(Parameters: ["amount":amount], encoding: JSONEncoding.default)
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

