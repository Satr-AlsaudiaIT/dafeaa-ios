//
//  StringExt.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//

import Foundation
import UIKit

extension String {
    var isValidSaudiIBAN: Bool {
        // 1. Remove any whitespaces and convert the string to uppercase
        let cleanedIBAN = self.replacingOccurrences(of: " ", with: "").uppercased()
        
        // 2. Basic format validation:
        // Must start with "SA" followed by exactly 22 alphanumeric characters (24 characters total)
        let pattern = "^SA[A-Z0-9]{22}$"
        guard cleanedIBAN.range(of: pattern, options: .regularExpression) != nil else {
            return false
        }
        
        // 3. Rearrange the IBAN: Move the first 4 characters to the end of the string
        let splitIndex = cleanedIBAN.index(cleanedIBAN.startIndex, offsetBy: 4)
        let rearranged = String(cleanedIBAN[splitIndex...]) + String(cleanedIBAN[..<splitIndex])
        
        // 4. Convert letters to numeric values (A = 10, B = 11, ..., Z = 35)
        var numericIban = ""
        for char in rearranged {
            if char.isNumber {
                numericIban.append(char)
            } else if let asciiValue = char.asciiValue {
                // Calculate the numeric value for uppercase letters (ASCII 'A' is 65)
                let numericValue = Int(asciiValue) - 65 + 10
                numericIban.append(String(numericValue))
            }
        }
        
        // 5. Apply the MOD-97 algorithm
        // Processing digit by digit to prevent integer overflow (since the number is too large)
        var remainder = 0
        for char in numericIban {
            if let digit = char.wholeNumberValue {
                remainder = (remainder * 10 + digit) % 97
            }
        }
        
        // 6. A valid IBAN must leave a remainder of exactly 1
        return remainder == 1
    }
    
    //    var isValidSaudiIBAN: Bool {
//        // Remove spaces and convert to uppercase
//        let cleanedIBAN = self.replacingOccurrences(of: " ", with: "").uppercased()
//        
//        // Saudi IBAN format:
//        // - 2 letter country code (SA)
//        // - 2 digit check number
//        // - 2 digits bank code
//        // - 18 digit account number
//        // Total: 24 characters
//        let saudiIBANPattern = "^SA[0-9]{2}[0-9]{2}[0-9]{18}$"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", saudiIBANPattern)
//        
//        guard predicate.evaluate(with: cleanedIBAN) else {
//            return false
//        }
//        
//        // Additional check: Verify it's exactly 24 characters
//        return cleanedIBAN.count == 24
//    }
}



extension String {
    var isValidCardNumber: Bool {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 13 && cleaned.count <= 19 else { return false }
        guard cleaned.allSatisfy({ $0.isNumber }) else { return false }
        
        // Luhn algorithm validation
        var sum = 0
        let reversedCharacters = cleaned.reversed().map { String($0) }
        for (index, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
    
    var isValidMonth: Bool {
        guard let month = Int(self), month >= 1 && month <= 12 else { return false }
        return self.count == 2
    }
    
    var isValidCVV: Bool {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 3 && cleaned.count <= 4 else { return false }
        return cleaned.allSatisfy({ $0.isNumber })
    }
    
    func formatCardNumber() -> String {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
        let trimmed = String(cleaned.prefix(19))
        
        var formatted = ""
        for (index, character) in trimmed.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(character)
        }
        return formatted
    }
}

extension NSAttributedString {
    func toHTML() -> String {
        let fullString = self.string
        var html = ""
        var paragraphs: [String] = []
        var currentParagraph = ""
        
        self.enumerateAttributes(in: NSRange(location: 0, length: self.length), options: []) { attributes, range, _ in
            let substring = (fullString as NSString).substring(with: range)
            var wrappedText = substring
            
            // Check for underline first (innermost tag)
            if let underlineStyle = attributes[.underlineStyle] as? NSNumber, underlineStyle.intValue != 0 {
                wrappedText = "<u>\(wrappedText)</u>"
            }
            
            // Check for strikethrough
            if let strikethroughStyle = attributes[.strikethroughStyle] as? NSNumber, strikethroughStyle.intValue != 0 {
                wrappedText = "<s>\(wrappedText)</s>"
            }
            
            // Check for italic
            if let font = attributes[.font] as? UIFont {
                if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    wrappedText = "<i>\(wrappedText)</i>"
                }
                // Check for bold (outermost tag)
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    wrappedText = "<b>\(wrappedText)</b>"
                }
            }
            
            // Handle line breaks
            let lines = wrappedText.components(separatedBy: "\n")
            for (index, line) in lines.enumerated() {
                if index > 0 {
                    if line.isEmpty && currentParagraph.isEmpty {
                        // Double line break - new paragraph
                        if !currentParagraph.trimmingCharacters(in: .whitespaces).isEmpty {
                            paragraphs.append(currentParagraph)
                            currentParagraph = ""
                        }
                    } else {
                        // Single line break - add <br>
                        currentParagraph += "<br>"
                    }
                }
                currentParagraph += line
            }
        }
        
        // Add the last paragraph
        if !currentParagraph.trimmingCharacters(in: .whitespaces).isEmpty {
            paragraphs.append(currentParagraph)
        }
        
        // Wrap each paragraph in <p> tags
        if paragraphs.isEmpty {
            html = "<p>\(currentParagraph)</p>"
        } else {
            html = paragraphs.map { "<p>\($0)</p>" }.joined()
        }
        
        print("✅ HTML with proper line breaks: \(html)")
        
        return html.isEmpty ? self.string : html
    }
}

extension String {
    var hasMultipleWords: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        let words = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return words.count >= 2
    }
    
    var containsNumbers: Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var isValidCardHolderName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        guard hasMultipleWords else { return false }
        guard !containsNumbers else { return false }
        return true
    }
}

extension String {
    enum YearValidationError {
        case invalidFormat
        case expired
        case valid
    }
    
    var yearValidationStatus: YearValidationError {
        // Check format first
        guard self.count == 4 else {
            return .invalidFormat
        }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let maxYear = currentYear + 10
        
        guard let year = Int(self) else {
            return .invalidFormat
        }
        
        guard year >= currentYear && year <= maxYear else {
            return .expired
        }
        
        return .valid
    }
    
    var isValidYear: Bool {
        return yearValidationStatus == .valid
    }
}


