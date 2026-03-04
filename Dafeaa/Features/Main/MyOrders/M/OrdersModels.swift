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
    let totalVatWithCommission: Double?
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
        case totalVatWithCommission = "total_commission_with_vat"
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
        provinceCode: String? = nil,
        totalVatWithCommission : Double? = nil
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
        self.totalVatWithCommission = totalVatWithCommission
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
    let totalCommissionWithVat: Double?
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
    // V3 additions
    let shipmentFree                        : Int?
    let hasTaxRecord                        : Int?
    let priceCommission                     : PriceCommissionV3?
    let shippingCommission                  : ShippingCommissionV3?
    let seller                              : SellerV3?
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


//// MARK: - ShowOfferModelV3
//struct ShowOfferModelV3: Codable {
//    let status: Bool?
//    let message: String?
//    let data: ShowOfferDataV3?
//}
//
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
    let lat: String?
    let lng: String?
}
//
//// MARK: - ShowOfferDataV3
//struct ShowOfferDataV3: Codable {
//    let id: Int?
//    let name, code: String?
//    var status: Int?
//    let description: String?
//    let productId: Int?
//    let clientId: Int?
//    let price: Double?
//    let offerPrice: Double?
//    let width, height, length, weight: Double?
//    let plannedShippingDateAndTime: Int?
//    let shippingCompanies: [String]?
//    let images: [ImageModel]?
//    let commissionRatio, maxCommissionValue: String?
//    let commission: Double?
//    let vatRatio: String?
//    let vatValue: Double?
//    let totalCommissionWithVat: Double?
//    let address: AddressModel?
//}
//
//// MARK: - Updated Mapping Function
//extension ShowOfferModelV3 {
//    func mapToShowOfferModel() -> ShowOfferModel? {
//        guard let v3Data = data else { return nil }
//        
//        // Create a single product from V3 data
//        let product = productList(
//            id: v3Data.productId,
//            images: v3Data.images,
//            name: v3Data.name,
//            description: v3Data.description,
//            price: v3Data.price,
//            amount: nil,
//            offerPrice: v3Data.offerPrice,
//            totalQuantity: nil,
//            paiedQuantity: nil,
//            remainingQuantity: nil
//        )
//        
//        let showOfferData = ShowOfferData(
//            id: v3Data.id,
//            name: v3Data.name,
//            code: v3Data.code,
//            description: v3Data.description,
//            clientId: v3Data.clientId,
//            deliveryPrice: nil,
//            taxPrice: v3Data.vatValue,
//            products: [product],
//            status: v3Data.status,
//            commissionRatio: v3Data.commissionRatio,
//            maxCommissionValue: v3Data.maxCommissionValue,
//            shippingCompanies: v3Data.shippingCompanies,
//            address: v3Data.address
//        )
//        
//        return ShowOfferModel(
//            status: status,
//            message: message,
//            data: showOfferData
//        )
//    }
//    
//    
//    
//}
//
//
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
    let shippingCommission: Double?
    let totalPrice: Double?
}


// Add this struct at the top of OrdersVM.swift file (outside the class)
struct TrackingEvent: Codable, Identifiable {
    let id = UUID()
    let date: String
    let time: String
    let typeCode: String
    let description: String
    let serviceArea: [ServiceArea]
    let signedBy: String?
    
    struct ServiceArea: Codable {
        let code: String
        let description: String
    }
    
//    enum CodingKeys: String, CodingKey {
//        case date, time, typeCode, description, serviceArea, signedBy
//    }
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
    let shipmentFree: Int?
    let hasTaxRecord: Int?
    let productId: Int?
    let product: ProductV3?
    let priceCommission: PriceCommissionV3?
    let shippingCommission: ShippingCommissionV3?
    let seller: SellerV3?
    let address: AddressModel?


}

// MARK: - ProductV3
struct ProductV3: Codable {
    let clientId: Int?
    let price: Double?
    let offerPrice: Double?
    let description: String?
    let width, height, length, weight: Double?
    let plannedShippingDateAndTime: Int?
    let shippingCompanies: [String]?
    let images: [ImageModel]?

  
}

// MARK: - PriceCommissionV3
struct PriceCommissionV3: Codable, Equatable {
    let commissionRatio: String?
    let maxCommissionValue: String?
    let vatRatio: String?
    let commission: Double?
    let commissionVat: Double?
    let commissionNet: Double?

  
}

// MARK: - ShippingCommissionV3
struct ShippingCommissionV3: Codable, Equatable {
    let shippingCommissionRatio: String?
    let vatRatio: String?
    let commission: Double?
    let commissionVat: Double?
    let commissionNet: Double?

 
}

// MARK: - SellerV3
struct SellerV3: Codable, Equatable {
    let merchantVatRatio: FlexibleDouble?
    let sellerAmountBeforeVat: FlexibleDouble?
    let sellerVatValue: FlexibleDouble?
    let sellerNetAmount: FlexibleDouble?
}

enum FlexibleDouble: Codable, Equatable {
    case string(String)
    case double(Double)

    var doubleValue: Double? {
        switch self {
        case .string(let s): return Double(s)
        case .double(let d): return d
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let d = try? container.decode(Double.self) {
            self = .double(d)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else {
            throw DecodingError.typeMismatch(
                FlexibleDouble.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Expected String or Double"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .double(let d): try container.encode(d)
        }
    }
}

extension ShowOfferModelV3 {
    func mapToShowOfferModel() -> ShowOfferModel? {
        guard let v3Data = data else { return nil }

        let product = productList(
            id: v3Data.productId,
            images: v3Data.product?.images,
            name: v3Data.name,
            description: v3Data.product?.description,
            price: v3Data.product?.price,
            amount: nil,
            offerPrice: v3Data.product?.offerPrice,
            totalQuantity: nil,
            paiedQuantity: nil,
            remainingQuantity: nil
        )

        let showOfferData = ShowOfferData(
            id: v3Data.id,
            name: v3Data.name,
            code: v3Data.code,
            description: v3Data.description,
            clientId: v3Data.product?.clientId,
            deliveryPrice: nil,
            taxPrice: v3Data.priceCommission?.commissionVat,
            products: [product],
            status: v3Data.status,
            commissionRatio: v3Data.priceCommission?.commissionRatio,
            maxCommissionValue: v3Data.priceCommission?.maxCommissionValue,
            shippingCompanies: v3Data.product?.shippingCompanies,
            address: v3Data.address,
            // V3 additions
            shipmentFree: v3Data.shipmentFree,
            hasTaxRecord: v3Data.hasTaxRecord,
            priceCommission: v3Data.priceCommission,
            shippingCommission: v3Data.shippingCommission,
            seller: v3Data.seller
        )

        return ShowOfferModel(
            status: status,
            message: message,
            data: showOfferData
        )
    }
}
