//
//  ValidateTF.swift
//  Proffer
//
//  Created by M.Magdy on 15/02/2024.
//  Copyright © 2024 Nura. All rights reserved.
//

import Foundation
enum validateFieldType {
    case phone, email, address, area, hospital, name, firstName, middleName, lastName, city, country, password, confirmPassword, noValidation
    
}

class ValidateTF : ObservableObject  {
    @Published private var _errorMessage = ""
 
    var errorMessage : String {
        get {return _errorMessage}
        set {}
    }
    func confirmPassword(password:String,confirmPassword:String){
        if confirmPassword == "" {
            self._errorMessage = "Confirm password is empty".localized()
        }
        else if confirmPassword != password  {
            self._errorMessage = "Confirm password doesn't match the password".localized()
        }
        else {
            self._errorMessage = ""
        }
    }
    func checkValidation(text:String,validationType:validateFieldType){
        switch validationType {
        case .phone:
            validatePhone(text: text)
        case .email:
            validateMail(text: text)
        case .firstName:
            validateFirstName(text: text)
        case .middleName:
            validateMiddleName(text: text)
        case .lastName:
            validateLastName(text: text)
        case .address:
            validateAddress(text: text)
        case .area:
            validateArea(text: text)
       
        case .name :
            validateName(text: text)
        default :
            break
        }
    }
    
   private func validatePhone(text: String) {
        self._errorMessage = !text.isValidPhone() ? "Please Enter valid phone starts with 1 and has 10 numbers".localized() : ""
    }
    private func validateMail(text: String) {
        self._errorMessage = !text.isEmail ? "Please Enter valid E-mail".localized() : ""
    }
    private func validateName(text: String) {
        self._errorMessage = !text.isValidName ? "Please Enter Valid Name(Minimum 2 Maximum 50)".localized() : ""
    }
    private func validateFirstName(text: String) {
        self._errorMessage = !text.isValidName ? "Please Enter Valid First Name(Minimum 2 Maximum 50)".localized() : ""
    }
    private func validateMiddleName(text: String) {
        self._errorMessage = !text.isValidName ? "Please Enter Valid Middle Name(Minimum 2 Maximum 50)".localized() : ""
    }
    private func validateLastName(text: String) {
        self._errorMessage = !text.isValidName ? "Please Enter Valid Last Name(Minimum 2 Maximum 50)".localized() : ""
    }
    private func validateAddress(text: String) {
        self._errorMessage = !text.isValidAddress ? "Please Enter Valid Address(Minimum 2 Maximum 50)".localized() : ""
    }
    private func validateArea(text: String) {
        self._errorMessage = !text.isValidName ? "Please Enter Valid Area(Minimum 2 Maximum 50)".localized() : ""
    }
    
    private func validateFullName(text: String) {
        self._errorMessage = !text.validateFullName ? "Please Enter Valid Name(Minimum 3 word)".localized() : ""
    }
//    private func validateHospital(text: String) {
//        self._errorMessage = text.isBlank ? "Please Enter choose hospital".localized() : ""
//    }
    
}
