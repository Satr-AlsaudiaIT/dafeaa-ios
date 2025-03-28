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
    let id                  : Int?
    let name                : String?
    let orderStatus             : Int?
    let date                : String?
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
    let orderPrice: Double?
    let deliveryPrice: Double?
    let paymentStatus: Int?
    let address: String?
    let taxPrice: Double?
    let totalPrice: Double?
    let addressDetails: AddressDetails?
    let commissionRatio: String?
    let maxCommissionValue: String?
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
        paymentStatus: Int? = nil,
        address: String? = nil,
        taxPrice: Double? = nil,
        totalPrice: Double? = nil,
        addressDetails: AddressDetails? = nil,
        commissionRatio: String? = nil,
        maxCommissionValue: String? = nil
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
    }
}

struct productList: Codable, Identifiable,Equatable {
    let id                  : Int?
    let image               : String?
    let name, description   : String?
    let price               : Double?
    let amount              : Int?
    let offerPrice          : Double?
    let totalQuantity       : Int?
    let paiedQuantity       : Int?
    var remainingQuantity   : Int?
}

struct PaymentDetails: Codable {
    let commission           : Double?
    let commissionMaxPrice   : Double?
}
struct AddressDetails: Codable {
    let id                  : Int?
    let adress              : String?
    let name,phone          : String?
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
}

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
