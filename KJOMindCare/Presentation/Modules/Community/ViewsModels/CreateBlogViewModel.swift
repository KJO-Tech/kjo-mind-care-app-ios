import SwiftUI
import UIKit

@MainActor
public class CreateBlogViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedCategory: BlogCategory = .other
    @Published var selectedImage: UIImage? = nil
    @Published var showImagePicker: Bool = false
    
    // Validation states
    @Published var titleError: Bool = false
    @Published var contentError: Bool = false
    
    public init() {}
    
    func validateForm() -> Bool {
        titleError = title.trimmingCharacters(in: .whitespaces).isEmpty
        contentError = content.trimmingCharacters(in: .whitespaces).isEmpty
        
        return !titleError && !contentError
    }
    
    func clearMedia() {
        selectedImage = nil
    }
    
    func publishBlog() -> Blog? {
        guard validateForm() else { return nil }
        

        let newBlog = Blog(
            authorName: "Current User",
            authorId: "current-user-id",
            title: title,
            content: content,
            category: selectedCategory,
            mediaType: selectedImage != nil ? .image : nil
        )
        
        resetForm()
        
        return newBlog
    }
    
    func resetForm() {
        title = ""
        content = ""
        selectedCategory = .other
        selectedImage = nil
        titleError = false
        contentError = false
    }
}
