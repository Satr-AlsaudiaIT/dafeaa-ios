//
//  Date+ext.swift
//  
//
//  Created by M.Magdy on 07/09/2023.
//  Copyright © 2023  Nura. All rights reserved.
//

import Foundation
extension Date {
    func getStringValueFromDate() -> String{
        let date = self // Replace this with your date object

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
