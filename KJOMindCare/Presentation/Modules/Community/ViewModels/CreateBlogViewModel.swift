//
//  CreateBlogViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 17/12/25.
//

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

    private let createBlogUseCase: CreateBlogUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase

    nonisolated init(
        createBlogUseCase: CreateBlogUseCase, checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.createBlogUseCase = createBlogUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
    }

    var isFormValid: Bool {
        !title.isEmpty && !content.isEmpty
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

    func createBlog() async -> Bool {
        guard isFormValid else {
            errorMessage = "Por favor completa todos los campos"
            return false
        }

        guard let currentUser = checkUserSessionUseCase.execute() else {
            errorMessage = "No se pudo obtener el usuario actual"
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let blog = Blog(
                title: title,
                content: content,
                author: currentUser,
                categoryId: nil
            )

            let blogId = try await createBlogUseCase.execute(
                blogPost: blog,
                mediaData: selectedMediaData,
                mediaType: selectedMediaType
            )

            print("Blog creado exitosamente con ID: \(blogId)")
            showSuccessAlert = true

            // Reset form
            title = ""
            content = ""
            selectedMediaItem = nil
            selectedMediaData = nil
            selectedMediaType = nil

            return true
        } catch {
            print("Error al crear blog: \(error.localizedDescription)")
            errorMessage = "Error al crear el blog. Intenta nuevamente."
            return false
        }
    }

    func clearMedia() {
        selectedMediaItem = nil
        selectedMediaData = nil
        selectedMediaType = nil
    }
}
