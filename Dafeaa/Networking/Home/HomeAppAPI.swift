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
    func generateQR(amount: String,reason: String, Completion: @escaping (Result<QRCodeModel?, NSError>) -> Void)
    func cancelQR(qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func checkQRStatus(qrCode: String, Completion: @escaping (Result<QRStatusModel?, NSError>) -> Void)
    func acceptQR(qrCode: String, Completion: @escaping (Result<AcceptQRResponse?, NSError>) -> Void) 
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
 
    func generateQR(amount: String,reason: String, Completion: @escaping (Result<QRCodeModel?, NSError>) -> Void) {
        self.fetchData(target: .generateQR(amount: amount,reason: reason), responseClass: QRCodeModel.self) { result in
            Completion(result)
        }
    }

    func cancelQR(qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .cancelQR(qrCode: qrCode), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }

    func checkQRStatus(qrCode: String, Completion: @escaping (Result<QRStatusModel?, NSError>) -> Void) {
        self.fetchData(target: .checkQRStatus(qrCode: qrCode), responseClass: QRStatusModel.self) { result in
            Completion(result)
        }
    }
    
    func acceptQR(qrCode: String, Completion: @escaping (Result<AcceptQRResponse?, NSError>) -> Void) {
        self.fetchData(target: .acceptQR(qrCode: qrCode), responseClass: AcceptQRResponse.self) { result in
            Completion(result)
        }
    }
}
