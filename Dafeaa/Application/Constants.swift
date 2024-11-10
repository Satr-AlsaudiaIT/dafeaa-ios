//
//  Constants.swift
//  Dafeaa
//
//  Created by M.Magdy on 01/10/2024.
//

import Foundation
class Constants {
    static var shared = Constants()

    
    var isAR: Bool { return (MOLHLanguage.currentAppleLanguage() == "ar") }
    let baseURL =  "https://dafeaa-backend.deplanagency.com/api/"  // develop instance
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
    
    static var clientOrderId: Int {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "clientOrderId") as? Int ?? 0
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "clientOrderId")
        }
    }
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
