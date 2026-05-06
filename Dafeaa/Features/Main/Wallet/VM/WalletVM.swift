//
//  WalletVM.swift
//  Dafeaa
//
//  Created by AMNY on 25/10/2024.
//

import SwiftUI

class WalletVM: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var toast: FancyToast?      = nil
    @Published private var _isLoading      = false
    @Published private var _isFailed       = false
    @Published private var _processList    : [HomeModelData] = []
    @Published private var _processListCount    : Int = 1
    
    @Published private var _walletData       : WalletModel?
    
    @Published var _getData                : Bool = false
    @Published var _isSuccess              = false
    @Published var acceptQRResult: AcceptQRResult? = nil
    @Published var isQRLoading: Bool = false
    @Published var qrAcceptError: String? = nil
    @Published var isExporting: Bool = false
    @Published var exportedFileURL: URL? = nil
//    @Published var showShareSheet: Bool = false
    private var _message                   : String = ""
    private var token                      = ""
    let api                                : HomeAPIProtocol = HomeAPI()
    var hasMoreData                        = true
    var isLoading    : Bool                { get { return _isLoading  }      }
    var message      : String              { get { return _message    }      }
    var isFailed     : Bool                { get { return _isFailed   }      }
    var processList  : [HomeModelData]     { get { return _processList} set{}}
    var walletData   : WalletModel?        { get { return _walletData   } set{}}
    
    //MARK: - APIs
    
    func wallet(skip: Int, animated: Bool = true) {
        if skip == 0 {
            _isLoading = animated ; hasMoreData = true ;
            animated ? ( self._processList.removeAll()):()
        }
        if self._processList.count >= self._processListCount {
            self.hasMoreData = false
        }
        guard hasMoreData  else { _isLoading = false ;return }
        _isLoading = true
        api.wallet(skip: skip) { [weak self] (Result) in
            guard let self = self else { return }
            self._isLoading = false
            switch Result {
            case .success(let Result):
                guard let data = Result?.data else { return }
                self._processListCount = Result?.count ?? 0
                self._walletData = Result
                
                if skip == 0 {
                    self._processList = data
                } else { self._processList.append(contentsOf: data)
                }
                
            case .failure(let error):
                self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                self._isLoading = false
                self._isFailed = true
                self.toast = FancyToast(type: .error, title: "Error".localized(), message: self._message)
            }
        }
    }
    
    func acceptQR(qrCode: String) {
        isQRLoading = true
        acceptQRResult = nil
        qrAcceptError = nil
        
        api.acceptQR(qrCode: qrCode) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isQRLoading = false
                switch result {
                case .success(let response):
                    guard let data = response else { return }
                    if data.success == true {
                        self.acceptQRResult = .success(transferId: data.transferId, transId: data.transId)
                    } else {
                        self.acceptQRResult = .failure
                        self.qrAcceptError = "payment_failed".localized()
                    }
                case .failure(let error):
                    self.acceptQRResult = .failure
                    self.qrAcceptError = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "")"
                }
            }
        }
    }
    
    func exportWalletOperations() {
            self.isExporting = true
            
            api.downloadExport { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isExporting = false
                    
                    switch result {
                    case .success(let fileURL):
                        self.exportedFileURL = fileURL
                        self.toast = FancyToast(
                            type: .success,
                            title: "success".localized(),
                            message: "file_saved_success".localized()
                        )
                        
                    case .failure(let error):
                        self._isFailed = true
                        self._message = "\(error.userInfo[NSLocalizedDescriptionKey] ?? "Error".localized())"
                        
                        self.toast = FancyToast(
                            type: .error,
                            title: "Error".localized(),
                            message: self._message
                        )
                    }
                }
            }
        }
}

enum AcceptQRResult: Equatable {
    case success(transferId: Int?, transId: String?)
    case failure
}

enum QRResultState { case success, failure }
