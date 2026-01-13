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

    let countryCode: String?
    let cityName: String?
    let postalCode: String?
    let provinceCode: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case clientImage = "client_image"
        case clientName = "client_name"
        case orderStatus = "order_status"
        case clientPhone = "client_phone"
        case clientEmail = "client_email"
        case qrCode = "qr_code"
        case name = "name"
        case products = "products"
        case paymentStatus = "payment_status"
        case address = "address"
        case commissionRatio = "commission_ratio"
        case maxCommissionValue = "max_commission_value"
        case taxPrice = "tax_price"
        case commissionValue = "commission_value"
        case orderPrice = "order_price"
        case deliveryPrice = "delivery_price"
        case totalPrice = "total_price"
        case streetName = "street_name"
        case buildingNum = "building_num"
        case area = "area"
        case floatNum = "float_num"
        case countryCode = "countryCode"
        case cityName = "cityName"
        case postalCode = "postalCode"
        case provinceCode = "provinceCode"
    }

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
        commissionRatio: String? = nil,
        maxCommissionValue: String? = nil,
        streetName: String? = nil,
        buildingNum: String? = nil,
        area: String? = nil,
        floatNum: String? = nil,
        countryCode: String? = nil,
        cityName: String? = nil,
        postalCode: String? = nil,
        provinceCode: String? = nil
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
        self.commissionValue = commissionValue
        self.paymentStatus = paymentStatus
        self.address = address
        self.taxPrice = taxPrice
        self.totalPrice = totalPrice
        self.commissionRatio = commissionRatio
        self.maxCommissionValue = maxCommissionValue
        self.streetName = streetName
        self.buildingNum = buildingNum
        self.area = area
        self.floatNum = floatNum
        self.countryCode = countryCode
        self.cityName = cityName
        self.postalCode = postalCode
        self.provinceCode = provinceCode
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
    let address             : String?
    let name,phone          : String?
    let countryCode         : String?
    let cityName            : String?
    let postalCode          : String?
    let provinceCode        : String?
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
    let countryCode: String?
    let cityId: Int?
    let cityName, postalCode, provinceCode, address: String?
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
    let shippingCompanies                   : [String]?
    let address                             : AddressModel?
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


// MARK: - ShowOfferModelV3
struct ShowOfferModelV3: Codable {
    let status: Bool?
    let message: String?
    let data: ShowOfferDataV3?
}

// MARK: - AddressModel
struct AddressModel: Codable, Equatable {
    let id: Int?
    let countryId: Int?
    let countryName: String?
    let cityId: Int?
    let cityName: String?
    let districtName: String?
    let streetName: String?
    let address: String?
    let lat: Double?
    let lng: Double?
}

// MARK: - ShowOfferDataV3
struct ShowOfferDataV3: Codable {
    let id: Int?
    let name, code: String?
    var status: Int?
    let description: String?
    let productId: Int?
    let clientId: Int?
    let price: Double?
    let offerPrice: Double?
    let width, height, length, weight: Double?
    let plannedShippingDateAndTime: Int?
    let shippingCompanies: [String]?
    let images: [ImageModel]?
    let commissionRatio, maxCommissionValue: String?
    let commission: Double?
    let vatRatio: String?
    let vatValue: Double?
    let totalCommissionWithVat: Double?
    let address: AddressModel?
}

// MARK: - Updated Mapping Function
extension ShowOfferModelV3 {
    func mapToShowOfferModel() -> ShowOfferModel? {
        guard let v3Data = data else { return nil }
        
        // Create a single product from V3 data
        let product = productList(
            id: v3Data.productId,
            images: v3Data.images,
            name: v3Data.name,
            description: v3Data.description,
            price: v3Data.price,
            amount: nil,
            offerPrice: v3Data.offerPrice,
            totalQuantity: nil,
            paiedQuantity: nil,
            remainingQuantity: nil
        )
        
        let showOfferData = ShowOfferData(
            id: v3Data.id,
            name: v3Data.name,
            code: v3Data.code,
            description: v3Data.description,
            clientId: v3Data.clientId,
            deliveryPrice: nil,
            taxPrice: v3Data.vatValue,
            products: [product],
            status: v3Data.status,
            commissionRatio: v3Data.commissionRatio,
            maxCommissionValue: v3Data.maxCommissionValue,
            shippingCompanies: v3Data.shippingCompanies,
            address: v3Data.address
        )
        
        return ShowOfferModel(
            status: status,
            message: message,
            data: showOfferData
        )
    }
    
    
    
}


// MARK: - ShippingRatesModel
struct ShippingRatesModel: Codable {
    let status: Bool?
    let message: String?
    let data: ShippingRatesData?
}

// MARK: - ShippingRatesData
struct ShippingRatesData: Codable {
    let currencyType, priceCurrency: String?
    let price: Double?
}
