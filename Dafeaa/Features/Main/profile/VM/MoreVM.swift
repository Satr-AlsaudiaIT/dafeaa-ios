//
//  MoreVM.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//

import Foundation
import UIKit

final class MoreVM : ObservableObject {
    
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _questionList   : [QuestionsListData] = []
    @Published private var _staticData     : StaticPagesData?
    @Published private var _contactData    : ContactData?
    @Published private var _profileData    : LoginData?
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    private var _message                   : String = ""
    private var token                      = ""
    let api                                : MoreAPIProtocol = MoreAPI()
    
    
    var isLoading    : Bool { get { return _isLoading} }
    
    var message      : String { get { return _message} }
    
    var isFailed     : Bool {  get { return _isFailed} }
 
    var profileData  : LoginData? {   get { return _profileData} }
    
    var contactData  : ContactData? {  get { return _contactData}  }
    
    var questionList : [QuestionsListData] { get {return _questionList  }  set {}  }
    
    var staticData   : StaticPagesData? { get {return _staticData} set {} }
    
    func validateChangePassword(currentPassword: String, password: String, confirmPassword: String) {
        if currentPassword.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "messageEmptyCurrentPassword".localized())
        } else if password.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "messageEmptyNewPassword".localized())
        } else if !password.isValidPassword {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "messageValidNewPassword8character".localized())
        } else if confirmPassword.isBlank {
                toast = FancyToast(type: .error, title: "Error".localized(), message: "messageEmptyConfirmPassword".localized())
        } else if !confirmPassword.isPasswordConfirm(password: password, confirmPassword: confirmPassword) {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "messageMatchPasswordConfirm".localized())
        } else {
            changePassword(for: [
                                 "old_password"              : currentPassword,
                                 "new_password"              : password,
                                 "new_password_confirmation" : confirmPassword])
        }
    }
    
    func validateEditProfile(name: String, email: String, image: UIImage?) {
        if name.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterUserName".localized())
        } else if email.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterEmail".localized())
        } else if !email.isEmail {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "enterValidEmail".localized())
        }else {
            var dic = [
                "_method" : "put"]
            if name  != self.profileData?.name ?? ""  { dic.updateValue(name, forKey: "name") }
            if email != self.profileData?.email ?? "" { dic.updateValue(email, forKey: "email")}
            editProfile(dic: dic, photo: image)
        }
    }

 
    //MARK: - APIs
    
    func profile() {
        self._isLoading = true
        api.profile {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._profileData = response?.data
                self._getData = true
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func  questions(skip : Int,completion: @escaping (Bool) -> Void) {
        self._isLoading = true
        api.questions(skip : skip) { [weak self] (Result) in
            guard let self = self else {return}
            switch Result {
            case .success(let Result):
                self._isLoading = false
                self._isFailed = false
                guard   let data = Result?.data else {return}
                if skip == 0  {
                    self._questionList.removeAll()
                    self._questionList = data
                } else  if skip != data.count{
                    data.forEach{ item in
                        self._questionList.append(item)
                        completion(true)
                    }
                }else{
                    completion(false)
                }
                case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func logOut() {
        self._isLoading = true
        api.logOut {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.reset()
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func  deleteAccount() {
        self._isLoading = true
        api.deleteAccount {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.reset()
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func  getStaticPages(type : String) {
        self._isLoading = true
        api.getStatic(type: type) {(result)  in
            switch result {
            case .success(let response):
                self._isLoading = false
                self._isFailed = false
                self._staticData = response?.data
            case .failure(let error):
                self._isLoading = false
                self._isFailed = true
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message )
            }
        }
    }
    
    func  getContacts() {
        self._isLoading = true
        api.getContacts {(result)  in
            switch result {
            case .success(let response):
                self._isLoading = false
                self._isFailed = false
                self._contactData = response?.data
            case .failure(let error):
                self._isLoading = false
                self._isFailed = true
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message )
            }
        }
    }

    func activeNotification (active: Int){
        self._isLoading = true
        api.notifyOnOff(active: active) {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    private func changePassword(for dic: [String:Any]) {
        self._isLoading = true
        api.changePassword(dic: dic) {(result)  in
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.reset()
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }

    func editProfile(dic: [String: Any],photo: UIImage?){
        self._isLoading = true
        
        MultipartUploadImages.shared.uploadImage(path: "auth/edit-profile", parameterS: dic, photos: ["profile_image": photo], photosArray: nil) { status, message, error in
            if status == 1 {
                self._isLoading = false
                self._isFailed = false
                self._message = message ?? ""
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self._isSuccess = true }
            } else {
                self._message = message ?? ""
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }

    func reset(){
        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
        GenericUserDefault.shared.setValue("", Constants.shared.token)
        MOLH.reset()
        
    }
}
