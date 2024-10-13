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
    
    func firebaseConfigration() {
        registerForPushNotifications()
    }
    
    // catch Notification Back Ground
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { [weak self]
            granted, error in
            guard granted else { //print("Permission denied");
                return}
            self?.getNotificationSettings()
            Messaging.messaging().delegate = self
        }
    }
    
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings {settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return}
                UIApplication.shared.registerForRemoteNotifications()
                self.pushNotificationAPISetUp()
            }
        }
    }
    
    private func pushNotificationAPISetUp() {
        //MARK:- toDo push notification
//        Messaging.messaging().token { token, error in
//            print("token is ----> \(token ?? "")")
//            GenericUserDefault.shared.setValue(token, Constants.shared.deviceToken)
//            let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
//            if  GenericUserDefault.shared.getValue( Constants.shared.token) as? String ?? "" != "" {
//                
//                let api  = AuthAPI()
//                api.submitToken(token: token ?? "", deviceId: UUIDValue) { (result) in
//                    switch result {
//                        
//                    case .success(let result):
//                        print(result?.message ?? "")
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        _ = notification.request.content.userInfo
        // print("userInfo\(userInfo)")
        completionHandler([.banner, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // print("CALL:: didReceiveRemoteNotification:: userinfo: \(userInfo)")
    }
    
    // MARK: - NotCalled
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let actionId = userInfo["action_id"] as? String
        let actionType = userInfo["action_type"] as? String
        
        print(userInfo,"userInfo")
        
        if  actionType != "0" && actionId != "" {
            setRoot(actionType: actionType  ?? "" , actionId: actionId ?? "")
            
        }
        
        completionHandler()
    }
    
    // Notification Click lisiner
    private func setRoot(actionType: String, actionId: String) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
           //MARK: - toDo action notification
//        if let window = windowScene?.windows.first {
//            let navigationHelper = NavigationHelper(actionType: Int(actionType) ?? 0, actionId: Int(actionId) ?? 0)
//            let mainView = MainView()
//                .environmentObject(navigationHelper)
//                .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
//                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
//
//            let rootViewController = UIHostingController(rootView: mainView)
//            
//            window.rootViewController = rootViewController
//            window.makeKeyAndVisible()
//        }
    }

}
