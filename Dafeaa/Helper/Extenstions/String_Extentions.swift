//
//  File.swift
//  Movie App
//
//  Created by AMN on 4/5/23.
//  Copyright © 2023 Nura. All rights reserved.

//

import Foundation
import UIKit
// MARK: - Date

extension Date {
    func formatDateFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
}
// MARK: - string


extension String
{
    // Handling Localization ....
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    var wordCount: Int {
        let regex = try? NSRegularExpression(pattern: "\\w+")
        return regex?.numberOfMatches(in: self, range: NSRange(location: 0, length: self.utf16.count)) ?? 0
    }
    
    func dateBackendFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: MOLHLanguage.isArabic() ? "ar" : "en")
        let date = dateFormatter.date(from: self)
        dateFormatter.locale = Locale(identifier: "en")
        print(dateFormatter.string(from: date ?? Date()))
        return dateFormatter.string(from: date ?? Date())
    }
   
    func toDate() -> Date? {
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"
          
          // Convert the string to a Date object
          return formatter.date(from: self)
      }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        
        if let formattedDate = dateFormatter.date(from: self) {
            return dateFormatter.string(from: formattedDate)
        } else {
            return self
        }
    }
//    //Html String Attributed
//    var htmlToAttributedString: NSAttributedString?
//    {
//        guard let data = data(using: .utf8) else { return NSAttributedString() }
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return NSAttributedString()
//        }
//    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
}
extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(from: Int,to:Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
        
    }
}

extension String{
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
   
    // validate name
    var isValidName: Bool {
        if(self.count>=2 && self.count<=30){
            return true
        }else{
            return false
        }
    }
    var isValidReason: Bool {
        if(self.count>=3 && self.count<=30){
            return true
        }else{
            return false
        }
    }
    
    // validate name
    var isValidAddress: Bool {
        if(self.count>=2 && self.count<=50){
            return true
        }else{
            return false
        }
    }
    
    // validate full name
    var validateFullName : Bool {
          let nameArray: [String] = self.split { $0 == " " }.map { String($0) }
          if nameArray.count >= 3 {
              return true
          }else{
              return false
          }
      }
    //Validate Phone
    
    func isValidPhone() -> Bool {
        if self.hasPrefix("1") && self.count == 10 {
            return true
        } else {
            return false
        }
    }
    
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    func isPasswordConfirm(password: String , confirmPassword : String) -> Bool {
        if password == confirmPassword{
            return true
        }else{
            return false
        }
    }
    
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    //validate Password
    var isValidPassword: Bool {
        if(self.count >= 8 ){
            return true
        }else{
            return false
        }
    }
    
    func to12hFormat() -> String {
        let dateAsString = self
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        df.locale = Locale(identifier: "en")
        if let date = df.date(from: dateAsString){
            df.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
            df.dateFormat = "hh:mm a"
            
            let time12 = df.string(from: date )
            return time12
        }else {
            return self}
    }
    
    func getDateAndTime() -> String {
        let full: String = self
        let fullDateArr = full.components(separatedBy:"T")
        let time: String = fullDateArr[1]
        let fullTimeArr = time.components(separatedBy:"Z")
        let timeFinal: String = fullTimeArr[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from: timeFinal)
        guard let ConvertDate  = date else {return ""}
        let string  = dateFormatter.string(from: ConvertDate)
        
        return string
    }
    
    func getFormateDateAndTime() -> String {
        let full: String = self
        let fullDateArr = full.components(separatedBy:"T")
        let dateNotFormate = fullDateArr[0]
        let time: String = fullDateArr[1]
        let fullTimeArr = time.components(separatedBy:"Z")
        let timeFinal: String = fullTimeArr[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from: timeFinal)
        guard let ConvertDate  = date else {return ""}
        let string  = dateFormatter.string(from: ConvertDate)
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateConverted = dateFormatter.date(from: dateNotFormate)
        guard let ConvertDateFormate  = dateConverted else {return ""}
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        let stringDate  = dateFormatter.string(from: ConvertDateFormate)

        return   stringDate + " " + string.to12hFormat()
    }
    func getDateInFormYYYYMMDD() -> Date {
        let timeFinal: String = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: timeFinal) else { return Date() }
        return date
    }
    
    func getDateFromHHMMSS() -> Date {
        let timeFinal: String = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let date = dateFormatter.date(from: timeFinal) else { return Date() }
        return date
    }
    func getFormateDateDayMonth() -> String {
        let full: String = self
        let fullDateArr = full.components(separatedBy:"T")
        let dateNotFormate = fullDateArr[0]
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateConverted = dateFormatter.date(from: dateNotFormate)
        guard let ConvertDateFormate  = dateConverted else {return ""}
        dateFormatter.dateFormat = "d MMM"
        dateFormatter.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        let stringDate  = dateFormatter.string(from: ConvertDateFormate)

        return   stringDate
    }
    func convertTo24HourFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "HH:mm:ss"
            print(dateFormatter.string(from: date))
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    public var convertDigitsToEng : String {
            let arabicNumbers = ["٠": "0","١": "1","٢": "2","٣": "3","٤": "4","٥": "5","٦": "6","٧": "7","٨": "8", "٩": "9"]
            var txt = self
            let _ = arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
            return txt
    }
    public var convertDigitsBetweenLang : String {
        if Constants.shared.isAR == false {
            let arabicNumbers = ["٠": "0","١": "1","٢": "2","٣": "3","٤": "4","٥": "5","٦": "6","٧": "7","٨": "8", "٩": "9"]
            var txt = self
            let _ = arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
            return txt
        }
       else if Constants.shared.isAR == true {
            let arabicNumbers = [
                "0": "٠",
                "1": "١",
                "2": "٢",
                "3": "٣",
                "4": "٤",
                "5": "٥",
                "6": "٦",
                "7": "٧",
                "8": "٨",
                "9": "٩"
            ]
            var txt = self
            let _ = arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
            return txt
        }
        else {
            return self
        }
    }
    func convertEngToPersianNum()->String {
        if Constants.shared.isAR == true {
            var data = self
            let arabicNumbers = [
                "0": "٠",
                "1": "١",
                "2": "٢",
                "3": "٣",
                "4": "٤",
                "5": "٥",
                "6": "٦",
                "7": "٧",
                "8": "٨",
                "9": "٩"
            ]
                   
            for (key,value) in arabicNumbers {
                if data.contains(key){
                    data = data.replacingOccurrences(of: key, with: value)
                }
            }
            return data
        }
        else {
            return self
        }
    }
    
}

extension String {
    func toUIImage(completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: self) else {
            completion(nil)
            return
        }
        
        // Download the image data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // Convert the data to UIImage
            let image = UIImage(data: data)
            completion(image)
        }
        
        task.resume()
    }
}



extension String {
    func toDateOnly() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            let attributedString = try NSMutableAttributedString(
                           data: data,
                           options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                           documentAttributes: nil
                       )

                       let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.foregroundColor, value: UIColor(resource: .black222222), range: range) // Change UIColor.red to your desired color
            // Set text alignment based on the language
                        let paragraphStyle = NSMutableParagraphStyle()
            if Constants.shared.isAR {
                            paragraphStyle.alignment = .right
                        } else {
                            paragraphStyle.alignment = .left
                        }
            
                        paragraphStyle.minimumLineHeight = 25.0
                        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

                        // Set the system font with light weight
                        let font = UIFont.systemFont(ofSize: 15, weight: .light)
                        attributedString.addAttribute(.font, value: font, range: range)


                       return attributedString
        } catch {
            return NSAttributedString()
        }
    }
  
}



