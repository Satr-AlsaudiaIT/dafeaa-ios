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
    
   
}
