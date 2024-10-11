//
//  LoginVM.swift
//  Dafeaa
//
//  Created by M.Magdy on 06/10/2024.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var isPhoneNumberValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
}

