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
    
    
  
    
    func validateLogin(phone: String, password: String) {
        if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter phone".localized())
        } else if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter Password".localized())
        } else {
            login(for: ["phone": phone,
                        "password": password])
        }
    }
    
    func validateRegister(photo: UIImage?,name: String, email: String, phone: String, accountType: AccountTypeOption, password: String, confirmPassword: String, isAgreeChecked:Bool) {
        if photo == nil {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter User Photo".localized())
        }
        else if name.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter User Name".localized())
        } else if !name.isValidName {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter a Valid User Name".localized())
        } else if email.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter Email".localized())
        } else if !email.isEmail {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter a Valid Email".localized())
        } else if phone.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter Phone".localized())
        } else if !phone.isNumber {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter a Valid Phone".localized())
        } else if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter Password".localized())
        } else if !password.isValidPassword {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter a Valid Password".localized())
        } else if !confirmPassword.isPasswordConfirm(password: password, confirmPassword: confirmPassword) {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Password and Confirm Password don't Match".localized())
        } else if !isAgreeChecked {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please agree the Terms and conditions".localized())
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
    
    func validateVerify(phone: String, code: String, isForgetPassword: Bool) {
        if code.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter the code".localized())
        } else if code.count != 4 {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter the 4 digit code".localized())
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
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter phone".localized())
        }else if !phone.isNumber {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter a Valid Phone".localized())
        } else {
            self.sendCode(for: ["phone":phone,"usage":"forget_password"])
//            self._isForgetSuccess = true
        }
    }
    
    func validateForgetPassword(phone: String, code: String, password: String, confirmPassword: String) {
        if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter your Password".localized())
        } else if !password.isValidPassword {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter valid Password at least 8 character".localized())
        } else if confirmPassword.isBlank {
                toast = FancyToast(type: .error, title: "Error".localized(), message: "Please Enter the Confirm Password".localized())
        } else if !confirmPassword.isPasswordConfirm(password: password, confirmPassword: confirmPassword) {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "Password and Confirm Password don't Match".localized())
        } else {
            forgetPassword(for: ["code": code.convertDigitsToEng,
                                 "phone": phone,
                                 "password": password,
                                 "password_confirmation": confirmPassword])
        }
    }
    
    private func login(for dic: [String: Any]) {
        self._isLoading = true
        api.login(dic: dic) { result in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                
                guard let response = response else { return }
                self.logIn(response:response)
                
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

//        api.signUp(dic: dic) { result in
//            switch result {
//            case .success(let response):
//                self._message = response?.message ?? ""
//                self._isLoading = false
//                self._isFailed = false
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self._isSignUpSuccess = true
//                }
//                
//            case .failure(let error):
//                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
//                self._isLoading = false
//                self._isFailed = true
//                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
//            }
//        }
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

                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isCheckCodeSuccess = true
                    self.logIn(response:response)

                }
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
                    if let response = response{
                        self.logIn(response: response)
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
   
    func logIn(response:LoginModel) {
        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
        GenericUserDefault.shared.setValue(response.data?.accountType ?? 1 , Constants.shared.userType)
        GenericUserDefault.shared.setValue(response.data?.email ?? "", Constants.shared.email)
        GenericUserDefault.shared.setValue(response.data?.phone ?? "", Constants.shared.phone)
        GenericUserDefault.shared.setValue(response.data?.name ?? "", Constants.shared.userName)
        GenericUserDefault.shared.setValue(response.token ?? "", Constants.shared.token)
        
        if response.data?.uncompletedData == 1 {
            sendCode(for: ["phone":response.data?.phone ?? "","usage":"verify"])
        } else if response.data?.uncompletedData == 2 {
            self._hasUnCompletedData = true 
        }  else {
            MOLH.reset()
        }
    }
    
}

