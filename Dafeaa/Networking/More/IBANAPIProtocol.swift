//
//  IBANAPIProtocol.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//

import Foundation

protocol IBANAPIProtocol {
    func getIBANs(Completion: @escaping (Result<IBANListModel?, NSError>) -> Void)
    func createIBAN(dic: [String: Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func updateIBAN(id: Int, dic: [String: Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func deleteIBAN(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
}

class IBANAPI: BaseAPI<IBANNetwork>, IBANAPIProtocol {
    
    func getIBANs(Completion: @escaping (Result<IBANListModel?, NSError>) -> Void) {
        self.fetchData(target: .getIBANs, responseClass: IBANListModel.self) { result in
            Completion(result)
        }
    }

    func createIBAN(dic: [String: Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .createIBAN(dic: dic), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }

    func updateIBAN(id: Int, dic: [String: Any], Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .updateIBAN(id: id, dic: dic), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }

    func deleteIBAN(id: Int, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .deleteIBAN(id: id), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }
}
