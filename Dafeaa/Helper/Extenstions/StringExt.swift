//
//  StringExt.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//

import Foundation

extension String {
    var isValidSaudiIBAN: Bool {
        // Remove spaces and convert to uppercase
        let cleanedIBAN = self.replacingOccurrences(of: " ", with: "").uppercased()
        
        // Saudi IBAN format:
        // - 2 letter country code (SA)
        // - 2 digit check number
        // - 2 digits bank code
        // - 18 digit account number
        // Total: 24 characters
        let saudiIBANPattern = "^SA[0-9]{2}[0-9]{2}[0-9]{18}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", saudiIBANPattern)
        
        guard predicate.evaluate(with: cleanedIBAN) else {
            return false
        }
        
        // Additional check: Verify it's exactly 24 characters
        return cleanedIBAN.count == 24
    }
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
    
    var isValidYear: Bool {
        guard let year = Int(self), year >= 2026 && year <= 2050 else { return false }
        return self.count == 4
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
