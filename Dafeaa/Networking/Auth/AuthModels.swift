//
//  StaticPagesModel.swift
//  Proffer
//
//  Created by AMN on 19/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
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
    let orderId, actionType, iconType,visitType, id, isRead, patientId,reportId: Int?
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
    let name, phone, email: String?
    let status, accountType, activeNotification, uncompletedData: Int?
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
            get {
                return _isExpanded ?? false // Return false if _isExpanded is nil
            }
            set {
                _isExpanded = newValue
            }
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

