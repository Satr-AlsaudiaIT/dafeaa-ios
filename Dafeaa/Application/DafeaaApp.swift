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
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate , MOLHResetable{
    
    var window: UIWindow?
    //    var keyboardDismissManager = KeyboardDismissManager()
    //    private var tapGesture: AnyGestureRecognizer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAsii5qK2U6xsP39ahyNOoDjXDfHIzH9yU")
        GMSPlacesClient.provideAPIKey("AIzaSyAsii5qK2U6xsP39ahyNOoDjXDfHIzH9yU")
        GoogleMapsLanguageManager.shared.forceEnglish()
        
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
        Constants.sessionFlag = false
        IQKeyboardManager.shared.enable = true
        languageConfiguration()
        self.reset()
        
    }
    
    func languageConfiguration() {
        let currentDeviceLanguage =   NSLocale.current.language.languageCode?.identifier
        print("\(currentDeviceLanguage ?? "en")")
        MOLHLanguage.setDefaultLanguage("en") // Defult Language
        MOLH.shared.activate(true)
    }
    
    func reset() {
        for family in UIFont.familyNames {
            let name = UIFont.fontNames(forFamilyName: family)
            print("family = \(family) - name = \(name)")
        }
        Constants.shouldNavigateToWallet = false
        Constants.lastPaymentStatus = ""
        Constants.lastPayoutStatus  = ""
        NotificationConfigration.shared.firebaseConfigration()
        //        checkAppAvailability()
        let window = UIWindow()
        self.window = window
        let resetLanguage = GenericUserDefault.shared.getValue(Constants.shared.resetLanguage) as? Bool ?? false
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        let status  = Constants.accountStatus
        let resetFromLoginLink = Constants.resetFromLinkLogin
        //
        if resetLanguage == false {
            window.rootViewController = UIHostingController(rootView: SplashView(window: window) .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight)
            )
        } else if token != ""  {
            if resetFromLoginLink {
                let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
                // ✅ Decode from Data
                if let savedData = UserDefaults.standard.data(forKey: "offerDataAfterLoginResetFromLink"),
                   let offerData = try? JSONDecoder().decode(ShowOfferData.self, from: savedData) {
                    // use offerData
                    UserDefaults.standard.removeObject(forKey: "offerDataAfterLoginResetFromLink")
                    if userId != offerData.clientId ?? 0 {
                        let rootView = ClientLinkDetailsNew(offerData: offerData)
                            .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                        window.rootViewController = UIHostingController(rootView: rootView)
                    } else {
                        let rootView = OrderLinkDetailsViewNew(offerData: offerData)
                            .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                        window.rootViewController = UIHostingController(rootView: rootView)
                    }

                }



            }

           else if status == 2{
                let navigationHelper = NavigationHelper(actionType: 0, actionId: 0, userType: "")

                window.rootViewController = UIHostingController(rootView: TabBarView().environmentObject(navigationHelper)
                    .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight)
                    )
                UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
                
            }
            else {
                window.rootViewController = UIHostingController(rootView: PendingView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight)
                    )
                UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
            }
            
        } else {
            window.rootViewController = UIHostingController(rootView: LoginView() .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft:.leftToRight)
            )
            UserDefaults.standard.set(false, forKey:  Constants.shared.resetLanguage)
        }
        window.makeKeyAndVisible()
        //        observeKeyboardDismissManager()
        
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    //        deepLink(url: url)
    //        return  true
    //    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        deepLink(url: incomingURL)
        return true
    }
    
    func deepLink(url: URL) {
        let strURL = String(describing: url)
        
        if let urlComponents = URLComponents(string: strURL) {
            let pathComponents = urlComponents.path.split(separator: "/")
            
            // /payments/{qrCode}
            if pathComponents.count >= 1, pathComponents[0] == "payments" {
                if pathComponents.count > 1 {
                    let quickQrCode = String(pathComponents[1])
                    Constants.quickQrCode = quickQrCode
                    navigateToWalletWithQR()
                }
            }
            // /offers/payments/{qrCode}
            else if pathComponents.count >= 2,
                    pathComponents[0] == "offers",
                    pathComponents[1] == "payments" {
                if pathComponents.count > 2 {
                    let quickQrCode = String(pathComponents[2])
                    Constants.quickQrCode = quickQrCode
                    navigateToWalletWithQR()
                }
            }
            // /offers/{offerCode}
            else if pathComponents.count >= 1, pathComponents[0] == "offers" {
                if pathComponents.count > 1 {
                    let offerCode = String(pathComponents[1])
                    Constants.clientOrderCode = offerCode
                    print("Offer ID: \(Constants.clientOrderCode)")
                    handleDeepLinkNav(code: offerCode)
                }
            }
        }
        
        //            else if pathComponents.count >= 3, pathComponents[1] == "offers" {
        //                let offerCode = String(pathComponents[3])
        //                    Constants.clientOrderCode = offerCode
        //
        //
        //                     print("Offer ID: \(Constants.clientOrderCode), Offer Code: (Constants.offerCode)")
        //                handleDeepLinkNav(code: offerCode) // Navigate in the app based on this link
        //
        //             }

}

func navigateToWalletWithQR() {
    guard Constants.accountStatus == 2 else { return }
    guard let window = self.window else { return }
        
        DispatchQueue.main.async {
            let navigationHelper = NavigationHelper(actionType: 5, actionId: 0, userType: "")
            let rootView = AnyView(
                TabBarView()
                    .environmentObject(navigationHelper)
                    .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
            )
            window.rootViewController = UIHostingController(rootView: rootView)
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
            window.makeKeyAndVisible()
        }
    }
    
    func handleDeepLinkNav(code:String){
        let api: OrdersAPIProtocolV3 = OrdersAPIV3()

        api.showDynamicLinks(code: code) { [weak self] (Result) in
            guard let self = self else { return }
            switch Result {
            case .success(let response):
                guard let response = response else { return }
                //to do if needed to return to v2 remove this and return self.offersData = data
                
                    if let mappedModel = mapShowOfferModelV3ToShowOfferModel(v3Model: response) {
                        navToOffer(offerData:mappedModel.data, offerUserId:response.data?.product?.clientId ?? 0 )
                        }
            case .failure(let error):
                if error.code == 404 {
                    return
                }
            }
        }
        
    }
    
    // to do if needed to return to v2 remove this
    func mapShowOfferModelV3ToShowOfferModel(v3Model: ShowOfferModelV3) -> ShowOfferModel? {
        guard let v3Data = v3Model.data else { return nil }
        
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
            status: v3Model.status,
            message: v3Model.message,
            data: showOfferData
        )
    }
    
    
    
    func navToOffer(offerData: ShowOfferData?,offerUserId: Int) {
        guard Constants.accountStatus == 2 else { return }
        let userId = GenericUserDefault.shared.getValue(Constants.shared.userId) as? Int ?? 0
        if let window = self.window {
            if userId != offerUserId {
                let rootView = ClientLinkDetailsNew(offerData: offerData)
                    .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                window.rootViewController = UIHostingController(rootView: rootView)
            } else {
                let rootView = OrderLinkDetailsViewNew(offerData: offerData)
                    .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                    .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
                window.rootViewController = UIHostingController(rootView: rootView)
            }
            
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
            
            window.makeKeyAndVisible()
        } else {
            print("Error: Window is not initialized.")
        }
    }}


struct DafeaaApp: App {
    @StateObject private var keyboardDismissManager = KeyboardDismissManager() // Create a shared instance
    
    var body: some Scene {
        var window: UIWindow?
        
        WindowGroup {
            SplashView(window: window)
                .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar":"en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft: .leftToRight)
            
        }
    }
}


import Foundation
import GoogleMaps

class GoogleMapsLanguageManager {
    static let shared = GoogleMapsLanguageManager()
    private var originalBundle: Bundle?
    
    func forceEnglish() {
        // Swizzle the main bundle's localizedString method
        swizzleLocalizationMethod()
    }
    
    private func swizzleLocalizationMethod() {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let swizzledSelector = #selector(Bundle.swizzled_localizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension Bundle {
    @objc dynamic func swizzled_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Check if this is a Google Maps related string
        if tableName?.contains("GoogleMaps") == true ||
            key.contains("GMSCore") ||
            key.contains("GoogleMaps") {
            // Use English bundle
            if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
               let enBundle = Bundle(path: path) {
                return enBundle.swizzled_localizedString(forKey: key, value: value, table: tableName)
            }
        }
        
        // For non-Google Maps strings, use normal localization
        return self.swizzled_localizedString(forKey: key, value: value, table: tableName)
    }
}
extension UIApplication {
    func dismissAllPresentedViewControllers(completion: (() -> Void)? = nil) {
        guard let root = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        // Find the topmost presenter
        var topPresenter = root
        while let presented = topPresenter.presentedViewController {
            topPresenter = presented
        }
        
        // Dismiss from root directly — kills entire stack at once
        root.dismiss(animated: true, completion: completion)
    }
}
