//
//  OrdersModel.swift
//
import Foundation


struct OrdersModel: Codable {
    let data: [OrdersData]?
    let message: String?
    let count: Int?
    let outstandingBalance: Double?
}

struct OrdersData: Codable, Identifiable {
    let id: Int?
    let name, userName, userImage: String?
    let orderStatus, isTransformed: Int?
    let createdAt, time: String?
    let type: Int?
}



struct OrderModel: Codable {
    let data                : OrderData?
    let message             : String?
}

struct OrderData: Codable, Identifiable {
    let id: Int?
    let clientImage: String?
    let clientName: String?
    let orderStatus: Int?
    let clientPhone: String?
    let clientEmail: String?
    let qrCode: String?
    let name: String?
    let products: [productList]?
   
    let paymentStatus: Int?
    let address: String?
    let addressDetails: AddressDetails?
    let commissionRatio: String?
    let maxCommissionValue: String?
    let taxPrice: Double?
    let commissionValue: Double?
    let orderPrice: Double?
    let deliveryPrice: Double?
    let totalPrice: Double?
    let streetName: String?
    let buildingNum: String?
    let area: String?
    let floatNum: String?
    // Custom initializer with default nil values
    init(
        id: Int? = nil,
        clientImage: String? = nil,
        clientName: String? = nil,
        orderStatus: Int? = nil,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        qrCode: String? = nil,
        name: String? = nil,
        products: [productList]? = nil,
        orderPrice: Double? = nil,
        deliveryPrice: Double? = nil,
        commissionValue: Double? = nil,
        paymentStatus: Int? = nil,
        address: String? = nil,
        taxPrice: Double? = nil,
        totalPrice: Double? = nil,
        addressDetails: AddressDetails? = nil,
        commissionRatio: String? = nil,
        maxCommissionValue: String? = nil,
         streetName: String? = nil,
         buildingNum: String? = nil,
         area: String? = nil,
         floatNum: String? = nil
    ) {
        self.id = id
        self.clientImage = clientImage
        self.clientName = clientName
        self.orderStatus = orderStatus
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.qrCode = qrCode
        self.name = name
        self.products = products
        self.orderPrice = orderPrice
        self.deliveryPrice = deliveryPrice
        self.paymentStatus = paymentStatus
        self.address = address
        self.taxPrice = taxPrice
        self.totalPrice = totalPrice
        self.addressDetails = addressDetails
        self.commissionRatio = commissionRatio
        self.maxCommissionValue = maxCommissionValue
        self.streetName = streetName
        self.buildingNum = buildingNum
        self.area = area
        self.floatNum = floatNum
        self.commissionValue = commissionValue
    }
}

struct productList: Codable, Identifiable,Equatable {
    let id                  : Int?
    let images              : [ImageModel]?
    let name, description   : String?
    let price               : Double?
    let amount              : Int?
    let offerPrice          : Double?
    let totalQuantity       : Int?
    let paiedQuantity       : Int?
    var remainingQuantity   : Int?
}

struct ImageModel : Codable, Equatable {
    var file: String?
}

struct PaymentDetails: Codable {
    let commission           : Double?
    let commissionMaxPrice   : Double?
}

struct AddressDetails: Codable {
    let id                  : Int?
    let adress              : String?
    let name,phone          : String?
    let countryId           : Int?
    let countryName         : String?
    let cityId              : Int?
    let city                : String?
    let districtName        : String?
    let streetName          : String?
    let lat                 : String?
    let lng                 : String?
}


// MARK: - OrdersModelV3
struct OrdersModelV3: Codable {
    let status: Bool?
    let message: String?
    let data: OrdersDataV3?
}

// MARK: - OrdersDataV3
struct OrdersDataV3: Codable {
    let id: Int?
    let name, userName, userImage: String?
    let orderStatus, isTransformed: Int?
    let createdAt, time: String?
    let type: Int?
    let userPhone, userEmail: String?
    let paymentStatus: Int?
    let qrCode: String?
    let countryId: Int?
    let countryName: String?
    let cityId: Int?
    let city, districtName, streetName, address: String?
    let lat, lng: String?
    let orderPrice, deliveryPrice, commission: Double?
    let totalPrice: Double?
    let products: [productList]?
}






struct LinkDetailsClient: Codable {
    let id                                  : Int?
    let name, code, description             : String?
    let clientId                            : Int?
    let deliveryPrice, taxPrice             : Double?
    let products                            : [productList]?
    let commissionRatio                     : String?
    let maxCommissionValue                  : String?
}

// MARK: - OffersModel
struct OffersModel: Codable {
    let status: Bool?
    let message: String?
    let data: [OffersData]?
    let count: Int?
}

// MARK: - OffersData
struct OffersData: Codable,Equatable, Identifiable{
    let id: Int?
    let name, code, description: String?
    let status: Int?
}

struct CreateOfferModel: Codable {
    let status: Bool?
    let message: String?
    let data : CreateOfferData?
}

struct CreateOfferData: Codable {
    let orderId: Int?
}




//To do v2 if needed
// MARK: - ShowOfferModel
struct ShowOfferModel: Codable {
    let status: Bool?
    let message: String?
    let data: ShowOfferData?
}

// MARK: - ShowOfferData
struct ShowOfferData: Codable, Equatable {
    let id                                  : Int?
    let name, code, description             : String?
    let clientId                            : Int?
    let deliveryPrice, taxPrice             : Double?
    var products                            : [productList]?
    var status                              : Int?
    let commissionRatio                     : String?
    let maxCommissionValue                  : String?
}

// MARK: - ShowOfferModelV3
struct ShowOfferModelV3: Codable {
    let status: Bool?
    let message: String?
    let data: ShowOfferDataV3?
}

// MARK: - ShowOfferDataV3
struct ShowOfferDataV3: Codable {
    let id: Int?
    let name, code: String?
    var status: Int?
    let description: String?
    let clientId: Int?
    let offerPrice, price: Double?
    let images: [ImageModel]?
    let commissionRatio, maxCommissionValue: String?

}








// MARK: - Product
struct Product: Codable {
    let id: Int?
    let image: String?
    let name, description: String?
    let price: Int?
    let offerPrice: Int?
}



// MARK: - CreateOrderPostModel
struct CreateOrderPostModel: Codable {
    let id: Int?
    let message: String?
    let name, code, description: String?
}



