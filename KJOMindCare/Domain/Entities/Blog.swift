//
//  Blog.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct Blog: Codable, Identifiable {
    var id: String
    var title: String
    var content: String
    var author: User
    var createdAt: Timestamp
    var updatedAt: Timestamp
    var mediaUrl: String?
    var mediaType: MediaType?
    var likes: Int
    var reaction: Int
    var comments: Int
    var categoryId: String?
    var status: BlogStatus
    
    init(
        id: String = "",
        title: String = "",
        content: String = "",
        author: User = User(uid: "", fullName: "", email: "", role: ""),
        createdAt: Timestamp = Timestamp(),
        updatedAt: Timestamp = Timestamp(),
        mediaUrl: String? = nil,
        mediaType: MediaType? = nil,
        likes: Int = 0,
        reaction: Int = 0,
        comments: Int = 0,
        categoryId: String? = nil,
        status: BlogStatus = .PENDING
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.author = author
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
        self.likes = likes
        self.reaction = reaction
        self.comments = comments
        self.categoryId = categoryId
        self.status = status
    }
    
    func getLocalDateTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(createdAt.seconds))
    }
    
    func getTimeAgo() -> String {
        let now = Date()
        let postDateTime = getLocalDateTime()
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: postDateTime,
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
}
