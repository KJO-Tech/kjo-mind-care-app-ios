//
//  DayOfWeek.swift
//  KJOMindCare
//
//  Created by Antigravity on 15/12/25.
//

import Foundation

enum DayOfWeek: String, Codable {
    case MONDAY
    case TUESDAY
    case WEDNESDAY
    case THURSDAY
    case FRIDAY
    case SATURDAY
    case SUNDAY
    
    init(from calendar: Calendar, date: Date) {
        let weekday = calendar.component(.weekday, from: date)
        // Calendar.weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        switch weekday {
        case 1: self = .SUNDAY
        case 2: self = .MONDAY
        case 3: self = .TUESDAY
        case 4: self = .WEDNESDAY
        case 5: self = .THURSDAY
        case 6: self = .FRIDAY
        case 7: self = .SATURDAY
        default: self = .SUNDAY
        }
    }
}
