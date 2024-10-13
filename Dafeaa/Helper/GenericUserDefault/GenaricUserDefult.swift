//
//  GenericUserDefaults.swift
//
//
//  Created by Nura on 4/11/23.
//  Copyright © 2023 Nura. All rights reserved.
//

import Foundation
import UIKit

protocol GenericUserDefaultsProtocol
{
    func getValue(_ key: String) -> Any?
    
    func setValue(_ value: Any?, _ key: String)
    
    func removeValue(_ key: String)
    
    func removeAllUserDefaults()
    
    func setObject<T>(_ key: String, _ value: T?) where T : Encodable
    
    func getObject<T: Codable>(_ key: String, result: T.Type) -> T?
}

class GenericUserDefault: GenericUserDefaultsProtocol
{
    static var shared = GenericUserDefault()
    
    func getValue(_ key: String) -> Any?
    {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func setValue(_ value: Any?, _ key: String)
    {
        UserDefaults.init().set(value, forKey: key)
    }
    
    func removeValue(_ key: String)
    {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func removeAllUserDefaults()
    {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    func removeArrayOfKeys(keys: [String]) {
        for remove in keys {
            GenericUserDefault.shared.removeValue(remove)
        }
    }

    
    //save all object in user defaults
    func setObject<T>(_ key: String, _ value: T?) where T : Encodable
    {
        if value == nil
        {
            UserDefaults.standard.set(nil, forKey: key)
        }else {
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(value!)
            let json = String(data: jsonData!, encoding: String.Encoding.utf8)
            UserDefaults.standard.set(json, forKey: key)
        }
    }
    
    //save get object in userdefaults
    func getObject<T: Codable>(_ key: String, result: T.Type) -> T?
    {
        let getUserDefault: GenericUserDefaultsProtocol = GenericUserDefault()
        let jsonString = getUserDefault.getValue(key) as? String
        let jsonData = jsonString?.data(using: .utf8)
        let decoder = JSONDecoder()
        return try? decoder.decode(result, from: jsonData ?? Data())
    }
}
