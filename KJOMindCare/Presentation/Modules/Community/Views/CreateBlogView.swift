import PhotosUI
import SwiftUI

public struct CreateBlogView: View {
    @EnvironmentObject var coordinator: CommunityCoordinator
    @StateObject private var vm: CreateBlogViewModel

    init(vm: CreateBlogViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)

                    TextField("Blog title", text: $vm.title)
                        .padding(12)
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .foregroundColor(Color.theme.text)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    vm.titleError ? Color.theme.error : Color.clear, lineWidth: 2)
                        )

                    if vm.titleError {
                        Text("El título no puede estar vacío")
                            .font(.theme.caption)
                            .foregroundColor(Color.theme.error)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)

                    Menu {
                        ForEach(vm.categories) { category in
                            Button(action: {
                                vm.selectedCategory = category
                            }) {
                                HStack {
                                    Text(
                                        category.getLocalizedName(
                                            languageCode: Locale.current.language.languageCode?
                                                .identifier ?? "en"))
                                    if vm.selectedCategory?.id == category.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                vm.selectedCategory?.getLocalizedName(
                                    languageCode: Locale.current.language.languageCode?.identifier
                                        ?? "en") ?? "Select Category"
                            )
                            .foregroundColor(Color.theme.text)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.theme.text)
                        }
                        .padding(12)
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)

                    TextEditor(text: $vm.content)
                        .padding(8)
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .foregroundColor(Color.theme.text)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    vm.contentError ? Color.theme.error : Color.clear, lineWidth: 2)
                        )

                    if vm.contentError {
                        Text("El contenido no puede estar vacío")
                            .font(.theme.caption)
                            .foregroundColor(Color.theme.error)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Image/Video (Optional)")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)
                        .padding(.horizontal)

                    if vm.selectedMediaType == .VIDEO, let videoData = vm.selectedMediaData {
                        // Video preview
                        VStack(spacing: 12) {
                            ZStack {
                                VideoPlayerView(videoData: videoData)
                                    .cornerRadius(12)

                                if vm.isLoading {
                                    ZStack {
                                        Color.black.opacity(0.5)
                                        ProgressView()
                                            .progressViewStyle(
                                                CircularProgressViewStyle(tint: Color.theme.text)
                                            )
                                            .scaleEffect(1.5)
                                    }
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)

                            Button {
                                vm.clearMedia()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Clear Video")
                                }
                                .font(.theme.subheadline)
                                .foregroundColor(Color.theme.text)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.theme.background.opacity(0.1))
                                )
                            }
                            .padding(.horizontal)
                        }
                    } else if let selectedImage = vm.selectedImage {
                        // Image preview
                        VStack(spacing: 12) {
                            ZStack {
                                MediaPreviewView(image: selectedImage)

                                if vm.isLoading {
                                    ZStack {
                                        Color.theme.shadow.opacity(0.5)
                                        ProgressView()
                                            .progressViewStyle(
                                                CircularProgressViewStyle(tint: Color.theme.text)
                                            )
                                            .scaleEffect(1.5)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            Button {
                                vm.clearMedia()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Clear Media")
                                }
                                .font(.theme.subheadline)
                                .foregroundColor(Color.theme.text)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.theme.shadow.opacity(0.1))
                                )
                            }
                            .padding(.horizontal)
                        }
                    }

                    Button {
                        vm.showImagePicker.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("Select Media")
                        }
                        .font(.theme.subheadline)
                        .foregroundColor(Color.theme.primaryContent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.primary.opacity(0.6))
                        )
                    }
                    .padding(.horizontal)
                    .photosPicker(
                        isPresented: $vm.showImagePicker,
                        selection: $vm.selectedMediaItem,
                        matching: .any(of: [.images, .videos])  // Allow both images and videos
                    )
                    .onChange(of: vm.selectedMediaItem) { newItem in
                        Task {
                            await vm.loadMediaData()
                        }
                    }
                }
                .padding(.vertical)

                Button(action: {
                    if vm.validateForm() {
                        Task {
                            if await vm.publishBlog() {
                                coordinator.pop()
                            }
                        }
                    }
                }) {
                    Text(vm.isEditMode ? "Update Blog" : "Publish Blog")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.primaryContent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.primary)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
            .padding(.top)
        }
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .navigationTitle(vm.isEditMode ? "Edit Blog" : "Create Blog")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .alert("¡Blog Enviado!", isPresented: $vm.showSuccessAlert) {
            Button("OK") {
                coordinator.pop()
            }
        } message: {
            Text(
                "Tu blog ha sido enviado exitosamente. Está pendiente de aprobación por un administrador."
            )
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") {
                vm.errorMessage = nil
            }
        } message: {
            if let error = vm.errorMessage {
                Text(error)
            }
        }
        .sheet(isPresented: $vm.showImagePicker) {
            ImagePickerView(
                selectedImage: $vm.selectedImage,
                isPresented: $vm.showImagePicker
            )
        }
    }
}

#Preview {
    let vm = DIContainer.shared.container.resolve(CreateBlogViewModel.self)!
    NavigationView {
        CreateBlogView(vm: vm)
    }
    .preferredColorScheme(.dark)
}
