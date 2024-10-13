//
//  Calender.swift
//  
//
//  Created by AMN on 5/3/23.
//  Copyright © 2023  Nura. All rights reserved.
//

import Foundation
extension Calendar {
    func getNext6DaysOFWeek()->[Date]{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        //        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound).compactMap {
            calendar.date(byAdding: .day, value: $0 - 1 , to: today)
        }
        return days
    }
    
    func todayDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        print(dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
}
extension Date{
    func addingRemoving(days: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.day = days

        return calendar.date(byAdding: components, to: self)
     }
}
