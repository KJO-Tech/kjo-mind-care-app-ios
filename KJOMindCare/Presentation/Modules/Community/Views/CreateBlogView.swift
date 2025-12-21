import SwiftUI
import PhotosUI

public struct CreateBlogView: View {
    @StateObject var viewModel: CreateBlogViewModel
    @EnvironmentObject var coordinator: CommunityCoordinator

    public var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.text)
                        
                        TextField("Escribe el título de tu blog", text: $viewModel.title)
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.textSecondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Content Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contenido")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.text)
                        
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.textSecondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Media Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Multimedia (Opcional)")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.text)
                        
                        PhotosPicker(
                            selection: $viewModel.selectedMediaItem,
                            matching: .any(of: [.images, .videos])
                        ) {
                            HStack {
                                Image(systemName: viewModel.selectedMediaItem != nil ? "checkmark.circle.fill" : "photo.on.rectangle.angled")
                                    .foregroundColor(viewModel.selectedMediaItem != nil ? .green : Color.theme.primary)
                                
                                Text(viewModel.selectedMediaItem != nil ? "Archivo seleccionado" : "Seleccionar imagen o video")
                                    .font(.theme.body)
                                    .foregroundColor(Color.theme.text)
                                
                                Spacer()
                                
                                if viewModel.selectedMediaItem != nil {
                                    Button(action: {
                                        viewModel.clearMedia()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .onChange(of: viewModel.selectedMediaItem) { _ in
                            Task {
                                await viewModel.loadMediaData()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.theme.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Publish Button
                    Button(action: {
                        Task {
                            let success = await viewModel.createBlog()
                            if success {
                                coordinator.pop()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primaryContent))
                            }
                            
                            Text(viewModel.isLoading ? "Publicando..." : "Publicar Blog")
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.primaryContent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid && !viewModel.isLoading ? Color.theme.primary : Color.theme.primary.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationTitle("Crear Blog")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let createBlogVM = DIContainer.shared.container.resolve(CreateBlogViewModel.self)!
    let coordinator = CommunityCoordinator()
    
    NavigationView {
        CreateBlogView(viewModel: createBlogVM)
            .environmentObject(coordinator)
    }
}
