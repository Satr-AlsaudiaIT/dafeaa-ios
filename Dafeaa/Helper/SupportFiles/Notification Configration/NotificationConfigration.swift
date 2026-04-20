//
//  NotificationConfigration.swift
//

import UIKit
import Firebase
//import FirebaseInstanceID
import FirebaseMessaging
import SwiftUI

class NotificationConfigration: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    static var shared = NotificationConfigration()
    
    func firebaseConfigration(onReady: (() -> Void)? = nil) {
        registerForPushNotifications(onReady: onReady)
    }
    
    // catch Notification Back Ground
    func registerForPushNotifications(onReady: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { [weak self]
            granted, error in
            guard granted else { return }
            self?.getNotificationSettings(onReady: onReady)
            Messaging.messaging().delegate = self
        }
    }
    
    
    private func getNotificationSettings(onReady: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                DispatchQueue.main.async { onReady?() }
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIApplication.shared.registerForRemoteNotifications()
                self.pushNotificationAPISetUp(onReady: onReady)
            }
        }
    }
    
    private func pushNotificationAPISetUp(onReady: (() -> Void)? = nil) {
        Messaging.messaging().token { token, error in
            print("token is ----> \(token ?? "")")
            GenericUserDefault.shared.setValue(token, Constants.shared.deviceToken)
            let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
            guard GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? "" != "" else {
                DispatchQueue.main.async { onReady?() }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let api = AuthAPI()
                api.submitToken(token: token ?? "", deviceId: UUIDValue) { (result) in
                    switch result {
                    case .success(let result):
                        print(result?.message ?? "")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    DispatchQueue.main.async { onReady?() }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
         print("userInfo\(userInfo)")
        completionHandler([.banner, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // print("CALL:: didReceiveRemoteNotification:: userinfo: \(userInfo)")
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionId = userInfo["action_id"] as? String
        let actionType = userInfo["action_type"] as? String
        let userType = userInfo["user_type"] as? String ?? "client"
print("userInfo",userInfo, actionId, actionType, userType)
        if let actionTypeInt = Int(actionType ?? "0"),
           actionTypeInt != 0
        {
            setRoot(
                actionType: actionType ?? "",
                actionId: actionId ?? "",
                userType: userType
            )
        }

        completionHandler()
    }
    
    // Notification Click lisiner
    private func setRoot(actionType: String, actionId: String,userType:String) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
           //MARK: - toDo action notification
        if let window = windowScene?.windows.first {
            let navigationHelper = NavigationHelper(actionType: Int(actionType) ?? 0, actionId: Int(actionId) ?? 0,userType: userType)
            let tabBarView = TabBarView()
                .environmentObject(navigationHelper)
                .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)

            let rootViewController = UIHostingController(rootView: tabBarView)
            
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }

}


import SwiftUI

class NavigationHelper: ObservableObject {
    @Published var actionType: Int
    @Published var actionId: Int
    @Published var userType: String
    @Published var navigateToClientOrder: Bool = false
    @Published var navigateToMerchentOrder: Bool = false
    @Published var navigateToWithdraws: Bool = false

    init(actionType: Int, actionId: Int,userType:String) {
        self.actionType = actionType
        self.actionId = actionId
        self.userType = userType
        
        if actionType == 1 {
            if userType == "client" {
                self.navigateToClientOrder = true
                
            }
            else if userType == "merchant" {
                self.navigateToMerchentOrder = true
            }
//        } else if actionType == 2 {
//            self.navigateToWithdraws = true
        } else if actionType == 3 || actionType == 2{
            Constants.shouldNavigateToWallet = true
        }
        else if actionType == 4 {
           Constants.shouldNavigateToWallet = true
       }
    }
}

