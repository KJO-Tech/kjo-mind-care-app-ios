//
//  Month.swift
//  KJOMindCare
//
//  Created by Antigravity on 15/12/25.
//

import Foundation

enum Month: String, Codable {
    case JANUARY
    case FEBRUARY
    case MARCH
    case APRIL
    case MAY
    case JUNE
    case JULY
    case AUGUST
    case SEPTEMBER
    case OCTOBER
    case NOVEMBER
    case DECEMBER
    
    init(from calendar: Calendar, date: Date) {
        let month = calendar.component(.month, from: date)
        switch month {
        case 1: self = .JANUARY
        case 2: self = .FEBRUARY
        case 3: self = .MARCH
        case 4: self = .APRIL
        case 5: self = .MAY
        case 6: self = .JUNE
        case 7: self = .JULY
        case 8: self = .AUGUST
        case 9: self = .SEPTEMBER
        case 10: self = .OCTOBER
        case 11: self = .NOVEMBER
        case 12: self = .DECEMBER
        default: self = .JANUARY
        }
    }
}
