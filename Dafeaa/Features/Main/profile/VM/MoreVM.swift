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
    @Published private var _questionList : [QuestionsListData] = []

    
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
    
    var questionList : [QuestionsListData] {
        get {return _questionList//[QuestionsListData(id: 0, question: "ما هو تطبيق دافع؟", answer: "ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟"),QuestionsListData(id: 1, question: "ما هو تطبيق دافع؟", answer: "ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟ما هو تطبيق دافع؟")]
        }
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

}

