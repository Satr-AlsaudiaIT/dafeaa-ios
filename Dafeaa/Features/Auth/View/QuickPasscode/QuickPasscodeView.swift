//
//  QuickPasscodeView.swift
//  Dafeaa
//
//  Created by AMNY on 06/05/2026.
//

import SwiftUI
import Security

// MARK: - Keychain Helper
final class QuickPasscodeManager {
    static let shared = QuickPasscodeManager()
    private let keychainPrefix = "com.dafeaa.quickPasscode."
    private let installedKey = "com.dafeaa.appInstalled"
    
    private init() {
        if !UserDefaults.standard.bool(forKey: installedKey) {
            clearAllAppPasscodes()
            UserDefaults.standard.set(true, forKey: installedKey)
        }
    }

    /// Delete only passcodes with our app prefix (not all keychain items)
    private func clearAllAppPasscodes() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let items = result as? [[String: Any]] else { return }
        
        for item in items {
            if let account = item[kSecAttrAccount as String] as? String,
               account.hasPrefix(keychainPrefix) {
                let deleteQuery: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: account
                ]
                SecItemDelete(deleteQuery as CFDictionary)
            }
        }
    }
    
    /// Current user's phone from saved profile
    private var currentPhone: String {
        // Adjust this to however your app stores the logged-in user's phone
        let phone = Constants.phone
        return phone.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")
    }
    
    private var keychainKey: String {
        keychainPrefix + currentPhone
    }
    
    func save(passcode: String) -> Bool {
        delete()
        guard let data = passcode.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    func delete() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
    
    /// Check for a specific phone (used before login completes)
    func hasPasscode(forPhone phone: String) -> Bool {
        let cleanPhone = phone.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")
        let key = keychainPrefix + cleanPhone
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
    
    var hasPasscode: Bool { load() != nil }
    
    /// Delete all passcodes (used on reinstall)
    private func deleteAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - QuickPasscodeView (Login flow — has Skip)
struct QuickPasscodeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var phone: String = ""
    @ObservedObject var activeVM: AuthVM
    
    @State private var passcode: [String] = Array(repeating: "", count: 6)
    @State private var confirmPasscode: [String] = Array(repeating: "", count: 6)
    @State private var isConfirmStep: Bool = false
    @State private var toast: FancyToast? = nil
    @FocusState private var focusedIndex: Int?
    @FocusState private var confirmFocusedIndex: Int?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "quickPasscodeTitle") {
                    NavigationUtil.popToRootView()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Image(.otp)
                            .resizable()
                            .frame(width: 144, height: 144)
                        
                        Text("setQuickPasscode".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 24)
                        
                        Text("setQuickPasscodeSubTitle".localized())
                            .textModifier(.plain, 15, .gray666666)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                        
                        // MARK: - Step 1: Enter passcode
                        if !isConfirmStep {
                            pinFields(pins: $passcode, focused: $focusedIndex)
                                .padding(.top, 20)
                        } else {
                            // Show step 1 as locked dots
                            dotsRow(values: passcode)
                                .padding(.top, 20)
                            
                            // MARK: - Step 2: Confirm passcode
                            Text("confirmQuickPasscode".localized())
                                .textModifier(.plain, 17, .black222222)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 24)
                            
                            pinFields(pins: $confirmPasscode, focused: $confirmFocusedIndex)
                                .padding(.top, 12)
                        }
                        
                        ReusableButton(buttonText: "confirm") {
                            handleConfirm()
                        }
                        .padding(.top, 24)
                        
                        Button {
                            activeVM.profile()
                        } label: {
                            Text("skip".localized())
                                .textModifier(.plain, 16, Color(.primary))
                                .padding(.top, 16)
                        }
                        
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done".localized()) { hideKeyboard() }
                    Spacer()
                }
            }
            
            if activeVM.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $toast)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedIndex = 0
            }
        }
    }
    
    // MARK: - Logic
    private func handleConfirm() {
        let code = passcode.joined()
        
        if !isConfirmStep {
            guard code.count == 6 else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "pleaseEnter6Digits".localized())
                return
            }
            withAnimation {
                isConfirmStep = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confirmFocusedIndex = 0
            }
        } else {
            let confirmCode = confirmPasscode.joined()
            guard confirmCode.count == 6 else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "pleaseEnter6Digits".localized())
                return
            }
            guard code == confirmCode else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "passcodeMismatch".localized())
                confirmPasscode = Array(repeating: "", count: 6)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    confirmFocusedIndex = 0
                }
                return
            }
            if QuickPasscodeManager.shared.save(passcode: code) {
                toast = FancyToast(type: .success, title: "Success".localized(), message: "passcodeSetSuccess".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    activeVM.profile()
                }
            } else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "passcodeSaveFailed".localized())
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Settings Quick Passcode Setup (no AuthVM, dismiss back)
struct SettingsQuickPasscodeSetupView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var isQuickPasscodeOn: Bool
    
    @State private var passcode: [String] = Array(repeating: "", count: 6)
    @State private var confirmPasscode: [String] = Array(repeating: "", count: 6)
    @State private var isConfirmStep: Bool = false
    @State private var toast: FancyToast? = nil
    @FocusState private var focusedIndex: Int?
    @FocusState private var confirmFocusedIndex: Int?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "quickPasscodeTitle") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Image(.otp)
                            .resizable()
                            .frame(width: 144, height: 144)
                        
                        Text("setQuickPasscode".localized())
                            .textModifier(.plain, 19, .black222222)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 24)
                        
                        Text("setQuickPasscodeSubTitle".localized())
                            .textModifier(.plain, 15, .gray666666)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                        
                        if !isConfirmStep {
                            pinFields(pins: $passcode, focused: $focusedIndex)
                                .padding(.top, 20)
                        } else {
                            dotsRow(values: passcode)
                                .padding(.top, 20)
                            
                            Text("confirmQuickPasscode".localized())
                                .textModifier(.plain, 17, .black222222)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 24)
                            
                            pinFields(pins: $confirmPasscode, focused: $confirmFocusedIndex)
                                .padding(.top, 12)
                        }
                        
                        ReusableButton(buttonText: "confirm") {
                            handleConfirm()
                        }
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done".localized()) { hideKeyboard() }
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $toast)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedIndex = 0
            }
        }
    }
    
    private func handleConfirm() {
        let code = passcode.joined()
        
        if !isConfirmStep {
            guard code.count == 6 else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "pleaseEnter6Digits".localized())
                return
            }
            withAnimation {
                isConfirmStep = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confirmFocusedIndex = 0
            }
        } else {
            let confirmCode = confirmPasscode.joined()
            guard confirmCode.count == 6 else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "pleaseEnter6Digits".localized())
                return
            }
            guard code == confirmCode else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "passcodeMismatch".localized())
                confirmPasscode = Array(repeating: "", count: 6)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    confirmFocusedIndex = 0
                }
                return
            }
            if QuickPasscodeManager.shared.save(passcode: code) {
                isQuickPasscodeOn = true
                toast = FancyToast(type: .success, title: "Success".localized(), message: "passcodeSetSuccess".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                toast = FancyToast(type: .error, title: "error".localized(), message: "passcodeSaveFailed".localized())
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Shared Reusable Pin Components
extension View {
    
    /// Read-only dots row — shows filled circles for entered digits, dashes for empty
    @ViewBuilder
    func dotsRow(values: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                ZStack{
                    if !values[index].isEmpty {
                        Circle()
                            .fill(Color.black222222)
                            .frame(width: 14, height: 14)
                    } else {
                        Rectangle()
                            .fill(Color(.gray666666))
                            .frame(width: 44, height: 2)
                    }
                }.frame(width: 44, height: 55)
            }
        }
        .frame(height: 55)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    /// Editable pin fields — invisible text field over dot/dash display
    @ViewBuilder
    func pinFields(pins: Binding<[String]>, focused: FocusState<Int?>.Binding) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    if !pins[index].wrappedValue.isEmpty {
                        Circle()
                            .fill(Color.black222222)
                            .frame(width: 14, height: 14)
                    } else {
                        Rectangle()
                            .fill(Color(.gray666666))
                            .frame(width: 38, height: 2)
                    }
                    
                    TextField("", text: pins[index])
                        .frame(width: 44, height: 55)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .foregroundColor(.clear)
                        .tint(.clear)
                        .focused(focused, equals: index)
                        .onChange(of: pins[index].wrappedValue) { _, newVal in
                            if newVal.count > 1 {
                                pins[index].wrappedValue = String(newVal.last!)
                            }
                            if newVal.count == 1 && index < 5 {
                                focused.wrappedValue = index + 1
                            } else if newVal.count == 1 && index == 5 {
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil
                                )
                            } else if newVal.isEmpty && index > 0 {
                                focused.wrappedValue = index - 1
                            }
                        }
                }
            }
        }
        .frame(height: 55)
        .environment(\.layoutDirection, .leftToRight)
    }
}
#Preview {
    QuickPasscodeView(activeVM: AuthVM())
}
