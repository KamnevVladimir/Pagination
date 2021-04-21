//
//  DateHelper.swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import Foundation
import SwiftDate

final class DateHelper {
    static func getBirthday(from dateString: String) -> String {
        guard let date = Date(dateString) else { return "" }
        return date.toFormat("dd.MM.yyyy")
    }
    
    static func getAge(from dateString: String) -> String {
        guard let birthdayDate = Date(dateString) else { return "" }
        guard let age = (Date() - birthdayDate).year else { return "" }
        return String(age)
    }
    
    static func getLocalTime(with offset: String) -> String {
        guard let offsetFloat = Float(offset.replacingOccurrences(of: ":", with: ".")) else { return "" }
        
        let aNumber = modf(offsetFloat)
        let minutes = Int(aNumber.1 * 100).minutes
        let hours = Int(aNumber.0).hours
        let localDate = Date() + hours + minutes
        
        return localDate.toFormat("HH:mm")
    }
}
