//
//  HomeVM.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import SwiftUI

class HomeVM: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _processList    : [HomeModelData] = []
    @Published private var _homeData       : HomeModel?
    @Published private var _notifications  : [NotificationsData] = []
    @Published private var _notificationsCount  : Int = 1
    @Published private var _offerData     : ShowOfferData?
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    @Published var _isWithdrawSuccess      = false
    @Published var _addToWalletURL         : String = ""
    @Published var paymentURL              : String = ""
    @Published var showOfferSuccess       : Bool = false
    private var _message                   : String = ""
    private var token                      = ""
    let api                                : HomeAPIProtocol = HomeAPI()
    let api2                               : MoreAPIProtocol = MoreAPI()
    
    var hasMoreData                        = true
    var isLoading    : Bool                { get { return _isLoading  }      }
    var message      : String              { get { return _message    }      }
    var addToWalletURL : String            { get { return _addToWalletURL}   }
    var isFailed     : Bool                { get { return _isFailed   }      }
    var processList  : [HomeModelData]     { get { return _processList} set{}}
    var homeData     : HomeModel?          { get { return _homeData   } set{}}
    var notifications: [NotificationsData] { get { return _notifications} set{}}
    var offerData     : ShowOfferData?     { get { return _offerData} set{}}

    @Published var walletAmount : Double = 0
    //MARK: - APIs
    
    func home() {
        self._isLoading = true
        api.wallet(skip: 0) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                self.walletAmount = Double(Result?.availableBalance ?? 0)
    
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }

//        api.home() { [weak self] (Result) in
//            guard let self = self else {return}
//            switch Result {
//                
//            case .success(let Result):
//                self._isLoading = false
//                self._isFailed = false
//                guard let data = Result?.data else {return}
//                self._homeData = Result
//                self._processList = data
//                self.walletAmount = self._homeData?.availableBalance ?? 0
//            case .failure(let error):
//                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
//                self._isLoading = false
//                self._isFailed = true
//                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
//            }
//        }
    }
    
    func notificationsList(skip: Int) {
        if skip == 0 {_isLoading = true; hasMoreData = true }
        else if self._notifications.count >= self._notificationsCount {
            self.hasMoreData = false
        }
        guard hasMoreData  else { _isLoading = false ;return }
        api2.notificationsList(skip: skip) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                
                self._notificationsCount = Result?.count ?? 0
                    if skip == 0 {
                        self._notifications =   data
                    } else {
                        self._notifications.append(contentsOf: data)
                }
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func validateWithdrawAmount(amount: Double) {
//        if walletAmount > amount {
            withdrawAmount(amount: amount)
//        }
//        else {
//            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "notValidBalance".localized())
//        }
    }
    
    func withdrawAmount(amount: Double) {
        api2.withDrawAmount(amount: amount) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: data.message ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self._isWithdrawSuccess = true
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func addAmount(amount: Double) {
        self._isLoading = true
        api2.addAmountToWallet(amount: amount) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                paymentURL = data.data ?? ""
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func handleFindOfferByNum(code:String){
        if code == "" {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "offer_num_validation".localized())
        }
        else {
            _isLoading = true
            let api: OrdersAPIProtocol = OrdersAPI()
            api.showDynamicLinks(code: code) { [weak self] (Result) in
                guard let self = self else { return }
                _isLoading = false
                switch Result {
                case .success(let response):
                    guard let data = response?.data else { return }
                    self._offerData = data
                    self.showOfferSuccess = true
                case .failure(_):
                        self.toast = FancyToast(type: .error, title: "Error".localized(), message: "order_not_found".localized())
                    
                }
            }
        }
    }

    
}

    

