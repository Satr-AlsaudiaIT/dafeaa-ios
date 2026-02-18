//
//  OrdersVM.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import Foundation
import UIKit

final class OrdersVM : ObservableObject {
    @Published var activeStopSuccess: Bool = false
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published var isUpdateQuantitySuccess   = false
    @Published var isOrderSuccess   = false
    @Published var orderId : Int?  = nil

    
    @Published var _ordersList     : [OrdersData] = []//[OrdersData(id: 1, name: "ww", orderNo: 1, date: "2121", status: "1")]
    @Published var _ordersListCount     : Int = 1
    @Published var outStandingBalance     : Double = 0

    @Published private var _orderData      : OrderData? //= OrderData(id: 1, clientImage: "", clientName: "sss", products: [productList(id: 1, amount: 2, name: "sss", image: "", price: 100,offerPrice: 89,description: "eewew")], deliveryPrice: 100, orderStatus: 3, paymentStatus: 1, address: "wwww", qrCode: "qqqqq", taxPrice: 10, totalPrice: 1300, addressDetails: AddressDetails(id: 1, adress: "qqq", name: "qqq", phone: "111111"))
    @Published var _offersList      : [OffersData] = []
    @Published private var _offersListCount :Int = 1

    @Published var offersData      : ShowOfferData?
    @Published var offersDataV3      : ShowOfferDataV3?
    @Published var productsListInCreateOrder: [[String:Any]] = []

    @Published var _getData                 : Bool = false
    @Published var _isSuccess               = false
    @Published var _isCompleteOrderSuccess  = false
    @Published var _isStatusChangedSuccess  = false
    @Published var _isAddProDuctValid       = false
    @Published var _isCreateOrderSuccess    = false
    @Published var shippingRatePrice: Double = 0

    private var _message                    : String = ""
    private var token                       = ""
    let api                                 : OrdersAPIProtocol = OrdersAPI()
    let apiV3                               : OrdersAPIProtocolV3 = OrdersAPIV3()
    var hasMoreData                         = true

    var isLoading    : Bool                 { get { return _isLoading }         }
    var message      : String               { get { return _message   }         }
    var isFailed     : Bool                 { get { return _isFailed  }         }
    var ordersList   : [OrdersData]         { get {return _ordersList }  set {} }
    var orderData    : OrderData?           { get {return _orderData  }  set {} }
    var offersList   : [OffersData]         { get {return _offersList }  set {} }
//    var offersData   : ShowOfferData?       { get {return _offersData }  set {} }

    // Add this property to OrdersVM class
    @Published var mockTrackingEvents: [TrackingEvent] = [
        TrackingEvent(
            date: "2026-01-18",
            time: "12:51:57",
            typeCode: "PU",
            description: "Shipment picked up",
            serviceArea: [TrackingEvent.ServiceArea(code: "CAN", description: "Guangzhou-CN")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-18",
            time: "18:11:01",
            typeCode: "AF",
            description: "Arrived at DHL Sort Facility  GUANGZHOU,AP-CHINA, PEOPLES REPUBLIC",
            serviceArea: [TrackingEvent.ServiceArea(code: "CAN", description: "Guangzhou-CN")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-19",
            time: "01:15:59",
            typeCode: "PL",
            description: "Processed at HONG KONG-HONG KONG SAR, CHINA",
            serviceArea: [TrackingEvent.ServiceArea(code: "HKG", description: "Hong Kong-HK")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-19",
            time: "21:43:26",
            typeCode: "PL",
            description: "Processed at HONG KONG-HONG KONG SAR, CHINA",
            serviceArea: [TrackingEvent.ServiceArea(code: "HKG", description: "Hong Kong-HK")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-20",
            time: "12:19:59",
            typeCode: "WC",
            description: "Shipment is out with courier for delivery",
            serviceArea: [TrackingEvent.ServiceArea(code: "YHM", description: "Brampton-CA")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-20",
            time: "13:14:49",
            typeCode: "OK",
            description: "Delivered",
            serviceArea: [TrackingEvent.ServiceArea(code: "YHM", description: "Brampton-CA")],
            signedBy: ""
        )
    ]

    
    func validations(dynamicLinkId:Int,addressId:Int,products:[[String:Any]]){
         if addressId == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"please choose address".localized())
        
        }else{
//            //to do v2
//            createClientOrder(dic: ["dynamic_link_id":dynamicLinkId,"address_id":addressId,"products":products])
            
            //to do v3
            createClientOrder(dic: ["dynamic_link_id":dynamicLinkId,"address_id":addressId])
        }
    }
    
    
    //MARK: - APIs
    func orders(skip: Int, status: String,type:String, animated: Bool = true) {
        if skip == 0 {
             _isLoading = animated ; hasMoreData = true ;
            animated ? ( self._ordersList.removeAll()):()
        }
        else if self._ordersList.count >= self._ordersListCount {
            self.hasMoreData = false
        }
        guard hasMoreData  else { _isLoading = false ;return }
        apiV3.orders(skip: skip, status: status,type: type) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                self._ordersListCount = Result?.count ?? 0
                self.outStandingBalance = Result?.outstandingBalance ?? 0
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
        apiV3.getOrder(id: id) { [weak self] (Result) in
            guard let self = self else {return}
            switch Result {
                
            case .success(let Result):
                self._isLoading = false
                self._isFailed = false
                guard let result = Result else {return}
                let convertedOrder = convertOrdersModelV3ToOrderModel(result)
                self._orderData = convertedOrder.data
                self._isStatusChangedSuccess = false

            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func convertOrdersModelV3ToOrderModel(_ ordersModelV3: OrdersModelV3) -> OrderModel {
        let orderData = OrderData(
            id: ordersModelV3.data?.id,
            clientImage: ordersModelV3.data?.userImage,
            clientName: ordersModelV3.data?.userName,
            orderStatus: ordersModelV3.data?.orderStatus,
            clientPhone: ordersModelV3.data?.userPhone,
            clientEmail: ordersModelV3.data?.userEmail,
            qrCode: ordersModelV3.data?.qrCode,
            name: ordersModelV3.data?.name,
            products: ordersModelV3.data?.products,
            orderPrice: ordersModelV3.data?.orderPrice,
            deliveryPrice: Double(ordersModelV3.data?.deliveryPrice ?? 0),
            commissionValue: ordersModelV3.data?.commission ?? 0,
            paymentStatus: ordersModelV3.data?.paymentStatus,
            address: ordersModelV3.data?.address,
            
            taxPrice: nil,
            totalPrice: Double(ordersModelV3.data?.totalPrice ?? 0),
            
            commissionRatio: nil,
            maxCommissionValue: nil,
            streetName: nil,
            buildingNum: nil,
            area: nil,
            floatNum: nil,
            countryCode: ordersModelV3.data?.countryCode,
            cityName: ordersModelV3.data?.cityName, postalCode: ordersModelV3.data?.postalCode,
            provinceCode: ordersModelV3.data?.provinceCode,
            totalVatWithCommission: ordersModelV3.data?.totalCommissionWithVat ?? 0
        )
        
        return OrderModel(
            data: orderData,
            message: ordersModelV3.message
        )
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
        apiV3.createClientOrder(dic: dic) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)

                self.orderId = response?.data?.orderId ?? 0
                self.isOrderSuccess = true
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
        print("Deleting offer with ID: \(id)")
        print("Current offers list before deletion: \(_offersList)")
        
        api.deleteDynamicLinks(id: id) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                
                // Ensure the removal happens on the main thread
                DispatchQueue.main.async {
                    print("Removing offer with ID: \(id)")
                    self._offersList.removeAll { $0.id == id }
                    print("Current offers list after deletion: \(self._offersList)")
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

    func stopActivateOffer(code: String,status:Int) {
        _isLoading = true
        api.activateStopLink(code: code, status: status) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: status == 1 ? "active_message".localized() : "stop_message".localized())
                self.activeStopSuccess.toggle()
                self.offersData?.status = status
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func updateQuantity(productId: Int,quantity:Int) {
        _isLoading = true
        api.updateQuantity(productId: productId, quantity: quantity) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                isUpdateQuantitySuccess = true 
                self.toast = FancyToast(type: .success, title: "success".localized(), message: self._message)
                
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }

    
    func showOffer(code:String) {
        _isLoading = true
        apiV3.showDynamicLinks(code: code) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let response):
                guard let response = response else { return }
        //to do if needed to return to v2 remove this and return self.offersData = data
                if let mappedModel = response.mapToShowOfferModel() {
                self._isLoading = false
                self._isFailed = false
                self.offersData = mappedModel.data
                }
//                self.offersData = data
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }

    
    //MARK: - Create Link Requests
    func validateAddOrderOLD(images: [UIImage]?, name: String, description: String, quantity:String, price: String, offerPrice: String, haveOffer: Bool) -> [String: Any]? {
        if name.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterName".localized())
            return nil
        }
       
        else if description.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterDescription".localized())
            return nil
        }
     
        else if quantity.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterQuantity".localized())
            return nil
        }
        else if price.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPrice".localized())
            return nil
        }else if haveOffer ,offerPrice.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterOfferPrice".localized())
            return nil
        } else if haveOffer ,!offerPrice.isBlank ,(Double(offerPrice) ?? 0) > (Double(price) ?? 0 ) {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "offerPriceMustBeLessThanPrice".localized())
            return nil
        }
        else if images?.count  ?? 0 == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "chooseProductImage".localized())
            return nil
        }
        else {
            var product: [String: Any] = [
                "images": images,
                "name": name,
                "description": description,
                "price": Double(price.convertDigitsToEng) ?? 0,
                "quantity": Int(quantity.convertDigitsToEng) ?? 0
            ]
            if haveOffer, !offerPrice.isBlank {
                product["offer_price"] = Double(offerPrice.convertDigitsToEng) ?? 0
            }
            
            self.toast = FancyToast(type: .success, title: "Success".localized(), message: "addProductSuccess".localized())
            self._isAddProDuctValid = true

            return product
        }
    }
    
//    func validateCreateOfferLinkOld(offerName:String, offerDescription:String, productsAdding: [[String: Any]]) {
//        if offerName.isBlank {
//            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterOfferName".localized())
//        }
//        else if offerDescription.isBlank {
//            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"enterOfferDescription".localized())
//        }
//
//        else if productsAdding.count == 0 {
//            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"pleaseAddProducts".localized())
//        }
//        else {
//            let param: [String:Any] = ["name": offerName,                                               "description": offerDescription]
//            self.createOrderLinkByMerchant(param: param, products: productsAdding)
//        }
//    }

    
    //MARK: - NEw add order
    func validateAddOrderNew(images: [UIImage]?, name: String, descriptionAttributed: NSAttributedString, quantity:String, price: String, offerPrice: String, haveOffer: Bool) -> [String: Any]? {
        let plainDescription = descriptionAttributed.string

        if name.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterName".localized())
            return nil
        }
       
        else if plainDescription.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterDescription".localized())
            return nil
        }
     
        else if price.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPrice".localized())
            return nil
        }else if haveOffer ,offerPrice.isBlank {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "enterOfferPrice".localized())
            return nil
        } else if haveOffer ,!offerPrice.isBlank ,(Double(offerPrice) ?? 0) > (Double(price) ?? 0 ) {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "offerPriceMustBeLessThanPrice".localized())
            return nil
        }
        else if images?.count  ?? 0 == 0 {
            self.toast = FancyToast(type: .error, title: "Error".localized(), message: "chooseProductImage".localized())
            return nil
        }
        else {

            let htmlDescription = (try? descriptionAttributed.data(
                from: NSRange(location: 0, length: descriptionAttributed.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )).flatMap { String(data: $0, encoding: .utf8) } ?? plainDescription
            
            var product: [String: Any] = [
                "images": images,
                "name": name,
                "description": htmlDescription,
                "price": Double(price.convertDigitsToEng) ?? 0,
                "quantity": 1
            ]
            if haveOffer, !offerPrice.isBlank {
                product["offer_price"] = Double(offerPrice.convertDigitsToEng) ?? 0
            }
            
            self._isAddProDuctValid = true

            return product
        }
    }
    
    func validateCreateOfferLinkV3(
        name: String,
        descriptionAttributed: NSAttributedString,
        price: String,
        offerPrice: String,
        haveOfferPrice: Bool,
        images: [UIImage],
        weight: String,
        length: String,
        width: String,
        height: String,
        shippingCompanies: [ShippingCompany],
        plannedShippingDateAndTime: String
    )  {

        let plainDescription = descriptionAttributed.string.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_offer_name".localized())
            return
        }

        if plainDescription.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_offer_description".localized())
            return
        }

        if price.isBlank || (Double(price.convertDigitsToEng) ?? 0) <= 0 {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_offer_price".localized())
            return
        }

        if haveOfferPrice {
            if offerPrice.isBlank || (Double(price.convertDigitsToEng) ?? 0) <= 0 {
                toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_offer_discount_price".localized())
                return
            }
        }
        
        if images.isEmpty {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_offer_images".localized())
            return
        }

        if weight.isBlank { toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_weight".localized()); return  }
        if length.isBlank { toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_length".localized()); return  }
        if width.isBlank  { toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_width".localized()); return  }
        if height.isBlank { toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_height".localized()); return  }

        if shippingCompanies.isEmpty {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_shipping_companies".localized())
            return
        }

        if plannedShippingDateAndTime.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "validation_planned_shipping".localized())
            return
        }

        // Convert rich text to HTML with proper UTF-8 encoding
        let htmlDescription = descriptionAttributed.toHTML()

        // Debug: Check what attributes exist
        descriptionAttributed.enumerateAttributes(in: NSRange(location: 0, length: descriptionAttributed.length), options: []) { attributes, range, _ in
            print("📋 Attributes at range \(range): \(attributes)")
        }

        
        var params: [String: Any] = [
            "name": name,
            "description": htmlDescription,
            "price": Double(price.convertDigitsToEng) ?? 0,
            "weight": weight.convertDigitsToEng,
            "length": length.convertDigitsToEng,
            "width": width.convertDigitsToEng,
            "height": height.convertDigitsToEng,
            "planned_shipping_date_and_time": plannedShippingDateAndTime.convertDigitsToEng
        ]
        
        if haveOfferPrice {
            params.updateValue(Double(offerPrice.convertDigitsToEng) ?? 0, forKey: "offer_price")
        }
        self.createOrderLinkByMerchant(param: params, selectedImages: images, selectedShippingCompanies: shippingCompanies)
    }

    

    
    private func  createOrderLinkByMerchant(param:[String:Any], selectedImages:[UIImage], selectedShippingCompanies: [ShippingCompany]){
        let params:[String:Any] = param
            self._isLoading = true
        let path :String = "links"
       

        MultipartUploadImageWithModel.shared.uploadOfferLinkV3(
            path: path,
            parameterS: params,
            images: selectedImages,
            shippingCompanies: selectedShippingCompanies.map(\.rawValue),
            responseClass: CreateOrderPostModel.self
        ) { result in
            switch result {
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
    
    // to do v3
//    func validateCreateOfferLinkNewV3(offerName:String, offerDescription:String, productsAdding: [[String: Any]]) {
//        if productsAdding.count == 0 {
//            self.toast = FancyToast(type: .error, title: "Error".localized(), message:"pleaseAddProducts".localized())
//        }
//        else {
//            let param: [String:Any] = ["name": offerName,                                               "description": offerDescription,
//                                       "price": productsAdding[0]["price"] ?? 0]
//            self.createOrderLinkByMerchant(param: param, products: productsAdding)
//        }
//    }
    
    private func  createOrderLinkByMerchantV3(param:[String:Any], products:[[String:Any]]){
        let params:[String:Any] = param
            self._isLoading = true
        let path :String = "v3/links"
            
        MultipartUploadImageWithModel.shared.uploadImage(path: path, pdfUrl: [:], parameterS: params, photos: ["images":products[0]["images"] as? UIImage ?? UIImage()] , responseClass: CreateOrderPostModel.self) {
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
    
    
    func getShippingRates(company: String,for productId: Int,/*from shipperAddressId: Int,*/ to receiverAddressId: Int ){
        
        let param : [String:Any] = ["product_id":productId,
//                                    "shipper_address_id":shipperAddressId,
                                    "receiver_address_id":receiverAddressId]
        apiV3.shippingRates(company: company, params: param) { result in
            switch result {
            case .success(let Result):
                guard  let data = Result else {return}
                self._isLoading = false
                self._isFailed = false
                self.shippingRatePrice = data.data?.price ?? 0
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.shippingRatePrice =  0
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
                
            }
        }
    }
}
