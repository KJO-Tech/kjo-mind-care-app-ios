//
//  MoodEntry.swift
//  KJOMindCare
//
//  Created by Antigravity on 15/12/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Chronology
struct Chronology: Codable, Equatable {
    let calendarType: String
    let id: String
    
    static var iso8601: Chronology {
        Chronology(calendarType: "iso8601", id: "ISO")
    }
}

// MARK: - LocalDateTime
struct LocalDateTime: Codable, Equatable {
    let chronology: Chronology
    let dayOfMonth: Int
    let dayOfWeek: DayOfWeek
    let dayOfYear: Int
    let hour: Int
    let minute: Int
    let month: Month
    let monthValue: Int
    let nano: Int
    let second: Int
    let year: Int
    
    init(from date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: date
        )
        
        self.year = components.year ?? 0
        self.monthValue = components.month ?? 0
        self.month = Month(from: calendar, date: date)
        self.dayOfMonth = components.day ?? 0
        self.dayOfWeek = DayOfWeek(from: calendar, date: date)
        self.dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
        self.second = components.second ?? 0
        self.nano = components.nanosecond ?? 0
        self.chronology = .iso8601
    }
    
    func toDate() -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = monthValue
        components.day = dayOfMonth
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nano
        
        return Calendar.current.date(from: components)
    }
}

// MARK: - MoodEntry
public struct MoodEntry: Codable, Identifiable, Equatable {
    public let id: String
    let userId: String
    let mood: String
    let note: String
    let createdAt: Timestamp
    let localDateTime: LocalDateTime
    
    init(
        id: String = "",
        userId: String,
        mood: String,
        note: String = "",
        createdAt: Timestamp = Timestamp(),
        localDateTime: LocalDateTime? = nil
    ) {
        self.id = id
        self.userId = userId
        self.mood = mood
        self.note = note
        self.createdAt = createdAt
        self.localDateTime = localDateTime ?? LocalDateTime(from: createdAt.dateValue())
    }
    
    public func getLocalDateTime() -> Date {
        return localDateTime.toDate() ?? createdAt.dateValue()
    }
    
    public func getFormattedDate() -> String {
        let date = getLocalDateTime()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
