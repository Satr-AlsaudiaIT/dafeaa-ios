//
//  FinancialsVM.swift
//  Dafeaa
//
//  Created by AMNY on 27/04/2026.
//

import Foundation
import SwiftUI

class FinancialsVM: ObservableObject {
    @Published var isLoading = false
    @Published var isFailed = false
    @Published var toast: FancyToast? = nil
    
    @Published var financialData: FinancialInfoData?
    
    @Published var selectedIncomeSource: DropDownOption?
    @Published var selectedIncomeRange: DropDownOption?
    @Published var taxResidency: Bool = false
    @Published var isPep: Bool = false
    @Published var isSuccess: Bool = false
    
    
    let incomeSources: [DropDownOption] = [
        DropDownOption(id: 1, label: "income_salary".localized()),
        DropDownOption(id: 2, label: "income_freelance".localized()),
        DropDownOption(id: 3, label: "income_trade".localized()),
        DropDownOption(id: 4, label: "income_investment".localized()),
        DropDownOption(id: 5, label: "income_family_support".localized()),
        DropDownOption(id: 6, label: "income_other".localized())
    ]
    
    let incomeRanges: [DropDownOption] = [
        DropDownOption(id: 1, label: "range_less_5000".localized()),
        DropDownOption(id: 2, label: "range_5000_10000".localized()),
        DropDownOption(id: 3, label: "range_10000_20000".localized()),
        DropDownOption(id: 4, label: "range_more_20000".localized())
    ]
    
    let api = MoreAPI()
    
    func getFinancialInfo() {
        self.isLoading = true
        api.getFinancialInfo { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if let data = response?.data {
                        self.financialData = data
                        
                        // Populate UI States
                        self.selectedIncomeSource = self.incomeSources.first { $0.id == data.incomeSource }
                        self.selectedIncomeRange = self.incomeRanges.first { $0.id == data.incomeRange }
                        self.taxResidency = data.taxResidency ?? false
                        self.isPep = data.isPep ?? false
                    }
                case .failure(let error):
                    self.isFailed = true
                    self.toast = FancyToast(type: .error, title: "error".localized(), message: error.localizedDescription)
                }
            }
        }
    }
    
    func updateFinancialInfo(isEditMode:Bool) {
        guard let source = selectedIncomeSource?.id, let range = selectedIncomeRange?.id else {
            self.toast = FancyToast(type: .warning, title: "warning".localized(), message: "please_fill_all_fields".localized())
            return
        }
        
        self.isLoading = true
        api.updateFinancialInfo(incomeSource: source, incomeRange: range, taxResidency: taxResidency, isPep: isPep) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response?.status == true {
                        Constants.isFinancialInfoCompleted = true 
                        self.isSuccess = true
                        self.toast = FancyToast(type: .success, title: "success".localized(), message:  !isEditMode ? response?.message?.localized()  ?? "Saved successfully" :"account_verified_success".localized())
                    } else {
                        self.toast = FancyToast(type: .error, title: "error".localized(), message: response?.message ?? "")
                    }
                case .failure(let error):
                    self.toast = FancyToast(type: .error, title: "error".localized(), message: error.localizedDescription)
                }
            }
        }
    }
}
