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
            // Try to load as image first
            if let imageData = try? await item.loadTransferable(type: Data.self) {
                selectedMediaData = imageData
                selectedMediaType = .IMAGE
                return
            }

            // If not an image, try as video
            if let videoData = try? await item.loadTransferable(type: Data.self) {
                selectedMediaData = videoData
                selectedMediaType = .VIDEO
            }
        } catch {
            print("Error loading media: \(error.localizedDescription)")
            errorMessage = "Error al cargar el archivo multimedia"
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

            if let image = selectedImage {
                // User selected a new image - upload it
                guard let data = image.jpegData(compressionQuality: 0.7) else {
                    print("Error converting image to data")
                    return false
                }

                let timestamp = Int(Date().timeIntervalSince1970)
                let uniqueFileName = "blog_\(sessionUser.uid)_\(timestamp)"

                // Use StorageService directly as requested
                mediaUrl = try await storageService.upload(
                    data: data,
                    folder: "blogs",
                    fileName: uniqueFileName
                )
                mediaType = .IMAGE
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
                    mediaType: selectedMediaType,
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
            print("Error \(isEditMode ? "updating" : "creating") blog: \(error)")
            errorMessage = "Error \(isEditMode ? "updating" : "creating") blog"
            return false
        }
    }

    func clearMedia() {
        selectedMediaItem = nil
        selectedMediaData = nil
        selectedMediaType = nil
    }
}
