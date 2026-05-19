
////
////  UploadImage.swift

////

import UIKit
import Alamofire
//import MOLH

class MultipartUploadImage {
    
    static var shared = MultipartUploadImage()
    
    
    
    func uploadDoc(
        path: String,
        docsData: [Data],
        docsUrl: [URL],
        parameters: [String:Any],
        paramName: String? = nil,
        completion: @escaping (String?, NSError?,Int?) -> Void) {
            
            let toLanguage = MOLHLanguage.currentAppleLanguage()
            let token:String = "\(GenericUserDefault.shared.getValue(Constants.shared.token) ?? "no token")"
            
            AF.upload(multipartFormData: { (form: MultipartFormData) in
                
                for (key, value) in parameters {
                    if let temp = value as? String {
                        form.append(temp.data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Int {
                        form.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Double {
                        form.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Float {
                        form.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? NSArray {
                        temp.forEach({ element in
                            let keyObj = key + "[]"
                            if let string = element as? String {
                                form.append(string.data(using: .utf8)!, withName: keyObj)
                            } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                form.append(value.data(using: .utf8)!, withName: keyObj)
                            }
                        })
                    }
                }
                
                for i in 0 ..< docsData.count {
                    form.append(docsData[i], withName: "report_documents[]", fileName:docsUrl[i].lastPathComponent, mimeType: "*/*")
                    print(form)
                }
                
            },
                      to: "\(Constants.shared.baseURL)\(path)", method: .post , headers: [
                        "Authorization": "Bearer \(token)",
                        "Content-Type": "application/json",
                        "X-device": "ios",
                        "Accept": "multipart/form-data",
                        "X-Language":"\(toLanguage)",
                        "X-Portal": "Patient"
                      ])
            .response { resp in
                print("status code -----------:> \(resp.response?.statusCode ?? 0)")
                print("url is -----------:> \(Constants.shared.baseURL)\(path)")
                print("parameters is -----------:> \(parameters)")
                //            print("headers:-----------:>\(headers)")
                debugPrint(String(data: resp.data ?? Data(), encoding: .utf8) ?? "no data")
                switch resp.result {
                case .success(let value):
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: value!, options: []) as? [String : Any]
                        let message = jsonResult?["message"] as? String ?? ""
                        completion(message, nil, resp.response?.statusCode ?? 0)
                    } catch let error {
                        print("couldn't convert response to json:",error)
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "operation failed"])
                        completion("operation failed",error, resp.response?.statusCode ?? 0)
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "operation failed"])
                    completion("operation failed",error, resp.response?.statusCode ?? 0)
                    
                }
            }
        }
}


import UIKit
import Alamofire
//import MOLH

class MultipartUploadImages
{
    static var shared = MultipartUploadImages()
    func uploadImage(path: String, parameterS: Parameters, photos: [String:UIImage?], photosArray: [String: [UIImage]?]?, completion: @escaping (Int, String?, NSError?) -> Void) {
        let toLanguage = MOLHLanguage.currentAppleLanguage()
        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
        AF.upload(multipartFormData: { (form: MultipartFormData) in
            
            for (key, value) in parameterS {
                if let temp = value as? String {
                    form.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Double {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Float {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let arrayValue = value as? [Any] {
                    for (index, element) in arrayValue.enumerated() {
                        let keyObj = "\(key)[\(index)]"
                        if let productData = try? JSONSerialization.data(withJSONObject: element) {
                            form.append(productData, withName: keyObj)
                        }
                    }
                }
            }
            
            print(form.boundary)
            for (key, value) in photos {
                if let imageData = value?.jpegData(compressionQuality: 0.5) {
                    form.append(imageData, withName: key, fileName: "file.jpeg", mimeType: "image/png")
                }
            }
            
            if let photosArray = photosArray {
                for (key, value) in photosArray {
                    if let images = value {
                        for (index, image) in images.enumerated() {
                            let keyObj = "\(key)[\(index)]"
                            if let imageData = image.jpegData(compressionQuality: 0.5) {
                                print("index: \(index), imageData: \(imageData)")
                                form.append(imageData, withName: keyObj, fileName: "\(key)_\(index).jpeg", mimeType: "image/png")
                            }
                        }
                    }
                }
            }
        },
        to: "\(Constants.shared.baseURL)\(path)", method: .post, headers: [
            "Authorization": "Bearer \(token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Language": "\(toLanguage)",
            "Connection": "keep-alive",
            "x-source": "ios"
        ])
        .responseJSON { resp in
            print(resp)
            print(resp.response?.statusCode ?? 0)
            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
            debugPrint(resp)

            if resp.response?.statusCode == 401 {
                let onRetry: () -> Void = {
                    self.uploadImage(path: path, parameterS: parameterS, photos: photos, photosArray: photosArray, completion: completion)
                }
                SessionExpiryState.handleExpiry(onRetry: onRetry)
                return
            }

            switch resp.result {
            case .success(let value):
                print("value is \(value)")
                let data = value as? [String: Any] ?? [String: Any]()
                let message = data["message"] as? String ?? ""
                if resp.response?.statusCode ?? 0 == 200 {
                    completion(1, message, nil)
                } else {
                    let data = value as? [String: Any] ?? [String: Any]()
                    let message = data["message"] as? String ?? ""
                    completion(0, message, nil)
                }
            case .failure(_):
                let data = resp.value as? [String: Any] ?? [String: Any]()
                let message = data["message"] as? String
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message ?? ""])
                completion(0, nil, error)
            }
        }
    }

}



class MultipartUploadImageWithModel {
    typealias networkResultCompletion<M:Decodable> = (Result<M?, NSError>) -> Void
    
    typealias networkCompletionError = (NSError) -> Void
    
    typealias decodingCompletion<M:Codable> = (_ response:M?, _ error:NSError?) -> Void
    
    typealias unAuthorizedCompletion = (NSError) -> Void
    static var shared = MultipartUploadImageWithModel()

    
    func uploadImage<M: Codable>(path:String,pdfUrl: [String: URL?] ,parameterS: [String:Any],photos: [String: UIImage?],responseClass: M.Type, completion: @escaping (Result<M?, NSError>) -> Void)  {

        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
        let toLanguage = MOLHLanguage.currentAppleLanguage()
        AF.upload(multipartFormData: { (form: MultipartFormData) in
            
            for (key, value) in parameterS {
                if let temp = value as? String {
                    form.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Double {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Float {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                else if let arrayValue = value as? [Any] {
                for (index, element) in arrayValue.enumerated() {
                                        let keyObj = "\(key)[\(index)]"
                                        
                                        if let stringValue = element as? String {
                                            form.append(stringValue.data(using: .utf8)!, withName: keyObj)
                                        } else if let intValue = element as? Int {
                                            let value = "\(intValue)"
                                            form.append(value.data(using: .utf8)!, withName: keyObj)
                                        } else if let dictValue = element as? [String: Any], let jsonData = try? JSONSerialization.data(withJSONObject: dictValue) {
                                            form.append(jsonData, withName: keyObj)
                                        }
                                    }
                                }
            }
            // Upload PDF files
                        for (key, url) in pdfUrl {
                            if let pdfURL = url, let data = try? Data(contentsOf: pdfURL) {
                                form.append(data, withName: key, fileName: pdfURL.lastPathComponent, mimeType: "application/pdf")
                            }
                        }
                        
                        // Upload image files
                        for (key, image) in photos {
                            if let photo = image, let data = photo.jpegData(compressionQuality: 0.5) {
                                form.append(data, withName: key, fileName: "file.jpeg", mimeType: "image/jpeg")
                            }
                        }

        },
                  to: "\(Constants.shared.baseURL)\(path)", method: .post , headers: [
                "Authorization": "Bearer \(token ?? "")",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Language": "\(toLanguage)",
                "Connection": "keep-alive",
                "x-source": "ios"
        ])
        .responseJSON { response in
            print(response.response?.statusCode ?? 0)
            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
            debugPrint(response)
//            debugPrint(resp.response)

            print("status is -----------:> \(response.response?.statusCode ?? 0)")
            debugPrint(response)
            guard response.error == nil else {
                self.handleUrlError(Constants.shared.baseURL, error: response.error, completion: { Error in
                    completion(.failure(Error))
                    return
                })
                return
            }

            let onRetry: () -> Void = {
                self.uploadImage(path: path, pdfUrl: pdfUrl, parameterS: parameterS, photos: photos, responseClass: responseClass, completion: completion)
            }

            self.handleUrlStatusCode(targetPath: path, responseData: response.data, code: response.response?.statusCode, onRetry: onRetry) { isSuccess, error in

                guard isSuccess else {
                    completion(.failure(NSError(domain: Constants.shared.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: error ?? ""])))
                    return
                }

                guard let data = response.data else { return }

                self.decode(fromData: data, toObject: responseClass) { object, decodeError in
                    guard let object = object, decodeError == nil else {
                        completion(.failure(decodeError!))
                        return
                    }
                    completion(.success(object))
                }
            }
        }
    }

    func uploadOrderWithProduct<M: Codable>(path: String, parameterS: [String: Any], products: [[String: Any]], responseClass: M.Type, completion: @escaping (Result<M?, NSError>) -> Void) {

        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
        let toLanguage = MOLHLanguage.currentAppleLanguage()
        AF.upload(multipartFormData: { (form: MultipartFormData) in
            
            for (key, value) in parameterS {
                if let temp = value as? String {
                    form.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Double {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Float {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }
            
            // Handle 'products' array with images
            for (index, product) in products.enumerated() {
                for (key, value) in product {
                    let fieldName = "products[\(index)][\(key)]"
                    if let stringValue = value as? String {
                        form.append(stringValue.data(using: .utf8)!, withName: fieldName)
                    } else if let intValue = value as? Int {
                        form.append("\(intValue)".data(using: .utf8)!, withName: fieldName)
                    } else if let doubleValue = value as? Double {
                        form.append("\(doubleValue)".data(using: .utf8)!, withName: fieldName)
                    } else if let images = value as? [UIImage] {
                        for (imageIndex, image) in images.enumerated() {
                            if let imageData = image.jpegData(compressionQuality: 0.5) {
                                let imageFieldName = "products[\(index)][images][\(imageIndex)]"
                                form.append(imageData, withName: imageFieldName, fileName: "product_\(index)_image_\(imageIndex).jpeg", mimeType: "image/jpeg")
                            }
                        }
                    }
                }
            }
            

        },
                  to: "\(Constants.shared.baseURL)\(path)", method: .post, headers: [
            "Authorization": "Bearer \(token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Language": "\(toLanguage)",
            "Connection": "keep-alive",
            "x-source": "ios"
        ])
        .responseJSON { response in
            print(response.response?.statusCode ?? 0)
            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
            debugPrint(response)
//            debugPrint(resp.response)

            print("status is -----------:> \(response.response?.statusCode ?? 0)")
            debugPrint(response)
            guard response.error == nil else {
                self.handleUrlError(Constants.shared.baseURL, error: response.error, completion: { Error in
                    completion(.failure(Error))
                    return
                })
                return
            }

            let onRetry: () -> Void = {
                self.uploadOrderWithProduct(path: path, parameterS: parameterS, products: products, responseClass: responseClass, completion: completion)
            }

            self.handleUrlStatusCode(targetPath: path, responseData: response.data, code: response.response?.statusCode, onRetry: onRetry) { isSuccess, error in

                guard isSuccess else {
                    completion(.failure(NSError(domain: Constants.shared.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: error ?? ""])))
                    return
                }

                guard let data = response.data else { return }

                self.decode(fromData: data, toObject: responseClass) { object, decodeError in
                    guard let object = object, decodeError == nil else {
                        completion(.failure(decodeError!))
                        return
                    }
                    completion(.success(object))
                }
            }
        }

    }
    
    private func buildParams(task: Task) -> (params:[String: Any], encodingType: ParameterEncoding) {
        switch task {
        case .requestPlain:
            return ([:],URLEncoding.default)
        case .requestParameters(Parameters: let parameters, encoding: let encoding):
            return (parameters,encoding)
        }
    }
    
    private func handleUrlStatusCode(targetPath: String, responseData: Data?, code: Int?, onRetry: (() -> Void)? = nil, completion: @escaping (Bool, String?) -> Void) {

        guard let statusCode = code else {
            print("there is no status code")
            return
        }

        switch statusCode {
        case 200, 201:
            completion(true, nil)
        case 401:
            guard let data = responseData else { return }
            decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
                if targetPath == "auth/login" {
                    completion(false, result?.message)
                } else {
                    SessionExpiryState.handleExpiry(onRetry: onRetry)
                }
            }
        case 403:
            completion(true, nil)
        default:
            guard let data = responseData else { return }
            decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
                completion(false, result?.message)
            }
        }
    }
    
    private func handleUrlError(_ target:String, error:Error?,completion:@escaping networkCompletionError){
        guard let error = error as? URLError else {
            print("there is url error")
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
            completion(error)
            return
        }
        
        switch error.code {
        case .networkConnectionLost:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
            completion(error)
            return
        case .timedOut:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().requestTimeOut])
            completion(error)
            return
            
        case .notConnectedToInternet:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
            completion(error)
            return
            
        case .badServerResponse:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badServerResponse])
            completion(error)
            return
            
        case .badURL:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badUrl])
            completion(error)
            return
            
        default:
            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey:NetworkErrorMessage().genericError])
            completion(error)
            return
        }
        
        
    }
    
    private func decode<M:Codable>(fromData data:Data,
                                   toObject responseClass: M.Type, completion:@escaping decodingCompletion<M>){
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let model:M = try decoder.decode(responseClass, from: data)
            completion(model,nil)
        } catch let error {
            print("decodingError:- \(error)")
            let decodingError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : NetworkErrorMessage().decodingError])
            completion(nil,decodingError)
        }
        
    }
    
    
}


import Alamofire
import UIKit

extension MultipartUploadImageWithModel {

    func uploadOfferLinkV3<M: Codable>(
        path: String,
        parameterS: [String: Any],
        images: [UIImage],
        shippingCompanies: [String],
        responseClass: M.Type,
        completion: @escaping (Result<M?, NSError>) -> Void
    ) {
        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
        let toLanguage = MOLHLanguage.currentAppleLanguage()

        AF.upload(multipartFormData: { (form: MultipartFormData) in

            for (key, value) in parameterS {
                if let temp = value as? String {
                    form.append(temp.data(using: .utf8)!, withName: key)
                } else if let temp = value as? Int {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                } else if let temp = value as? Double {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                } else if let temp = value as? Float {
                    form.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }

            for (index, image) in images.enumerated() {
                let keyObj = "images[\(index)]"
                if let data = image.jpegData(compressionQuality: 0.5) {
                    form.append(
                        data,
                        withName: keyObj,
                        fileName: "image_\(index).jpeg",
                        mimeType: "image/jpeg"
                    )
                }
            }

            // 3) shipping_companies[i]
            for (index, company) in shippingCompanies.enumerated() {
                let keyObj = "shipping_companies[\(index)]"
                form.append(company.data(using: .utf8)!, withName: keyObj)
            }

        }, to: "\(Constants.shared.basURLV3)\(path)", method: .post, headers: [
            "Authorization": "Bearer \(token ?? "")",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Language": "\(toLanguage)",
            "Connection": "keep-alive",
            "x-source": "ios"
        ])
        .responseJSON { response in
            print(response.response?.statusCode ?? 0)
            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
            debugPrint(response)

            guard response.error == nil else {
                self.handleUrlError(Constants.shared.baseURL, error: response.error) { err in
                    completion(.failure(err))
                }
                return
            }

            let onRetry: () -> Void = {
                self.uploadOfferLinkV3(path: path, parameterS: parameterS, images: images, shippingCompanies: shippingCompanies, responseClass: responseClass, completion: completion)
            }

            self.handleUrlStatusCode(
                targetPath: path,
                responseData: response.data,
                code: response.response?.statusCode,
                onRetry: onRetry
            ) { isSuccess, error in

                guard isSuccess else {
                    completion(.failure(NSError(
                        domain: Constants.shared.baseURL,
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: error ?? ""]
                    )))
                    return
                }

                guard let data = response.data else { return }

                self.decode(fromData: data, toObject: responseClass) { object, decodeError in
                    guard let object, decodeError == nil else {
                        completion(.failure(decodeError!))
                        return
                    }
                    completion(.success(object))
                }
            }
        }
    }
}
