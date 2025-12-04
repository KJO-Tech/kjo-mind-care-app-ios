//
//  Comment.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct Comment: Codable, Identifiable {
    var id: String
    var author: User
    var content: String
    var createdAt: Timestamp
    var parentCommentId: String?
    var replies: [Comment]
    
    init(
        id: String = "",
        author: User = User(uid: "", fullName: "", email: "", role: ""),
        content: String = "",
        createdAt: Timestamp = Timestamp(),
        parentCommentId: String? = nil,
        replies: [Comment] = []
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.parentCommentId = parentCommentId
        self.replies = replies
    }
    
    func getLocalDateTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(createdAt.seconds))
    }
    
    func getTimeAgo() -> String {
        let now = Date()
        let commentDateTime = getLocalDateTime()
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: commentDateTime,
            to: now
        )
        
        // Detect language from device locale
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let isSpanish = languageCode.starts(with: "es")
        
        if let years = components.year, years > 0 {
            if isSpanish {
                return years == 1 ? "Hace 1 año" : "Hace \(years) años"
            } else {
                return years == 1 ? "1 year ago" : "\(years) years ago"
            }
        }
        
        if let months = components.month, months > 0 {
            if isSpanish {
                return months == 1 ? "Hace 1 mes" : "Hace \(months) meses"
            } else {
                return months == 1 ? "1 month ago" : "\(months) months ago"
            }
        }
        
        if let days = components.day, days > 0 {
            if isSpanish {
                return days == 1 ? "Hace 1 día" : "Hace \(days) días"
            } else {
                return days == 1 ? "1 day ago" : "\(days) days ago"
            }
        }
        
        if let hours = components.hour, hours > 0 {
            if isSpanish {
                return hours == 1 ? "Hace 1 hora" : "Hace \(hours) horas"
            } else {
                return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
            }
        }
        
        if let minutes = components.minute, minutes > 0 {
            if isSpanish {
                return minutes == 1 ? "Hace 1 minuto" : "Hace \(minutes) minutos"
            } else {
                return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
            }
        }
        
        return isSpanish ? "Ahora" : "Just now"
    }
    
    func isMine(currentUserId: String) -> Bool {
        return author.uid == currentUserId
    }
}
