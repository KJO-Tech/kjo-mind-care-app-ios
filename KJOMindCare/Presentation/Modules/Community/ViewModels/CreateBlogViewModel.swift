//
//  CreateBlogViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 17/12/25.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
class CreateBlogViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedMediaItem: PhotosPickerItem?
    @Published var selectedMediaData: Data?
    @Published var selectedMediaType: MediaType?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false

    // UI Properties from new design
    // UI Properties
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var titleError: Bool = false
    @Published var contentError: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var selectedImage: UIImage? = nil

    // Edit mode
    @Published var editingBlogId: String?
    var isEditMode: Bool { editingBlogId != nil }

    // Store original media to preserve if user doesn't change it
    private var originalMediaUrl: String?
    private var originalMediaType: MediaType?

    private let createBlogUseCase: CreateBlogUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase
    private let storageService: StorageService
    private let updateBlogUseCase: UpdateBlogUseCase

    private var cancellables = Set<AnyCancellable>()

    nonisolated init(
        createBlogUseCase: CreateBlogUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        getUserProfileUseCase: GetUserProfileUseCase,
        getCategoriesUseCase: GetCategoriesUseCase,
        storageService: StorageService,
        updateBlogUseCase: UpdateBlogUseCase
    ) {
        self.createBlogUseCase = createBlogUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        self.storageService = storageService
        self.updateBlogUseCase = updateBlogUseCase

        Task { await loadCategories() }
    }

    @MainActor
    func loadCategories() {
        getCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading categories: \(error)")
                }
            } receiveValue: { [weak self] categories in
                self?.categories = categories
                // Default selection if needed, or leave nil
                if let first = categories.first {
                    self?.selectedCategory = first
                }
            }
            .store(in: &cancellables)
    }

    func loadBlogForEditing(_ blog: Blog) {
        self.editingBlogId = blog.id
        self.title = blog.title
        self.content = blog.content
        self.selectedCategory = categories.first(where: { $0.id == blog.categoryId })

        // Store original media info to preserve if user doesn't change it
        self.originalMediaUrl = blog.mediaUrl
        self.originalMediaType = blog.mediaType

        // Load original image for preview if available
        if let mediaUrlString = blog.mediaUrl, blog.mediaType == .IMAGE,
            let url = URL(string: mediaUrlString)
        {
            Task { @MainActor in
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    self.selectedImage = UIImage(data: data)
                } catch {
                    print("Error loading original image for editing: \(error)")
                    self.errorMessage = "Error al cargar la imagen original."
                }
            }
        }
    }

    func loadMediaData() async {
        guard let item = selectedMediaItem else { return }

        do {
            // Detect media type based on the item's supported content types FIRST
            if let contentType = item.supportedContentTypes.first {
                let identifier = contentType.identifier.lowercased()

                print("📹 Content Type Identifier: \(identifier)")
                print("📹 Content Type: \(contentType)")

                // Check if it's a video
                if contentType.conforms(to: .movie) || contentType.conforms(to: .video) {
                    selectedMediaType = .VIDEO
                    print("✅ Detected media type: VIDEO")

                    // For videos, just load the data (no UIImage)
                    if let data = try await item.loadTransferable(type: Data.self) {
                        selectedMediaData = data
                        // Create a placeholder image for video preview
                        selectedImage = createVideoPlaceholder()
                    }
                    return
                }

                // Check if it's an image
                if contentType.conforms(to: .image) {
                    selectedMediaType = .IMAGE
                    print("✅ Detected media type: IMAGE")

                    // For images, load as UIImage
                    if let data = try await item.loadTransferable(type: Data.self) {
                        selectedMediaData = data
                        selectedImage = UIImage(data: data)
                    }
                    return
                }

                // Unknown type
                print("⚠️ Unknown media type: \(contentType), defaulting to IMAGE")
                selectedMediaType = .IMAGE
            }

            // Fallback: try to load as image
            if let data = try await item.loadTransferable(type: Data.self) {
                selectedMediaData = data
                selectedImage = UIImage(data: data)
                selectedMediaType = .IMAGE
            }
        } catch {
            print("❌ Error loading media: \(error)")
            errorMessage = "Error al cargar el archivo multimedia"
        }
    }

    // Helper to create a placeholder image for video
    private func createVideoPlaceholder() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Play icon
            let playIconSize: CGFloat = 60
            let playIconRect = CGRect(
                x: (size.width - playIconSize) / 2,
                y: (size.height - playIconSize) / 2,
                width: playIconSize,
                height: playIconSize
            )

            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: playIconRect.minX + 15, y: playIconRect.minY))
            path.addLine(to: CGPoint(x: playIconRect.maxX - 5, y: playIconRect.midY))
            path.addLine(to: CGPoint(x: playIconRect.minX + 15, y: playIconRect.maxY))
            path.close()
            path.fill()
        }
    }

    func validateForm() -> Bool {
        titleError = title.trimmingCharacters(in: .whitespaces).isEmpty
        contentError = content.trimmingCharacters(in: .whitespaces).isEmpty
        return !titleError && !contentError && selectedCategory != nil
    }

    func publishBlog() async -> Bool {
        guard validateForm() else { return false }

        guard let sessionUser = checkUserSessionUseCase.execute() else {
            errorMessage = "No active session"
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Fetch full profile
            let author: User
            let profile = try await getUserProfileUseCase.execute(userId: sessionUser.uid)

            author = profile ?? sessionUser

            var mediaUrl: String? = nil
            var mediaType: MediaType? = nil

            if let image = selectedImage, selectedMediaType == .IMAGE {
                // User selected a new image - upload it
                guard let data = image.jpegData(compressionQuality: 0.7) else {
                    print("Error converting image to data")
                    return false
                }

                let timestamp = Int(Date().timeIntervalSince1970)
                let uniqueFileName = "blog_\(sessionUser.uid)_\(timestamp).jpg"

                mediaUrl = try await storageService.upload(
                    data: data,
                    folder: "blogs",
                    fileName: uniqueFileName,
                    resourceType: nil  // nil defaults to "image" in Cloudinary
                )
                mediaType = .IMAGE
            } else if let videoData = selectedMediaData, selectedMediaType == .VIDEO {
                // User selected a new video - upload it
                let timestamp = Int(Date().timeIntervalSince1970)
                let uniqueFileName = "blog_\(sessionUser.uid)_\(timestamp).mp4"

                mediaUrl = try await storageService.upload(
                    data: videoData,
                    folder: "blogs",
                    fileName: uniqueFileName,
                    resourceType: "video"  // Specify video resource type for Cloudinary
                )
                mediaType = .VIDEO
            } else if isEditMode {
                // Editing mode and no new image selected - preserve original media
                mediaUrl = originalMediaUrl
                mediaType = originalMediaType
            }

            if let editingId = editingBlogId {
                // Update existing blog
                var updatedBlog = Blog(
                    id: editingId,
                    title: title,
                    content: content,
                    author: author,
                    mediaUrl: mediaUrl,
                    mediaType: mediaType,  // Use the determined mediaType (either new or original)
                    categoryId: selectedCategory?.id
                )

                try await updateBlogUseCase.execute(blogPost: updatedBlog)
                print("Blog updated with ID: \(editingId)")
            } else {
                // Create new blog
                let blog = Blog(
                    title: title,
                    content: content,
                    author: author,
                    mediaUrl: mediaUrl,
                    mediaType: mediaType,  // Use determined mediaType (was missing before)
                    categoryId: selectedCategory?.id
                )

                let blogId = try await createBlogUseCase.execute(blogPost: blog)
                print("Blog created with ID: \(blogId)")
            }

            showSuccessAlert = true

            // Cleanup
            title = ""
            content = ""
            clearMedia()
            editingBlogId = nil

            return true
        } catch {
            print("Error uploading blog: \(error)")
            errorMessage =
                isEditMode
                ? "Error al actualizar el blog. Por favor, intenta de nuevo."
                : "Error al crear el blog. Por favor, intenta de nuevo."
            return false
        }
    }

    func clearMedia() {
        selectedImage = nil
        selectedMediaItem = nil
        selectedMediaData = nil
        selectedMediaType = nil

        // Also clear original media if in edit mode (user wants to remove the image)
        if isEditMode {
            originalMediaUrl = nil
            originalMediaType = nil
        }
    }
}
