//
// HomeAPIProtocol.swift
//
//

import Foundation
import Alamofire
protocol HomeAPIProtocol {
    func home(Completion: @escaping (Result<HomeModel?, NSError>) -> Void)
    func wallet(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void)
    func operations(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void)
    func processApplePay(amount: Int, token: String, Completion: @escaping (Result<ApplePayResponse?, NSError>) -> Void)
    func generateQR(amount: String,reason: String, Completion: @escaping (Result<QRCodeModel?, NSError>) -> Void)
    func cancelQR(qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void)
    func checkQRStatus(qrCode: String, Completion: @escaping (Result<QRStatusModel?, NSError>) -> Void)
    func acceptQR(qrCode: String, Completion: @escaping (Result<AcceptQRResponse?, NSError>) -> Void)
    func downloadExport(Completion: @escaping (Result<URL, NSError>) -> Void)}

class HomeAPI: BaseAPI<HomeNetwork>, HomeAPIProtocol
{
    func home(Completion: @escaping (Result<HomeModel?, NSError>) -> Void){
        self.fetchData(target: .home, responseClass: HomeModel.self) { (result) in
            Completion(result)
        }
    }
    
    func wallet(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void){
        self.fetchData(target: .wallet(skip: skip), responseClass: WalletModel.self) { (result) in
            Completion(result)
        }
    }
    
    func operations(skip: Int, Completion: @escaping (Result<WalletModel?, NSError>) -> Void){
        self.fetchData(target: .operations(skip: skip), responseClass: WalletModel.self) { (result) in
            Completion(result)
        }
    }
    
    func processApplePay(amount: Int, token: String, Completion: @escaping (Result<ApplePayResponse?, NSError>) -> Void) {
        self.fetchApplePayData(target: .applePay(amount: amount, token: token), responseClass: ApplePayResponse.self) { (result) in
            Completion(result)
        }
    }
    
    func generateQR(amount: String,reason: String, Completion: @escaping (Result<QRCodeModel?, NSError>) -> Void) {
        self.fetchData(target: .generateQR(amount: amount,reason: reason), responseClass: QRCodeModel.self) { result in
            Completion(result)
        }
    }
    
    func cancelQR(qrCode: String, Completion: @escaping (Result<GeneralModel?, NSError>) -> Void) {
        self.fetchData(target: .cancelQR(qrCode: qrCode), responseClass: GeneralModel.self) { result in
            Completion(result)
        }
    }
    
    func checkQRStatus(qrCode: String, Completion: @escaping (Result<QRStatusModel?, NSError>) -> Void) {
        self.fetchData(target: .checkQRStatus(qrCode: qrCode), responseClass: QRStatusModel.self) { result in
            Completion(result)
        }
    }
    
    func acceptQR(qrCode: String, Completion: @escaping (Result<AcceptQRResponse?, NSError>) -> Void) {
        self.fetchData(target: .acceptQR(qrCode: qrCode), responseClass: AcceptQRResponse.self) { result in
            Completion(result)
        }
    }
    
    func downloadExport(Completion: @escaping (Result<URL, NSError>) -> Void) {
            let target = HomeNetwork.exportOperations
            let url = target.baseURL + target.path
            
            let headersDict = target.headers ?? [:]
            let httpHeaders = HTTPHeaders(headersDict)
            
            let destination: DownloadRequest.Destination = { temporaryURL, response in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileManager = FileManager.default
                
                let exactServerName = response.suggestedFilename ?? "WalletExport.xlsx"
                
                let urlForExtraction = URL(fileURLWithPath: exactServerName)
                let fileExtension = urlForExtraction.pathExtension
                let originalName = urlForExtraction.deletingPathExtension().lastPathComponent
                
                var fileURL = documentsURL.appendingPathComponent(exactServerName)
                var counter = 1
                
                while fileManager.fileExists(atPath: fileURL.path) {
                    let newFileName = fileExtension.isEmpty
                        ? "\(originalName) (\(counter))"
                        : "\(originalName) (\(counter)).\(fileExtension)"
                    
                    fileURL = documentsURL.appendingPathComponent(newFileName)
                    counter += 1
                }
                
                return (fileURL, [.createIntermediateDirectories])
            }
            
            AF.download(url, headers: httpHeaders, to: destination)
                .response { response in
                    if let error = response.error {
                        let nsError = NSError(domain: "DownloadError", code: error.responseCode ?? 500, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
                        Completion(.failure(nsError))
                    } else if let fileURL = response.fileURL {
                        Completion(.success(fileURL))
                    } else {
                        let nsError = NSError(domain: "DownloadError", code: 500, userInfo: [NSLocalizedDescriptionKey: "unknown_download_error".localized()])
                        Completion(.failure(nsError))
                    }
                }
        }}
