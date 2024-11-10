//
//  DafeaaApp.swift
//  Dafeaa
//
//  Created by M.Magdy on 01/10/2024.
//


import UIKit
import SwiftUI
import IQKeyboardManagerSwift
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate , MOLHResetable{

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        FirebaseApp.configure()
        
        setUpDidFinishLaunch()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        
    }
    
    func setUpDidFinishLaunch() {
        // Keyboard setup
        IQKeyboardManager.shared.enable = true
        languageConfiguration()
        self.reset()
        let tapGesture = AnyGestureRecognizer(target: window, action:#selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self //I don't use window as delegate to minimize possible side effects
        window?.addGestureRecognizer(tapGesture)
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
    
    func languageConfiguration() {
        let currentDeviceLanguage =   NSLocale.current.language.languageCode?.identifier
        print("\(currentDeviceLanguage ?? "en")")
        MOLHLanguage.setDefaultLanguage("en") // Defult Language
        MOLH.shared.activate(true)
    }
    
    func reset() {
        //        NotificationConfigration.shared.firebaseConfigration()
        //        checkAppAvailability()
        let window = UIWindow()
        self.window = window
        let resetLanguage = GenericUserDefault.shared.getValue(Constants.shared.resetLanguage) as? Bool ?? false
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        let status  = Constants.accountStatus
        //
        if resetLanguage == false {
            window.rootViewController = UIHostingController(rootView: SplashView(window: window) .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
        } else if token != ""  {
            if status == 2{
                window.rootViewController = UIHostingController(rootView: TabBarView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
                UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
                
            }else {
                window.rootViewController = UIHostingController(rootView: PendingView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
                UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
            }
        } else {
            window.rootViewController = UIHostingController(rootView: LoginView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
            UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
         }
        window.makeKeyAndVisible()
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        deepLink(url: url)
        return  true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let string = userActivity.webpageURL!.relativeString
        if let url = URL(string: string){
            deepLink(url: url)
        }
        return true
    }
    
    func deepLink(url: URL) {
        let strURL = String(describing: url)
        
        if let urlComponents = URLComponents(string: strURL) {
            let pathComponents = urlComponents.path.split(separator: "/")
            
            // Check if the URL structure matches `/offers/{offerID}/{offerCode}`
             if pathComponents.count >= 3, pathComponents[0] == "offers" {
                 if let offerID = Int(pathComponents[1]) {
                     Constants.clientOrderId = offerID
//                     Constants.offerCode = offerCode // Assuming Constants has an offerCode property
                     
                     print("Offer ID: \(Constants.clientOrderId), Offer Code: (Constants.offerCode)")
                     handelDeepLinkNav() // Navigate in the app based on this link
                 }
             }
         }
    }
    
    func handelDeepLinkNav(){
        self.window?.rootViewController = UIHostingController(rootView: ClientLinkDetails().environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight))
        UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
        self.window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


struct DafeaaApp: App {
    
    var body: some Scene {
        var window: UIWindow?

        WindowGroup {
            SplashView(window: window)
                .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft: .leftToRight)
            
        }
    }
}
