//
//  DafeaaAppClipApp.swift
//  DafeaaAppClip
//
//  Created by AMNY on 18/01/2026.
//

import SwiftUI

@main
struct DafeaaClipApp: App {
    
    init() {
        // Force Arabic language
        UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Debug: Print current locale
        print("🌍 Current locale: \(Locale.current.identifier)")
        print("🌍 Preferred languages: \(Locale.preferredLanguages)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "Locale.current.identifier"))
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    handleAppClipInvocation(userActivity)
                }
        }
    }
    
    func handleAppClipInvocation(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        print("📱 App Clip invoked with: \(url)")
        
        // URL parameters will be handled by ContentView
        NotificationCenter.default.post(
            name: NSNotification.Name("AppClipURLReceived"),
            object: url
        )
    }
}
