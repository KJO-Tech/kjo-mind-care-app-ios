import Foundation

public struct Blog: Identifiable, Codable {
    public let id: UUID
    public let authorName: String
    public let authorId: String
    public let title: String
    public let content: String
    public let category: BlogCategory
    public var likes: Int
    public var isLiked: Bool
    public let comments: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let mediaUrl: String?
    public let mediaType: MediaType?
    
    // Helper para saber si es el blog del usuario actual
    public func isMyBlog(currentUserId: String) -> Bool {
        return authorId == currentUserId
    }
    
    // Para previews y desarrollo
    init(
        id: UUID = UUID(),
        authorName: String,
        authorId: String = UUID().uuidString,
        title: String,
        content: String = "",
        category: BlogCategory,
        likes: Int = 0,
        isLiked: Bool = false,
        comments: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mediaUrl: String? = nil,
        mediaType: MediaType? = nil
    ) {
        self.id = id
        self.authorName = authorName
        self.authorId = authorId
        self.title = title
        self.content = content
        self.category = category
        self.likes = likes
        self.isLiked = isLiked
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
    }
}
extension Blog {
    static let mockList: [Blog] = [
        Blog(
            authorName: "Kevin",
            title: "Test notificación",
            content: "notificaciones",
            category: .other,
            likes: 0,
            comments: 2,
            createdAt: Date().addingTimeInterval(-11*86400)
        ),
        Blog(
            authorName: "Kevin Briceño Quezada",
            title: "Salud Mental",
            content: "La salud mental es importante",
            category: .anxiety,
            likes: 9,
            isLiked: true,
            comments: 4,
            createdAt: Date().addingTimeInterval(-4*30*86400),
            mediaUrl: "https://example.com/salud-mental.jpg",
            mediaType: .image
        ),
        Blog(
            authorName: "María González",
            title: "Tips para dormir mejor",
            content: "Consejos para mejorar la calidad del sueño y descansar adecuadamente cada noche. La importancia de establecer una rutina.",
            category: .sleep,
            likes: 15,
            comments: 8,
            createdAt: Date().addingTimeInterval(-5*86400)
        ),
        Blog(
            authorName: "Carlos Ruiz",
            title: "Meditación matutina",
            content: "Rutina de meditación para empezar el día con energía positiva y calma mental.",
            category: .meditation,
            likes: 22,
            comments: 5,
            createdAt: Date().addingTimeInterval(-2*86400)
        ),
        Blog(
            authorName: "Ana López",
            title: "Manejo del estrés laboral",
            content: "Técnicas efectivas para reducir el estrés en el trabajo y mantener el balance vida-trabajo.",
            category: .stress,
            likes: 18,
            comments: 10,
            createdAt: Date().addingTimeInterval(-7*86400)
        ),
        Blog(
            authorName: "José Martínez",
            title: "Alimentación balanceada",
            content: "Cómo mantener una dieta equilibrada y nutritiva para mejorar tu bienestar general.",
            category: .nutrition,
            likes: 12,
            comments: 6,
            createdAt: Date().addingTimeInterval(-3*86400)
        )
    ]
}
