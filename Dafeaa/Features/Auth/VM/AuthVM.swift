//
//  AuthVM.swift
//  Dafeaa
//
//  Created by M.Magdy on 06/10/2024.
//

import SwiftUI

class AuthVM: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var isPhoneNumberValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    @Published var toast: FancyToast? = nil
    @Published var _isForgetSuccess = false
    @Published var _isSendCodeSuccess = false
    @Published private var _isLoading = false
    @Published private var _isFailed = false
    @Published private var _needsVerification = false
    @Published var _isSignUpSuccess = false
    @Published private var _isCheckCodeSuccess = false
    @Published var _isVerifyCodeSuccess = false
    @Published private var _isCreatePasswordSuccess = false
    @Published var _hasUnCompletedData = false
    @Published private var _countries: [CountryCityModelData] = []
    @Published private var _countriesNames: [String] = []
    
    @Published private var _cities: [CountryCityModelData] = []
    @Published private var _citiesNames: [String] = []
    
    
    private var _message: String = ""
    private var token = ""
    let api: AuthAPIProtocol = AuthAPI()
    var isLoading: Bool {
        get { return _isLoading}
    }
    var message : String {
        get { return _message}
    }
    
    var isFailed: Bool {
        get { return _isFailed}
    }
    var isSignUpSuccess: Bool {
        get {return _isSignUpSuccess}
        set {}
    }
    
    var countriesNames: [String] {
        get {
            return  self._countries.map {$0.name ?? ""}
        }
        set{}
    }
    var cityNames: [String] {
        get {
            return  self._cities.map {$0.name ?? ""}
        }
        set{}
    }
    func validateLogin(phone: String, password: String) {
        if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPhone".localized())
        } else if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPassword".localized())
        } else {
            login(for: ["phone": phone,
                        "password": password])
        }
    }
    
    func validateRegister(photo: UIImage?, name: String, email: String, phone: String, accountType: AccountTypeOption, password: String, confirmPassword: String, isAgreeChecked:Bool) {
        if photo == nil {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterUserPhoto".localized())
        } else if name.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterUserName".localized())
        } else if !name.isValidName {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidUserName".localized())
        } else if email.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterEmail".localized())
        } else if !email.isEmail {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidEmail".localized())
        } else if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPhone".localized())
        } else if !phone.isValidPhoneNumber {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidPhone".localized())
        } else if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPassword".localized())
        } else if !password.isValidPassword {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterValidPassword".localized())
        } else if !confirmPassword.isPasswordConfirm(password: password, confirmPassword: confirmPassword) {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "PasswordConfirmn'tMatch".localized())
        } else if !isAgreeChecked {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "PleaseTermsconditions" .localized())
        } else {
            let registerDic: [String: Any] = ["name": name,
                                              "email": email,
                                              "phone": phone.convertDigitsToEng,
                                              "account_type": accountType.returnedInt(),
                                              "password": password,
                                              "password_confirmation": confirmPassword]
            registerApi(dic: registerDic,photo: photo)
        }
        
    }
    
    func validateBusiness(phone:String, commLecs: UIImage?, name: String, country: String, city: String, area: String, taxNum: String, endDate: String) {
        if name.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterCommercialName".localized())
        } else if country.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterCountry".localized())
        } else if city.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterCity".localized())
            
        } else if area.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterArea".localized())
            
        } else if taxNum.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterTax".localized())
            
        } else if commLecs == nil {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterCommercialLicens".localized())
            
        }  else if endDate.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterEndDate".localized())
            
        } else {
            let registerDic: [String: Any] = ["name": name,
                                              "city_id": getCityId(cityName: city),
                                              "area": area,
                                              "tax_number": taxNum,
                                              "expired_date": endDate,
                                              "phone" : phone
            ]
            businessInfo(dic: registerDic,photo: commLecs)
        }
        
    }
    
    func validateVerify(phone: String, code: String, isForgetPassword: Bool) {
        if code.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterThecode".localized())
        } else if code.count != 4 {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Enter4DigitCode".localized())
        } else {
            let verifyDic: [String: Any] = ["phone": phone,
                                            "code": code.convertDigitsToEng]
            if isForgetPassword {
                verifyCodeForget(for: verifyDic)
            } else {
                verify(for: verifyDic)
            }
            
        }
    }
    
    func validateForgetPasswordPhone(phone: String) {
        if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPhone".localized())
        }else if !phone.isNumber {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidPhone".localized())
        } else {
            self.sendCode(for: ["phone":phone,"usage":"forget_password"])
            //            self._isForgetSuccess = true
        }
    }
    
    func validateForgetPassword(phone: String, code: String, password: String, confirmPassword: String) {
        if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterYourPassword".localized())
        } else if !password.isValidPassword {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterValidPassword8Character".localized())
        } else if confirmPassword.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "EnterConfirmPassword" .localized())
            
        } else if !confirmPassword.isPasswordConfirm(password: password, confirmPassword: confirmPassword) {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "PasswordConfirmn'tMatch".localized())
        } else {
            forgetPassword(for: ["code"            : code.convertDigitsToEng,
                                 "phone"           : phone,
                                 "password"        : password,
                                 "password_confirmation": confirmPassword])
            
        }
    }
    
    
    func validateChangePhone(password: String, phone: String) {
        if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPassword".localized())
        } else if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterPhone".localized())
        } else if !phone.isValidPhoneNumber{
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidPhone".localized())
        }  else {
            changePhone(for: ["password"     : password,
                              "phone"        : phone    ])
        }
    }
    
    //MARK: - APIs
    
    private func login(for dic: [String: Any]) {
        self._isLoading = true
        api.login(dic: dic) { result in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                
                if let response = response,let phone = dic["phone"] as? String {
                    self.logIn(response:response, phone: phone)
                }
            case .failure(let error):
                self._needsVerification = GenericUserDefault.shared.getValue(Constants.shared.needsVerification) as? Bool ?? false
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                if !self._needsVerification {
                    self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
                }
                
            }
        }
    }
    
    private func registerApi(dic: [String: Any],photo: UIImage?) {
        self._isLoading = true
        
        MultipartUploadImages.shared.uploadImage(path: "auth/register", parameterS: dic, photos: ["profile_image": photo], photosArray: nil) { status, message, error in
            if status == 1 {
                self._isLoading = false
                self._isFailed = false
                self._message = message ?? ""
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self._isSignUpSuccess = true
                }
            } else {
                self._message = message ?? ""
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    private func verify(for dic: [String:Any]) {
        self._isLoading = true
        self._isCheckCodeSuccess = false
        api.verify(dic: dic) {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._isCheckCodeSuccess = true
                guard let response = response else { return }
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                if let phone = dic["phone"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        self._isCheckCodeSuccess = true
                        self.logIn(response:response, phone: phone)
                    }}
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func sendCode(for dic: [String:Any]) {
        self._isLoading = true
        api.sendCode(dic: dic) { result in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isSendCodeSuccess = true
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    private func verifyCodeForget(for dic: [String:Any]) {
        self._isLoading = true
        api.verifyCode(dic: dic) { result in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isVerifyCodeSuccess = true
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    private func forgetPassword(for dic: [String:Any]) {
        self._isLoading = true
        api.forgetPassword(dic: dic) {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._isForgetSuccess = true
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
                    if let response = response, let phone = dic["phone"] as? String {
                        self.logIn(response: response,phone: phone)
                    } else{return}
                    
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func businessInfo(dic: [String: Any],photo: UIImage?){
        self._isLoading = true
        
        MultipartUploadImages.shared.uploadImage(path: "auth/submit-business-info", parameterS: dic, photos: ["commercial_record": photo], photosArray: nil) { status, message, error in
            if status == 1 {
                self._isLoading = false
                self._isFailed = false
                self._message = message ?? ""
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self._isSignUpSuccess = true
                }
            } else {
                self._message = message ?? ""
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func logIn(response:LoginModel, phone: String) {
        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
        GenericUserDefault.shared.setValue(response.data?.accountType ?? 1 , Constants.shared.userType)
        GenericUserDefault.shared.setValue(response.token ?? "", Constants.shared.token)
        Constants.accountStatus = response.data?.status ?? 2

        if response.data?.uncompletedData == 1 {
            sendCode(for: ["phone":phone ,"usage":"verify"])
        } else if response.data?.uncompletedData == 2 {
            self._hasUnCompletedData = true
        }  else {
            MOLH.reset()
        }
    }
    func getCountryId(countryName:String) -> Int {
        if let selectedCountry = self._countries.first(where: { $0.name == countryName }){
            return selectedCountry.id ?? 0
        }
        else {
            return 0
        }
    }
    func getCountries() {
        self._isLoading = true
        api.getCountries() { result in
            switch result {
            case .success(let response):
                self._isLoading = false
                self._isFailed = false
                self._countries = response?.data ?? []
                self._countriesNames = self._countries.map {$0.name ?? ""}
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func getCityId(cityName:String) -> Int {
        if let selectedCity = self._cities.first(where: { $0.name == cityName }){
            return selectedCity.id ?? 0
        }
        else {
            return 0
        }
    }
    func getCities(countryId:Int) {
        self._isLoading = true
        api.getCities(countryId: countryId) { result in
            switch result {
            case .success(let response):
                self._isLoading = false
                self._isFailed = false
                self._cities = response?.data ?? []
                self._citiesNames = self._cities.map {$0.name ?? ""}
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    private func changePhone(for dic: [String:Any]) {
        self._isLoading = true
        api.changePhone(dic: dic) {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                if let phone = dic["phone"] as? String {
                    self.sendCode(for: ["phone": phone, "usage": "verify"]) }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
}

