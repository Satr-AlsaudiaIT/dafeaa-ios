//
// MoreAPIProtocol.swift
//
//

//

import Foundation
protocol MoreAPIProtocol {
    
    func profile(Completion: @escaping (Result<LoginModel?, NSError>) -> Void)
    func changePassword(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func logOut(Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func deleteAccount(Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func notifyOnOff(active: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func notificationsList(skip : Int,Completion: @escaping (Result<NotificationsModel?, NSError>) -> Void)
    func getStatic(type: String, Completion: @escaping (Result<StaticPagesModel?, NSError>) -> Void)
    func questions(skip : Int,Completion: @escaping (Result<QuestionsListModel?, NSError>) -> Void)
    func getContacts(Completion: @escaping (Result<ContactModel?, NSError>) -> Void)
    func addresses(Completion: @escaping (Result<AddressesModel?, NSError>) -> Void)
    func address(id:Int,method: HTTPMethod, dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func createAddress( dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func withDrawAmount( amount:Double, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func getWithdraws(skip:Int,Completion: @escaping (Result<withdrawsModel?, NSError>) -> Void)
    func addAmountToWallet( amount:Double, Completion: @escaping (Result<AddToWalletModel?, NSError>) -> Void)
    func getSubscriptionPlans(Completion: @escaping (Result<SubscriptionModel?, NSError>) -> Void)
    func selectSubscriptionPlan(id:Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)


}



class MoreAPI: BaseAPI<MoreNetwork>, MoreAPIProtocol
{
    
    func profile(Completion: @escaping (Result<LoginModel?, NSError>) -> Void){
        self.fetchData(target: .profile, responseClass: LoginModel.self) { (result) in
            Completion(result)
        }
    }
    
    func changePassword(dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .changePassword(dic: dic), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func logOut(Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .logOut, responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func deleteAccount(Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .deleteAccount, responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func notifyOnOff(active: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target:.notifyOnOff(active: active), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    
    func notificationsList(skip : Int,Completion: @escaping (Result<NotificationsModel?, NSError>) -> Void){ self.fetchData(target: .notificationList(skip: skip), responseClass: NotificationsModel.self){(result) in
        Completion(result)
        
    }
    }
    
    func getStatic(type: String, Completion: @escaping (Result<StaticPagesModel?, NSError>) -> Void){
        self.fetchData(target: .getStaticPages(type: type), responseClass: StaticPagesModel.self){(result) in
            Completion(result)
            
        }
    }
    
    func questions(skip : Int,Completion: @escaping (Result<QuestionsListModel?, NSError>) -> Void){
        self.fetchData(target: .questions(skip :skip), responseClass: QuestionsListModel.self) { (result) in
            Completion(result)
        }
    }
    
    func getContacts(Completion: @escaping (Result<ContactModel?, NSError>) -> Void){
        self.fetchData(target: .contacts, responseClass: ContactModel.self) { (result) in
            Completion(result)
        }
    }
 
    func addresses(Completion: @escaping (Result<AddressesModel?, NSError>) -> Void){
        self.fetchData(target: .addresses, responseClass: AddressesModel.self) { (result) in
            Completion(result)
        }
    }
 
    func address(id:Int,method: HTTPMethod, dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .address(id: id, method: method, dic: dic), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    func createAddress( dic: [String:Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .createAddress(dic: dic), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    func withDrawAmount( amount:Double, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void){
        self.fetchData(target: .withDraw(amount: amount), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
    func getWithdraws(skip:Int, Completion: @escaping (Result<withdrawsModel?, NSError>) -> Void){
        self.fetchData(target: .getWithdraws(skip: skip), responseClass: withdrawsModel.self) { (result) in
            Completion(result)
        }
    }
    
    func addAmountToWallet( amount:Double, Completion: @escaping (Result<AddToWalletModel?, NSError>) -> Void){
        self.fetchData(target: .addAmountToWallet(amount: amount), responseClass: AddToWalletModel.self) { (result) in
            Completion(result)
        }
    }
    
    func getSubscriptionPlans(Completion: @escaping (Result<SubscriptionModel?, NSError>) -> Void) {
        self.fetchData(target: .getSubScriptionPlans, responseClass: SubscriptionModel.self) { (result) in
            Completion(result)
        }
    }
    func selectSubscriptionPlan(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .selectSubscriptionPlan(id: id), responseClass: GeneralModel.self) { (result) in
            Completion(result)
        }
    }
}
