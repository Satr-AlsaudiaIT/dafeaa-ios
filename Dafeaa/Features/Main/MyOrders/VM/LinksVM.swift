//
//  LinksVM.swift
//  Dafeaa
//
//  Created by AMNY on 09/11/2024.
//


import Foundation
import UIKit

final class LinksVM : ObservableObject {
    
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
   
    
    @Published var _isSuccess              = false
 

    private var _message                   : String = ""
    private var token                      = ""
    let api                                : OrdersAPIProtocol = OrdersAPI()
    var hasMoreData                        = true
    
    var isLoading    : Bool                { get { return _isLoading }         }
    var message      : String              { get { return _message   }         }
    var isFailed     : Bool                { get { return _isFailed  }         }
  

    
    //MARK: - APIs
    
//    func orders(skip: Int, status: String) {
//        if skip == 0 {_isLoading = true; hasMoreData = true }
//        guard hasMoreData  else { _isLoading = false ;return }
//        _isLoading = true
//        api.orders(skip: skip, status: status) { [weak self] (Result) in
//            guard let self = self else { return }
//            self._isLoading = false
//            switch Result {
//            case .success(let Result):
//                guard let data = Result?.data else { return }
//                if data.isEmpty {
//                    self.hasMoreData = false
//                } else {
//                    if skip == 0 {
//                        self._ordersList = data
//                    } else {
//                        self._ordersList.append(contentsOf: data)
//                    }
//                }
//                
//            case .failure(let error):
//                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
//                self._isFailed = true
//                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
//            }
//        }
//    }
   
}
