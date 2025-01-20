//
//  OrdersModel.swift
//
import Foundation


struct OrdersModel: Codable {
    let data: [OrdersData]?
    let message: String?
    let count: Int?
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
    let id                  : Int?
    let clientImage         : String?
    let clientName          : String?
    let orderStatus         : Int?
    let clientPhone         : String?
    let clientEmail         : String?
    let qrCode              : String?
    let name                : String?
    let products            : [productList]?
    let orderPrice          : Double?
    let deliveryPrice       : Double?
    let paymentStatus       : Int?
    let address             : String?
    let taxPrice            : Double?
    let totalPrice          : Double?
    let addressDetails      : AddressDetails?
    
}
struct productList: Codable, Identifiable,Equatable {
    let id                  : Int?
    let image               : String?
    let name, description   : String?
    let price               : Double?
    let amount              : Int?
    let offerPrice          : Double?
}

struct PaymentDetails: Codable {
    let tax     : Double?
    let deliveryPrice       : Double?
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
}

// MARK: - OffersModel
struct OffersModel: Codable {
    let status: Bool?
    let message: String?
    let data: [OffersData]?
    let count: Int?
}

// MARK: - OffersData
struct OffersData: Codable {
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
    let products                            : [productList]?
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
