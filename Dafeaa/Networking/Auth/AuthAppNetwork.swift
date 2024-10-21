//
//  MainAppNetwork.swift
//

//

import Foundation
import Alamofire

enum AuthNetwork
{
    case appAvailability(appCode: String)
    case Login(dic:[String: Any])
    case signUp(dic:[String: Any])
    case userSubmitToken(token: String, device_id: String)
    case verify(dic:[String: Any])
    case verifyCode(dic: [String: Any])
    case sendCode(dic:[String: Any])
    case forgetPassword(dic:[String: Any])
    case countries
    case cities(countryId:Int)
    case changePhone(dic: [String: Any])

}

extension AuthNetwork: TargetType
{
    var baseURL: String {
        let source = Constants.shared.baseURL
        return source
    }
    
    var path: String {
        switch self {
        case .appAvailability(let appCode): return "check-avalability/\(appCode)"
        case .Login                       : return "auth/login"
        case .signUp                      : return "auth/register"
        case .userSubmitToken             : return "notifications/submit-token"
        case .verify                      : return "auth/verify"
        case .verifyCode                  : return "auth/verify-code"
        case .sendCode                    : return "auth/send-code"
        case .forgetPassword              : return "auth/new-password"
        case .countries                   : return "countries"
        case .cities                      : return "cities"
        case .changePhone                 : return "auth/change-phone"
}
    }
    
    var methods: HTTPMethod
    {
        switch self  {
        case.Login, .signUp, .userSubmitToken, .verify, .verifyCode, .sendCode, .forgetPassword,.changePhone: return .post

        default:  return .get
        }
    }
    
    var task: Task
    {
        switch self{
        case .Login(dic: let dic),let .changePhone(dic: dic),.signUp(dic: let dic), .verify(dic: let dic), .verifyCode(dic: let dic):
            return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case .forgetPassword(dic: let dic):
            return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case let .userSubmitToken(token, device_id):
            return .requestParameters(Parameters: ["token": token, "device_id": device_id], encoding: JSONEncoding.default)
        case let .sendCode(dic):
            return .requestParameters(Parameters: dic, encoding: JSONEncoding.default)
        case let .cities(countryId):
            return .requestParameters(Parameters: ["filter[country_id]": countryId], encoding: URLEncoding.default)
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

