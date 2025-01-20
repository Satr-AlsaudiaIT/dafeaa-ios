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
    @Published var _ordersList     : [OrdersData] = []//[OrdersData(id: 1, name: "ww", orderNo: 1, date: "2121", status: "1")]
    @Published var _ordersListCount     : Int = 1
    @Published private var _orderData      : OrderData? //= OrderData(id: 1, clientImage: "", clientName: "sss", products: [productList(id: 1, amount: 2, name: "sss", image: "", price: 100,offerPrice: 89,description: "eewew")], deliveryPrice: 100, orderStatus: 3, paymentStatus: 1, address: "wwww", qrCode: "qqqqq", taxPrice: 10, totalPrice: 1300, addressDetails: AddressDetails(id: 1, adress: "qqq", name: "qqq", phone: "111111"))
    @Published private var _offersList      : [OffersData] = []
    @Published private var _offersListCount :Int = 1

    @Published var _offersData      : ShowOfferData?
    @Published var productsListInCreateOrder: [[String:Any]] = []

    @Published var _getData                 : Bool = false
    @Published var _isSuccess               = false
    @Published var _isCompleteOrderSuccess  = false
    @Published var _isStatusChangedSuccess  = false
    @Published var _isAddProDuctValid       = false
    @Published var _isCreateOrderSuccess    = false

    private var _message                    : String = ""
    private var token                       = ""
    let api                                 : OrdersAPIProtocol = OrdersAPI()
    var hasMoreData                         = true

    var isLoading    : Bool                 { get { return _isLoading }         }
    var message      : String               { get { return _message   }         }
    var isFailed     : Bool                 { get { return _isFailed  }         }
    var ordersList   : [OrdersData]         { get {return _ordersList }  set {} }
    var orderData    : OrderData?           { get {return _orderData  }  set {} }
    var offersList   : [OffersData]         { get {return _offersList }  set {} }
    var offersData   : ShowOfferData?       { get {return _offersData }  set {} }

    func validations(dynamic_link_id:Int,address_id:Int,products:[[String:Any]]){
         if address_id == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"please choose address".localized())
        
        }else{
            createClientOrder(dic: ["dynamic_link_id":dynamic_link_id,"address_id":address_id,"products":products])
        }
    }
    //MARK: - APIs
    
    func orders(skip: Int, status: String,animated: Bool = true) {
        if skip == 0 {
             _isLoading = animated ; hasMoreData = true ;
            animated ? ( self._ordersList.removeAll()):()
        }
        else if self._ordersList.count >= self._ordersListCount {
            self.hasMoreData = false
        }
        guard hasMoreData  else { _isLoading = false ;return }
        api.orders(skip: skip, status: status) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                self._ordersListCount = Result?.count ?? 0
                    if skip == 0 {
                        self._ordersList = data
                    } else {
                        self._ordersList.append(contentsOf: data)
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
                self._isStatusChangedSuccess = false

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
                    GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                    MOLH.reset()
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
        if skip == 0 { hasMoreData = true ; self._offersList.removeAll()}
        if self._offersList.count >= self._offersListCount{
            self.hasMoreData = false
        }
        guard hasMoreData  else { _isLoading = false ;return }
        _isLoading = true
        api.offers(skip: skip) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                
                self._offersListCount = Result?.count ?? 0
                    if skip == 0 {
                        self._offersList = data
                    } else { self._offersList.append(contentsOf: data)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isSuccess = true
                    self._offersList.removeAll { $0.id == id }
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
    
    
    //MARK: - Create Link Requests
    func validateAddOrder(image: UIImage?, nameAr: String, nameEn: String, descriptionAr: String, descriptionEn: String, price: String, offerPrice: String) -> [String: Any]? {
        if image == nil {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "chooseProductImage".localized())
            return nil
        } else if nameAr.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterNameAr".localized())
            return nil
        } else if nameEn.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterNameEn".localized())
            return nil
        } else if descriptionAr.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterDescriptionAr".localized())
            return nil
        } else if descriptionEn.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterDescriptionEn".localized())
            return nil
        } else if price.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPrice".localized())
            return nil
        } else {
            var product: [String: Any] = [
                "image": image ?? UIImage(),
                "name_en": nameEn,
                "name_ar": nameAr,
                "description_en": descriptionEn,
                "description_ar": descriptionAr,
                "price": Double(price.convertDigitsToEng) ?? 0
            ]
            if !offerPrice.isBlank {
                product["offer_price"] = Double(offerPrice.convertDigitsToEng) ?? 0
            }

            self.toast = FancyToast(type: .success, title: "Success".localized(), message: "addProductSuccess".localized())
            self._isAddProDuctValid = true

            return product
        }
    }
    
    func validateAddOffer(offerName:String, offerDescription:String, deliveryPrice: String,tax:String, productsAdding: [[String: Any]]) {
        if offerName.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterOfferName".localized())
        }
        else if offerDescription.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterOfferDescription".localized())
        }
        else if deliveryPrice.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterDeliveryPrice".localized())
        }
        else if tax.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterTax".localized())
        }
        else if productsAdding.count == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"pleaseAddProducts".localized())
        }
        else {
            let param: [String:Any] = ["name": offerName,                                               "description": offerDescription,
                                       "delivery_price": Double(deliveryPrice.convertDigitsToEng) ?? 0,
                                       "tax_price": Double(tax.convertDigitsToEng) ?? 0]
            self.createOrderByMerchant(param: param, products: productsAdding)
        }
    }
   
    private func  createOrderByMerchant(param:[String:Any], products:[[String:Any]]){
        let params:[String:Any] = param
            self._isLoading = true
        let path :String = "links"
            
        MultipartUploadImageWithModel.shared.uploadOrderWithProduct(path: path, parameterS: params, products: products, responseClass: CreateOrderPostModel.self) {
                [weak self] (Result) in
                guard let self = self else {return}
                switch Result {
                case .success(let Result):
                    guard  let data = Result else {return}
                    self._isLoading = false
                    self._isFailed = false
                    self.toast = FancyToast(type: .success, title: "Success".localized(), message: data.message ?? "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self._isCreateOrderSuccess = true
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
