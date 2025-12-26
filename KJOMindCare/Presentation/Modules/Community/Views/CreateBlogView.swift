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
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Blog title", text: $vm.title)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.titleError ? Color.red : Color.clear, lineWidth: 2)
                        )

                    if vm.titleError {
                        Text("El título no puede estar vacío")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.white)

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
                            .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextEditor(text: $vm.content)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.contentError ? Color.red : Color.clear, lineWidth: 2)
                        )

                    if vm.contentError {
                        Text("El contenido no puede estar vacío")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Image/Video (Optional)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    if let selectedImage = vm.selectedImage {
                        VStack(spacing: 12) {
                            MediaPreviewView(image: selectedImage)
                                .padding(.horizontal)

                            Button {
                                vm.clearMedia()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Clear Media")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }
                            .padding(.horizontal)
                        }
                    }

                    Button {
                        vm.showImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(
                                vm.selectedImage == nil
                                    ? "Select Image or Video" : "Change Image or Video")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple.opacity(0.6))
                        )
                    }
                    .padding(.horizontal)
                }

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
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
            .padding(.top)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle(vm.isEditMode ? "Edit Blog" : "Create Blog")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
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
