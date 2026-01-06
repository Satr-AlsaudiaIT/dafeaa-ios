//
// IBANVM.swift
// Dafeaa
//
// Created by AMNY on 01/01/2026.
//

import Foundation

final class IBANVM: ObservableObject {
    @Published private var _isLoading = false
    @Published private var _isFailed = false
    @Published private var _ibanList: [IBANData] = []
    @Published var _isSuccess = false
    @Published var toast: FancyToast? = nil
    
    private var _message: String = ""
    let api: IBANAPIProtocol = IBANAPI() 
    
    var isLoading: Bool { return _isLoading }
    var isFailed: Bool { return _isFailed }
    var message: String { return _message }
    var ibanList: [IBANData] {
        get { return _ibanList }
        set { _ibanList = newValue }
    }
    
    // MARK: - Validation
    func validateIBAN(id: Int?, iban: String, name: String) {
        let dic: [String: Any] = [
            "iban": iban,
            "name": name
        ]
        
        if let id = id {
            updateIBAN(id: id, dic: dic)
        } else {
            createIBAN(dic: dic)
        }
    }

    var ibanDisplayList: [String] {
        return _ibanList.map { iban in
            let ibanNumber = iban.iban ?? ""
            let accountName = iban.name ?? ""
            return "\(ibanNumber) - \(accountName)"
        }
    }

    func getIBANId(displayText: String) -> Int {
        if let selectedIBAN = self._ibanList.first(where: { iban in
            let display = "\(iban.iban ?? "") - \(iban.name ?? "")"
            return display == displayText
        }) {
            return selectedIBAN.id ?? 0
        }
        return 0
    }

    
    // MARK: - APIs
    func getIBANs() {
        self._isLoading = true
        api.getIBANs { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._ibanList = response?.data ?? []
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func createIBAN(dic: [String: Any]) {
        self._isLoading = true
        api.createIBAN(dic: dic) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._isSuccess = true
                self.toast = FancyToast(type: .success, title: "", message: self._message)
                self.getIBANs()
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func updateIBAN(id: Int, dic: [String: Any]) {
        self._isLoading = true
        api.updateIBAN(id: id, dic: dic) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self._isSuccess = true
                self.toast = FancyToast(type: .success, title: "", message: self._message)
                self.getIBANs()
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func deleteIBAN(id: Int) {
        self._isLoading = true
        api.deleteIBAN(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self._message = response?.message ?? ""
                self._isLoading = false
                self._isFailed = false
                self.toast = FancyToast(type: .success, title: "", message: self._message)
                self.getIBANs()
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
}
