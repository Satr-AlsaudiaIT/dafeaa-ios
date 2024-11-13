//
//  WalletVM.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import SwiftUI

class WalletVM: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _processList    : [HomeModelData] = []
    @Published private var _walletData       : WalletModel?
    
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    private var _message                   : String = ""
    private var token                      = ""
    let api                                : HomeAPIProtocol = HomeAPI()
    var hasMoreData                        = true
    var isLoading    : Bool                { get { return _isLoading  }      }
    var message      : String              { get { return _message    }      }
    var isFailed     : Bool                { get { return _isFailed   }      }
    var processList  : [HomeModelData]     { get { return _processList} set{}}
    var walletData   : WalletModel?        { get { return _walletData   } set{}}
    
    //MARK: - APIs
    
    func wallet(skip: Int) {
        if skip == 0 { hasMoreData = true }
        guard hasMoreData  else { _isLoading = false ;return }
        _isLoading = true
        api.wallet(skip: skip) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                self._walletData = Result
                if self._processList.count >= Result?.count ?? 0 {
                    self.hasMoreData = false
                } else {
                    if skip == 0 {
                        self._processList = data
                    } else { self._processList.append(contentsOf: data)
                    }
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
}



