//
//  Constants.swift
//  Dafeaa
//
//  Created by M.Magdy on 01/10/2024.
//

import Foundation
import UIKit
class Constants {
    static var shared = Constants()
    
    var isAR: Bool { return (MOLHLanguage.currentAppleLanguage() == "ar") }
//    let baseURLV1 =  "https://dafeaa-backend.deplanagency.com/api/"  // develop instance
    //BaseURL v1 backup
    let baseURLV1 =  "https://backend.dafea.com.sa/api/"
    
    
//    let baseURL =  "https://dafeaa-backend.deplanagency.com/api/v2/"  // develop instance
    //BaseURL backup
    let baseURL = "https://backend.dafea.com.sa/api/v2/"
    
    
    
    //To do
//    let basURLV3 = "https://dafeaa-backend.deplanagency.com/api/v3/"  //develop for links and orders V3
        //BaseURL v3 backup
    
    
    let basURLV3 = "https://backend.dafea.com.sa/api/v3/"
    // possible to get back to V2
    
//    let baseURL =   "" // live
    let developerMode = false
    let resetLanguage = "resetLanguage"
    var onboarding = "onboarding"
    let token = ""
    let returnCode = "returnCode"
    let registerFinish  = "No"
    let email = "email"
    let gender = "gender"
    let dateOfBirth = "dateOfBirth"
    let profileImageURL = "profileImageURL"
    let deviceToken = "deviceToken"
    let unReadNotificationCount = "unread"
    let notificationOnOrOff = "notificationOnOrOff"
    let userType = "userType"
    let needsVerification = "needVerification"
    let selectedAddressId = "selectedAddressId"
    let selectedAddress = "selectedAddress"
    let userId = "userId"
    let businessInformationStatus = "businessInformationStatus"
    let subPlanId = "subPlanId"
    let activeNotification = "activeNotification"
    let offerDataAfterLoginResetFromLink = "offerDataAfterLoginResetFromLink"

    static let ARAB_NATIONAL_BANK_CODE = "30"  // البنك العربي الوطني
    static let WITHDRAW_THRESHOLD: Double = 20000.0  // SAR
    static var qrAuthAlreadyConfirmed: Bool = false

    static var accountStatus: Int {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "accountStatus") as? Int ?? 2
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "accountStatus")
        }
    }
    
    static var userName: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "userName") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "userName")
        }
    }
    
    static var availableAmount: Double {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "availableAmount") as? Double ?? 0
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "availableAmount")
        }
    }

    static var phone: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "phone") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "phone")
        }
    }
    
    static var sessionFlag: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "sessionFlag") as? Bool ?? false
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "sessionFlag")
        }
    }

    static var selectedAddressId: Int {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "selectedAddressId") as? Int ?? 0
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "selectedAddressId")
        }
    }
    
    static var selectedAddress: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "selectedAddress") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "selectedAddress")
        }
    }
    
    static var clientOrderCode: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "clientOrderCode") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "clientOrderCode")
        }
    }
    
    static var quickQrCode: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "quickQrCode") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "quickQrCode")
        }
    }

    static var refreshToken: String {
        get {
            UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "refreshToken")
        }
    }
    
    // Payment status tracking
    static var shouldNavigateToWallet: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "shouldNavigateToWallet") as? Bool ?? false
        }
        set(value) {
            let ud = UserDefaults.standard
            ud.set(value, forKey: "shouldNavigateToWallet")
        }
    }
    
    static var resetFromLinkLogin: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "resetFromLinkLogin") as? Bool ?? false
        }
        set(value) {
            let ud = UserDefaults.standard
            ud.set(value, forKey: "resetFromLinkLogin")
        }
    }
    
    
    
//    static var offerDataAfterLoginResetFromLink: ShowOfferData {
//        get {
//            let ud = UserDefaults.standard
//            return ud.value(forKey: "offerUserIdAfterLoginResetFromLink") as? ShowOfferData ?? ShowOfferData()
//        }
//        set(value) {
//            let ud = UserDefaults.standard
//            ud.set(value, forKey: "offerUserIdAfterLoginResetFromLink")
//        }
//    }

    
    static var lastPayoutStatus: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "lastPaymentStatus") as? String ?? ""
        }
        set(value) {
            let ud = UserDefaults.standard
            ud.set(value, forKey: "lastPaymentStatus")
        }
    }
    
    static var lastPaymentStatus: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "lastPaymentStatus") as? String ?? ""
        }
        set(value) {
            let ud = UserDefaults.standard
            ud.set(value, forKey: "lastPaymentStatus")
        }
    }
    
    static func getBankCodeFromIBAN(_ iban: String) -> String {
            let cleanedIBAN = iban.replacingOccurrences(of: " ", with: "").uppercased()
            
            guard cleanedIBAN.count >= 6 else { return "" }
            
            let startIndex = cleanedIBAN.index(cleanedIBAN.startIndex, offsetBy: 4)
            let endIndex = cleanedIBAN.index(cleanedIBAN.startIndex, offsetBy: 6)
            let bankCode = String(cleanedIBAN[startIndex..<endIndex])
            
            return bankCode
        }
        
        static func isArabNationalBank(_ iban: String) -> Bool {
            let bankCode = getBankCodeFromIBAN(iban)
            return bankCode == ARAB_NATIONAL_BANK_CODE
        }
    
    static func clearSession() {
        refreshToken = ""
        accountStatus = 2
        userName = ""
        phone = ""
        sessionFlag = false
    }
    
//    static var offersData: ShowOfferData? {
//        get {
//            let ud = UserDefaults.standard
//            if let data = ud.data(forKey: "offersData") {
//                let decoder = JSONDecoder()
//                return try? decoder.decode(ShowOfferData.self, from: data)
//            }
//            return nil
//        }
//        set {
//            let ud = UserDefaults.standard
//            if let newValue = newValue {
//                let encoder = JSONEncoder()
//                if let encodedData = try? encoder.encode(newValue) {
//                    ud.set(encodedData, forKey: "offersData")
//                }
//            } else {
//                ud.removeObject(forKey: "offersData")
//            }
//        }
//    }

//    static var notificationOnOrOff: Bool {
//        get {
//            let ud = UserDefaults.standard
//            return ud.value(forKey: "notificationOnOrOff") as? Bool ?? true
//        }
//        set(token) {
//            let ud = UserDefaults.standard
//            ud.set(token, forKey: "notificationOnOrOff")
//        }
//    }
}
