//
// HomeAPIProtocol.swift
//
//

import Foundation
protocol HomeAPIProtocol {
    func home(Completion: @escaping (Result<HomeModel?, NSError>) -> Void)
    func wallet(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void)
    func operations(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void)
    func processApplePay(amount: Int, token: String, Completion: @escaping (Result<ApplePayResponse?, NSError>) -> Void)
}

class HomeAPI: BaseAPI<HomeNetwork>, HomeAPIProtocol
{
    func home(Completion: @escaping (Result<HomeModel?, NSError>) -> Void){
        self.fetchData(target: .home, responseClass: HomeModel.self) { (result) in
            Completion(result)
        }
    }
    
    func wallet(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void){
        self.fetchData(target: .wallet(skip: skip), responseClass: WalletModel.self) { (result) in
            Completion(result)
        }
    }
    
    func operations(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void){
        self.fetchData(target: .operations(skip: skip), responseClass: WalletModel.self) { (result) in
            Completion(result)
        }
    }

    func processApplePay(amount: Int, token: String, Completion: @escaping (Result<ApplePayResponse?, NSError>) -> Void) {
         self.fetchApplePayData(target: .applePay(amount: amount, token: token), responseClass: ApplePayResponse.self) { (result) in
             Completion(result)
         }
     }
    
}
