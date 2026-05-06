//
//  AuthModel.swift

//

import Foundation

// MARK: - GeneralModel

struct GeneralModel: Codable {
    let status: Bool?
    let message: String?
}


// MARK: - StaticPagesModel
struct StaticPagesModel: Codable {
    let status: Bool?
    let message: String?
    let data: StaticPagesData?
}
// MARK: - StaticPagesData
struct StaticPagesData: Codable {
    let privacy: String?
    let terms: String?
    let about: String?

}
//MARK: - notificationList
struct NotificationsModel: Codable {
    let data: [NotificationsData]?
    let count: Int?
    let status: Bool?
}

// Top of the same file as NotificationsView
enum NotificationAction: Hashable {
    case clientOrder(id: Int)
    case merchantOrder(id: Int)
    case withdraws(id: Int)
    case wallet(id: Int)
    case none
}

// MARK: - NotificationsData
struct NotificationsData: Codable {
    let  id, isRead, actionId, actionType : Int?
    let title,  createdAt, body, data, time : String?
    let userType: String?
}

extension NotificationsData {
    var navigationAction: NotificationAction {
        guard let actionTypeInt = actionType else {
            return .none
        }

        switch actionTypeInt {
        case 1:
            guard let actionId = actionId else { return .none }
            if userType?.lowercased() == "client" {
                return .clientOrder(id: actionId)
            } else if userType?.lowercased() == "merchant" {
                return .merchantOrder(id: actionId)
            } else {
                return .none
            }
//        case 2:
//            return .withdraws(id: actionId ?? 1)
//            
        case 2, 3:
            return .wallet(id: actionId ?? 1)
            
        default:
            return .none
        }
    }
}

extension NotificationAction {
    static func make(
        actionType: Int,
        actionId: Int,
        userType: String
    ) -> NotificationAction {
        switch actionType {
        case 1:
            switch userType.lowercased() {
            case "client":
                return .clientOrder(id: actionId)
            case "merchant":
                return .merchantOrder(id: actionId)
            default:
                return .clientOrder(id: actionId)
            }

        case 2:
            return .withdraws(id: actionId)

        case 3:
            return .wallet(id: actionId)

        default:
            return .none
        }
    }
}
// MARK: - LoginModel
struct LoginModel: Codable {
    let status: Bool?
    let message: String?
    let data: LoginData?
    let accessToken: String?
    let refreshToken: String?
}

// MARK: - LoginData
struct LoginData:Codable, Equatable {
    let name, phone, email, profileImage: String?
    let id: Int?
    let status, accountType, activeNotification, uncompletedData: Int?
    let businessInformationStatus: Int? // 0 no files uploaded, 1 pending, 2 accepted
    let subscriptionPlan, subscriptionPlanEndDate: String?
    let profileId: String?
    var secretKey : String? = nil
    var isFinancialInfoCompleted: Bool?
}

// MARK: - RefreshTokenModel
struct RefreshTokenModel: Codable {
    let status: Bool?
    let message: String?
    let accessToken: String?
    let refreshToken: String?
}

struct QuestionsListModel: Codable {
    let data: [QuestionsListData]?
    let message: String?
}

struct QuestionsListData: Codable, Identifiable {
    let id: Int?
    let question: String?
    let answer: String?
    var _isExpanded: Bool? // Private variable to hold the actual value
    var isExpanded: Bool {
        get {   return _isExpanded ?? false  }
        set {   _isExpanded = newValue }
    }
}


// MARK: - ContactModel
struct ContactModel:Codable {
    let status: Bool?
    let message: String?
    let data: ContactData?
}

// MARK: - ContactData
struct ContactData: Codable{
    let contactPhone, contactEmail, whatsappNum: String?
}

// MARK: - RegisterModel
struct RegisterModel: Codable {
    let status: Bool?
    let message: String?
    let data: RegisterDataModel?
}

// MARK: - RegisterDataModel
struct RegisterDataModel: Codable {
    let email, phone: [String]?
}


// MARK: - CountryCityModel
struct CountryCityModel: Codable  {
    let status: Bool?
    let message: String?
    let data: [CountryCityModelData]?
    let count: Int?
}

// MARK: - CountryCityModelData
struct CountryCityModelData : Codable {
    let id: Int?
    let name: String?
}

// MARK: - AddressesModel
struct AddressesModel: Codable {
    let status: Bool?
    let message: String?
    let data: [AddressesData]?
    let count: Int?
}

// MARK: - AddressesData
struct AddressesData: Codable {
    let id, clientID: Int?
    let address, streetName, countryCode, cityName: String?
    let areaId: Int?
    let cityId, countryId: Int?
    let districtName: String?
    let provinceCode: String? // Governorate
    let postalCode: String?   // Postal code
    let lat, lng: String?
    let isMain: Int?
    
}


// MARK: - withdrawsModel
struct withdrawsModel: Codable {
    let status: Bool?
    let message: String?
    let data: [withdrawsData]?
    let count: Int?
}
// MARK: - withdrawsData
struct withdrawsData: Codable {
    let id, status: Int?
    let amount: Double?
    let statusDate: String?
}


struct AddToWalletModel: Codable {
    let status: Bool?
    let message: String?
    let data: String?
}

// MARK: - WithdrawResponseModel
struct WithdrawResponseModel: Codable {
    let message: String?
    let transaction: WithdrawTransactionData?
}

// MARK: - WithdrawTransactionData
struct WithdrawTransactionData: Codable {
    let id: String?
    let sourceId: String?
    let sequenceNumber: String?
    let channel: String?
    let status: String?
    let amount: Int?
    let currency: String?
    let purpose: String?
    let comment: String?
    let destination: WithdrawDestination?
    let message: String?
    let failureReason: String?
    let createdAt: String?
    let updatedAt: String?
    let metadata: String?
    
  
}

// MARK: - WithdrawDestination
struct WithdrawDestination: Codable {
    let type: String?
    let mobile: String?
    let iban: String?
    let name: String?
    let country: String?
    let city: String?
}

// MARK: - PaymentResponseModel
struct PaymentResponseModel: Codable {
    let success: Bool?
    let transactionUrl: String?

}




import Foundation

// MARK: - Tax Record Response Model
struct TaxRecordModel: Codable {
    let status: Bool?
    let message: String?
    let data: TaxRecordData?
}

// MARK: - Tax Record Data
struct TaxRecordData: Codable {
    let id: Int?
    let clientId: Int?
    let taxNumber: String?
    let createdAt: String?
    let updatedAt: String?

    
}
