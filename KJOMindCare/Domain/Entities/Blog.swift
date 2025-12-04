import Foundation

struct Blog: Identifiable {
    let id = UUID()
    let authorName: String
    let title: String
    let category: String
    let likes: Int
    let comments: Int
    let createdAt: Date
}
extension Blog {
    static let mockList: [Blog] = [
        Blog(
            authorName: "Kevin",
            title: "Test notificación",
            category: "Notificaciones",
            likes: 0,
            comments: 2,
            createdAt: Date().addingTimeInterval(-11*86400)
        ),
        Blog(
            authorName: "Kevin Briceño Quezada",
            title: "Salud Mental",
            category: "Salud Mental 2",
            likes: 3,
            comments: 12,
            createdAt: Date().addingTimeInterval(-12*86400)
        )
    ]
}
