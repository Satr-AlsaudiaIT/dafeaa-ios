//
// MoreAPIProtocol.swift
//
//

//

import Foundation
protocol OrdersAPIProtocol {
    func orders(skip : Int, status: String,type:String, Completion: @escaping (Result<OrdersModel?, NSError>) -> Void)
    func getOrder(id : Int, Completion: @escaping (Result<OrderModel?, NSError>) -> Void)
    func changeOrderStatus(id : Int,status: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func completeOrder(id : Int,qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func offers(skip: Int, Completion: @escaping (Result<OffersModel?, NSError>) -> Void)
    func showDynamicLinks(id: Int, Completion: @escaping (Result<ShowOfferModel?, NSError>) -> Void)
    func deleteDynamicLinks(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func createDynamicLinks(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    
}

class OrdersAPI: BaseAPI<OrdersNetwork>, OrdersAPIProtocol
{
    func orders(skip : Int, status: String, type:String, Completion: @escaping (Result<OrdersModel?, NSError>) -> Void){
        self.fetchData(target: .orders(skip :skip, status: status,type: type), responseClass: OrdersModel.self) { (result) in
            Completion(result)
        }
    }
    
    func getOrder(id : Int, Completion: @escaping (Result<OrderModel?, NSError>) -> Void){
        self.fetchData(target: .getOrder(id: id), responseClass: OrderModel.self) { (result) in
            Completion(result)
        }
    }
    func changeOrderStatus(id : Int,status: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .changeStatus(id: id, status: status), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func completeOrder(id : Int,qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .completeOrder(id: id, qrCode: qrCode), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .createClientOrder(dic:dic), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    // merchentOffers
    
     func offers(skip: Int, Completion: @escaping (Result<OffersModel?, NSError>) -> Void){
         self.fetchData(target: .dynamicLinks(skip: skip), responseClass: OffersModel.self) { (result) in
             Completion(result)
         }
     }
    
    func showDynamicLinks(id: Int, Completion: @escaping (Result<ShowOfferModel?, NSError>) -> Void){
        self.fetchData(target: .showDynamicLinks(id: id), responseClass: ShowOfferModel.self) { (result) in
            Completion(result)
        }
    }
    
    func deleteDynamicLinks(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .deleteDynamicLinks(id: id), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func createDynamicLinks(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .createDynamicLinks(dic:dic), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    

}
