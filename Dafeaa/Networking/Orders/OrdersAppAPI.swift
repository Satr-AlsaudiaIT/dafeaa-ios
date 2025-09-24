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
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<CreateOfferModel?, NSError>) -> Void)
    func offers(skip: Int, Completion: @escaping (Result<OffersModel?, NSError>) -> Void)
    func showDynamicLinks(code: String, Completion: @escaping (Result<ShowOfferModel?, NSError>) -> Void)
    func deleteDynamicLinks(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func activateStopLink(code: String,status:Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func updateQuantity(productId: Int,quantity:Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)

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
    
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<CreateOfferModel?, NSError>) -> Void){
        self.fetchData(target: .createClientOrder(dic:dic), responseClass: CreateOfferModel.self) { (result) in
            Completion(result)
        }
    }
    
    // merchentOffers
    
     func offers(skip: Int, Completion: @escaping (Result<OffersModel?, NSError>) -> Void){
         self.fetchData(target: .dynamicLinks(skip: skip), responseClass: OffersModel.self) { (result) in
             Completion(result)
         }
     }
    
    func showDynamicLinks(code: String, Completion: @escaping (Result<ShowOfferModel?, NSError>) -> Void){
        self.fetchData(target: .showDynamicLinks(code: code), responseClass: ShowOfferModel.self) { (result) in
            Completion(result)
        }
    }
    
    func deleteDynamicLinks(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .deleteDynamicLinks(id: id), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func activateStopLink(code: String,status:Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .activateStopLink(code: code, status: status), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
 
    
    func updateQuantity(productId: Int,quantity:Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .updateQuantity(productId: productId, newQuantity: quantity), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
}



protocol OrdersAPIProtocolV3 {
    func orders(skip : Int, status: String,type:String, Completion: @escaping (Result<OrdersModel?, NSError>) -> Void)
    func getOrder(id : Int, Completion: @escaping (Result<OrdersModelV3?, NSError>) -> Void)
    func changeOrderStatus(id : Int,status: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func completeOrder(id : Int,qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<CreateOfferModel?, NSError>) -> Void)
    
    
    func showDynamicLinks(code: String, Completion: @escaping (Result<ShowOfferModelV3?, NSError>) -> Void)
  

}

class OrdersAPIV3: BaseAPI<OrdersNetworkV3>, OrdersAPIProtocolV3
{
    func orders(skip : Int, status: String, type:String, Completion: @escaping (Result<OrdersModel?, NSError>) -> Void){
        self.fetchData(target: .orders(skip :skip, status: status,type: type), responseClass: OrdersModel.self) { (result) in
            Completion(result)
        }
    }
    
    func getOrder(id : Int, Completion: @escaping (Result<OrdersModelV3?, NSError>) -> Void){
        self.fetchData(target: .getOrder(id: id), responseClass: OrdersModelV3.self) { (result) in
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
    
    func createClientOrder(dic: [String:Any], Completion: @escaping (Result<CreateOfferModel?, NSError>) -> Void){
        self.fetchData(target: .createClientOrder(dic:dic), responseClass: CreateOfferModel.self) { (result) in
            Completion(result)
        }
    }
    
    
    
    // merchentOffers
    func showDynamicLinks(code: String, Completion: @escaping (Result<ShowOfferModelV3?, NSError>) -> Void){
        self.fetchData(target: .showDynamicLinks(code: code), responseClass: ShowOfferModelV3.self) { (result) in
            Completion(result)
        }
    }
    

    
}
