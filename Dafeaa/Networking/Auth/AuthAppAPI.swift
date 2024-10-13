//
// AuthAPIProtocol.swift
//
//

//

import Foundation
protocol AuthAPIProtocol {
    func appAvailability(appCode:String,Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func submitToken(token: String, deviceId: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func login(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void)
    func signUp(dic:[String:Any],Completion: @escaping (Result<RegisterModel?, NSError>) -> Void)
    func verify(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void)
    func verifyCode(dic:[String:Any],Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func sendCode(dic:[String:Any],Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func forgetPassword(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void)
    
}



class AuthAPI: BaseAPI<AuthNetwork>, AuthAPIProtocol
{
    func appAvailability(appCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target:.appAvailability(appCode: appCode), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }

    func submitToken(token: String, deviceId: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
            self.fetchData(target:.userSubmitToken(token: token, device_id: deviceId), responseClass: GeneralModel.self) { (result) in
                Completion(result)
            }
        }
    func login(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void){
        
        self.fetchData(target: .Login(dic: dic), responseClass: LoginModel.self) { (result) in
            Completion(result)
        }
        
    }
    func signUp(dic:[String:Any],Completion: @escaping (Result<RegisterModel?, NSError>) -> Void){
        
        self.fetchData(target: .signUp(dic: dic), responseClass: RegisterModel.self) { (result) in
            Completion(result)
        }
        
    }
    
    func verify(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void){
        
        self.fetchData(target: .verify(dic: dic), responseClass: LoginModel.self) { (result) in
            Completion(result)
        }
        
    }
    
    func sendCode(dic:[String:Any],Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .sendCode(dic: dic), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }
    
    func verifyCode(dic:[String:Any],Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .verifyCode(dic: dic), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }

    
    
    func forgetPassword(dic:[String:Any],Completion: @escaping (Result<LoginModel?, NSError>) -> Void){
        
        self.fetchData(target: .forgetPassword(dic: dic), responseClass: LoginModel.self) { (result) in
            Completion(result)
        }
        
    }
}
