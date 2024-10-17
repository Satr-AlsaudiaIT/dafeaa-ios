//
//  MoreVM.swift
//  Dafeaa
//
//  Created by AMNY on 13/10/2024.
//

import Foundation

final class MoreVM : ObservableObject {
    
    @Published var toast: FancyToast? = nil
    @Published private var _isLoading = false
    @Published private var _isFailed = false
    @Published private var _isLoginSuccess = false
    @Published private var _questionList : [QuestionsListData] = []
    @Published private var _staticData :  StaticPagesData?
    @Published private var _contactData :  ContactData?

    
    private var token = ""
    let api: MoreAPIProtocol = MoreAPI()
    
    private var _message: String = ""
    
    var isLoading: Bool {
        get { return _isLoading}
    }
    
    var message : String {
        get { return _message}
    }
    
    var isFailed: Bool {
        get { return _isFailed}
    }
    
    var contactData: ContactData? {
        get { return _contactData}
    }
    
    var isLoginSuccess : Bool {
        get {return _isLoginSuccess}
        set {}
    }
    
    var questionList : [QuestionsListData] {
        get {return _questionList//[QuestionsListData(id: 0, question: "ما هو تطبيق دافع؟", answer: "ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟"),QuestionsListData(id: 1, question: "ما هو تطبيق دافع؟", answer: "ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟")]
        }
        set {}
    }
    
    var staticData : StaticPagesData? {
        get {return _staticData}
        set {}
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
                self._isLoginSuccess = true
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
                
                self._isLoginSuccess = true
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
    
    
    func reset(){
        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
        GenericUserDefault.shared.setValue("", Constants.shared.token)
        MOLH.reset()
        
    }
}
