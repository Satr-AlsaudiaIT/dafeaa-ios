//
//  OrdersVM.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import Foundation
import UIKit

final class OrdersVM : ObservableObject {
    
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _ordersList     : [OrdersData] = []//[OrdersData(id: 1, name: "ww", orderNo: 1, date: "2121", status: "1")]
    @Published private var _orderData      : OrderData? //= OrderData(id: 1, clientImage: "", clientName: "sss", products: [productList(id: 1, amount: 2, name: "sss", image: "", price: 100,offerPrice: 89,description: "eewew")], deliveryPrice: 100, orderStatus: 3, paymentStatus: 1, address: "wwww", qrCode: "qqqqq", taxPrice: 10, totalPrice: 1300, addressDetails: AddressDetails(id: 1, adress: "qqq", name: "qqq", phone: "111111"))
    @Published private var _offersList     : [OffersData] = []
    @Published private var _offersData     : ShowOfferData?
    
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    @Published var _isCompleteOrderSuccess = false
    @Published var _isStatusChangedSuccess = false

    private var _message                   : String = ""
    private var token                      = ""
    let api                                : OrdersAPIProtocol = OrdersAPI()
    var hasMoreData                        = true

    var isLoading    : Bool                { get { return _isLoading }         }
    var message      : String              { get { return _message   }         }
    var isFailed     : Bool                { get { return _isFailed  }         }
    var ordersList   : [OrdersData]        { get {return _ordersList }  set {} }
    var orderData    : OrderData?          { get {return _orderData  }  set {} }
    var offersList   : [OffersData]        { get {return _offersList }  set {} }
    var offersData   : ShowOfferData?      { get {return _offersData }  set {} }

    func validations(dynamic_link_id:Int,address_id:Int,products:[[String:Any]]){
        if dynamic_link_id == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"please choose dynamic link".localized())

        }else if address_id == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"please choose address".localized())

        }else if products.isEmpty {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"please choose products".localized())

        }else{
            createClientOrder(dic: ["dynamic_link_id":dynamic_link_id,"address_id":address_id,"products":products])
        }
    }
    //MARK: - APIs
    
    func orders(skip: Int, status: String) {
        if skip == 0 {_isLoading = true; hasMoreData = true }
        guard hasMoreData  else { _isLoading = false ;return }
        _isLoading = true
        api.orders(skip: skip, status: status) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                if data.isEmpty {
                    self.hasMoreData = false
                } else {
                    if skip == 0 {
                        self._ordersList = data
                    } else {
                        self._ordersList.append(contentsOf: data)
                    }
                }
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func resetData() {
        _ordersList.removeAll()
        hasMoreData = true
    }
    
    func getOrder(id : Int) {
        self._isLoading = true
        api.getOrder(id: id) { [weak self] (Result) in
            guard let self = self else {return}
            switch Result {
                
            case .success(let Result):
                self._isLoading = false
                self._isFailed = false
                guard let data = Result?.data else {return}
                self._orderData = data
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func changeOrderStatus(id : Int,status:Int) {
        self._isLoading = true
        api.changeOrderStatus(id: id, status: status) { [weak self] (Result) in
            guard let self = self else {return}
            switch Result {
                
            case .success(_):
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: "statusChanges".localized())
                self._isStatusChangedSuccess = true
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }

    func completeOrder(id : Int, qrCode: String) {
        self._isLoading = true
        api.completeOrder(id: id, qrCode: qrCode) { [weak self] (Result) in
            guard let self = self else {return}
            switch Result {
                
            case .success(_):
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: "completeSuccessful".localized())
                self._isCompleteOrderSuccess = true
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func createClientOrder(dic:[String:Any]) {
        _isLoading = true
        api.createClientOrder(dic: dic) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self._isSuccess = true
                }
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
//merchentOffers
    func offers(skip: Int) {
        if skip == 0 { hasMoreData = true }
        guard hasMoreData  else { _isLoading = false ;return }
        _isLoading = true
        api.offers(skip: skip) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                if data.isEmpty {
                    self.hasMoreData = false
                } else {
                    if skip == 0 {
                        self._offersList = data
                    } else { self._offersList.append(contentsOf: data)
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

    func createOffer() {
        _isLoading = true
        api.createDynamicLinks(dic: [:]) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                }
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func deleteOffer(id: Int) {
        _isLoading = true
        api.deleteDynamicLinks(id: id) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                }
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func showOffer(id:Int) {
        _isLoading = true
        api.showDynamicLinks(id: id) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                guard let data = response?.data else { return }
                self._isLoading = false
                self._isFailed = false
                self._offersData = data
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }


}
