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
    @Published var transferToast: FancyToast? = nil
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
    @Published var _isPaymentSuccess       = false 
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
    @Published var userNameOfPhone: String = ""
    @Published var walletAmount : Double = 0
    @Published var isUserFound: Bool = false
    @Published var isTransferSuccess: Bool = false
    @Published var isTransferFailed: Bool = false

    @Published var transferData: ConfirmTransferData = ConfirmTransferData()

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
    func validateWithdrawAmount(amount: Double, accountName: String, iban: String, mobile: String, city: String) {
        // Get UDID
        guard let udid = UIDevice.current.identifierForVendor?.uuidString else {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "Device ID not found".localized())
            return
        }
        
       
        
        let amountInHalalas = Int(amount * 100)
        
        // Build request dictionary
        let dic: [String: Any] = [
            "source_id": "71b34f0e-c476-41c7-b16b-9701649320e0",
            "amount": amountInHalalas,
            "purpose": "personal",
            "destination": [
                "type": "bank",
                "iban": iban,
                "name": accountName,
                "mobile": mobile,
                "country": "SA",
                "city": city
            ]
        ]
        
        withdrawAmount(dic: dic)
    }

    func withdrawAmount(dic: [String: Any]) {
        self._isLoading = true
        api2.withDrawAmount(dic: dic) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                
                // Check transaction status
                if let transaction = data.transaction {
                    let status = transaction.status ?? ""
                    let message = transaction.message ?? data.message ?? ""
                    
                    if status == "initiated" {
                        // Success - payment initiated
                        self.toast = FancyToast(
                            type: .success,
                            title: "Success".localized(),
                            message: message
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self._isWithdrawSuccess = true
                            Constants.shouldNavigateToWallet = true
                            Constants.lastPayoutStatus = "done"
                        }
                    } else if status == "failed" {
                        // Failed transaction
                        let failureReason = transaction.failureReason ?? "Withdrawal failed".localized()
                        self.toast = FancyToast(
                            type: .error,
                            title: "Error".localized(),
                            message: failureReason
                        )
                    } else {
                        // Other statuses (pending, processing, etc.)
                        self.toast = FancyToast(
                            type: .info,
                            title: "Info".localized(),
                            message: message
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self._isWithdrawSuccess = true
                        }
                    }
                } else {
                    // No transaction data
                    self.toast = FancyToast(
                        type: .success,
                        title: "Success".localized(),
                        message: data.message ?? "Withdrawal request submitted".localized()
                    )
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self._isWithdrawSuccess = true
                    }
                }
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(
                    type: .error,
                    title: "Error".localized(),
                    message: self._message
                )
            }
        }
    }

    func addAmount(amount: Double, cardNumber: String, cardHolderName: String, month: String, year: String, cvv: String) {
        self._isLoading = true
        
        // Convert amount to halalas (multiply by 100)
        let amountInHalalas = Int(amount * 100)
        
        
        // Convert month to Int
        guard let monthInt = Int(month) else {
            self._isLoading = false
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "Invalid month".localized())
            return
        }
        
        // Build request dictionary
        let dic: [String: Any] = [
            "amount": amountInHalalas,
            "source": [
                "type": "card",
                "number": cardNumber.replacingOccurrences(of: " ", with: ""),
                "name": cardHolderName,
                "month": monthInt,
                "year": year,
                "cvc": cvv
            ]
        ]
        
        api2.addAmountToWallet(dic: dic) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                
                if data.success == true, let transactionUrl = data.transactionUrl {
                    self.paymentURL = transactionUrl
                    self._isPaymentSuccess = true
                } else {
                    self.toast = FancyToast(
                        type: .error,
                        title: "Error".localized(),
                        message: "Payment failed".localized()
                    )
                }
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(
                    type: .error,
                    title: "Error".localized(),
                    message: self._message
                )
            }
        }
    }
    
    func handleFindOfferByNum(code:String){
        if code == "" {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "offer_num_validation".localized())
        }
        else {
            _isLoading = true
            let api: OrdersAPIProtocolV3 = OrdersAPIV3()
            api.showDynamicLinks(code: code) { [weak self] (Result) in
                guard let self = self else { return }
                _isLoading = false
                switch Result {
                case .success(let response):
                    guard let data = response?.mapToShowOfferModel() else { return }
                    self._offerData = data.data
                    self.showOfferSuccess = true
                case .failure(_):
                        self.toast = FancyToast(type: .error, title: "Error".localized(), message: "order_not_found".localized())
                }
            }
        }
    }

    func validateTransferAmount(phone:String,amount: String) {
        if phone.isBlank {
            transferToast = FancyToast(type: .error, title: "Error".localized(), message: "enterPhone".localized())
        } else if !phone.isValidPhoneNumber {
            transferToast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidPhone".localized())
        } else if amount == "" {
            self.transferToast = FancyToast(type: .error, title: "Error".localized(), message: "amount_validation".localized())
            
        }else {
            checkPhoneNumber(phone: phone)
        }
    }
    
    func checkPhoneNumber(phone: String) {
        self._isLoading = true
        isUserFound = false
        api2.getNameFromPhone(phone: phone) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                userNameOfPhone = data.data ?? ""
                isUserFound = true
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.transferToast = FancyToast(type: .error, title: "Error".localized(), message: "userNotExist".localized())
            }
        }
    }
    
    
    
    func confirmTransfer(phone:String,amount:Double) {
        self._isLoading = true
        isUserFound = false
        api2.confirmTransfer(phone: phone, amount: amount) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result else { return }
                
                if data.status == true {
                    isTransferSuccess = true
                    isTransferFailed =  false
                    transferData = data.data ?? ConfirmTransferData()
                }else {
                    isTransferFailed =  true
                    isTransferSuccess = false
                    transferData = data.errors ?? ConfirmTransferData()
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                isTransferFailed =  true
                self.transferToast = FancyToast(type: .error, title: "Error".localized(), message: "userNotExist".localized())
            }
        }
    }
    
}

    

