//
//  MoreVM.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//

import Foundation
import UIKit

final class MoreVM : ObservableObject {
    
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _questionList   : [QuestionsListData] = []
    @Published private var _staticData     : StaticPagesData?
    @Published private var _contactData    : ContactData?
    @Published private var _profileData    : LoginData?
    @Published private var _addressList    : [AddressesData] = []
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    @Published var _isCreateSuccess        = false
    @Published var _isActive               = false
    @Published var toast: FancyToast?      = nil

    private var _message                   : String = ""
    private var token                      = ""
    let api                                : MoreAPIProtocol = MoreAPI()
    var hasMoreData                        = true
    var isLoading                          : Bool { get { return _isLoading} }
    var message                            : String { get { return _message} }
    var isFailed                           : Bool {  get { return _isFailed} }
    var profileData                        : LoginData? {   get { return _profileData} }
    var contactData                        : ContactData? {  get { return _contactData}  }
    var questionList                       : [QuestionsListData] { get {return _questionList  }  set {}  }
    var staticData                         : StaticPagesData? { get {return _staticData} set {} }
    var addressList                        : [AddressesData] { get {return _addressList  }  set {}  }

    
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

    func validateCreateAddress(id:Int?,area:String, streetName: String, buildingNum:String, floatNum:String,address:String ){
        if area.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "areaValidation".localized())
        } else if streetName.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "streetValidation".localized())
        } else if buildingNum.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "buildingNumValidation".localized())
        } else if floatNum.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "floatNumValidation".localized())
        } else if address.isBlank {
            toast = FancyToast(type: .error, title: "Error".localized(), message: "addressNumValidation".localized())
        }else {
            var  dic = [
                "address"       : address,
                "street_name"   :streetName,
                "building_num"  :buildingNum,
                "area"          :area,
                "float_num"     :floatNum]
            
            if id != nil {
                dic.updateValue("put", forKey: "_method")
                self.address(id: id ?? 0, method: .post, dic: dic)
            } else {  createAddress(dic: dic)              }
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
                Constants.accountStatus = response?.data?.status ?? 2
                Constants.phone = response?.data?.phone ?? ""
                Constants.userName = response?.data?.name ?? ""
                self._isActive = Constants.accountStatus == 2 ? true : false
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

    func addressesList() {
        _isLoading = true
        api.addresses() { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                self._addressList = data
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func address(id: Int, method: HTTPMethod,dic: [String: Any]) {
        _isLoading = true
        api.address(id: id, method: method, dic: dic) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                self._message = Result?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                if method == .delete { _addressList.removeAll { $0.id == id }}
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isCreateSuccess = true
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    func createAddress(dic: [String: Any]) {
        _isLoading = true
        api.createAddress(dic: dic){ [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                self._message = Result?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "Success".localized(), message: self._message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self._isCreateSuccess = true
                }
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
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
