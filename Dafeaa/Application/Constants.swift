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
    let baseURL =  "http://93.127.186.172:8000/api/"  // develop instance
//    let baseURL =   "" // live
    let developerMode = false
    let resetLanguage = "resetLanguage"
    var onboarding = "onboarding"
    let token = ""
    let returnCode = "returnCode"
    let userName = "userName"
    let registerFinish  = "No"
    let phone = "phone"
    let email = "email"
    let gender = "gender"
    let dateOfBirth = "dateOfBirth"
    let profileImageURL = "profileImageURL"
    let deviceToken = "deviceToken"
    let unReadNotificationCount = "unread"
    let notificationOnOrOff = "notificationOnOrOff"
    let userType = "userType"
    let needsVerification = "needVerification"

}
