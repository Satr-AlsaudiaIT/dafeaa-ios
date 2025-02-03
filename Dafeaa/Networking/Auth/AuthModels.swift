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
    let privacyPolicy: String?
    let terms: String?
    let about: String?

}
//MARK: - notificationList
struct NotificationsModel: Codable {
    let data: [NotificationsData]?
    let count: Int?
    let status: Bool?
}

// MARK: - NotificationsData
struct NotificationsData: Codable {
    let orderId, actionType, iconType,visitType, id, isRead : Int?
    let title,  createdAt, body, data, time: String?
}
// MARK: - LoginModel
struct LoginModel: Codable {
    let status: Bool?
    let message: String?
    let data: LoginData?
    let token: String?
}

// MARK: - LoginData
struct LoginData:Codable {
    let name, phone, email, profileImage: String?
    let id: Int?
    let status, accountType, activeNotification, uncompletedData: Int?
    let businessInformationStatus: Int? // 0 no files uploaded, 1 pending, 2 accepted
    let subscriptionPlan, subscriptionPlanEndDate: String?
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
    let address, streetName, buildingNum: String?
    let area, floatNum: String?
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
