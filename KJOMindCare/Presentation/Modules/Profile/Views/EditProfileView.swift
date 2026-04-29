import SwiftUI

public struct EditProfileView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject var viewModel: SettingsViewModel
    @State private var newName: String = ""
    @State private var newEmail: String = ""
    @State private var newImage: UIImage? = nil
    @State private var showImagePicker = false

    public var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = newImage {
                    Image(uiImage: uiImage).profileCircleStyle()
                } else if let url = viewModel.profileImageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().profileCircleStyle()
                    } placeholder: {
                        ProgressView().frame(width: 120, height: 120)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color.theme.card)
                }

                Image(systemName: "camera.fill")
                    .padding(8)
                    .background(Color.theme.primary)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
            .onTapGesture { showImagePicker.toggle() }

            VStack(spacing: 16) {
                TextField("Nombre Completo", text: $newName)
                    .padding()
                    .background(Color.theme.card)
                    .cornerRadius(12)

                TextField("Email", text: $newEmail)
                    .disabled(true)
                    .padding()
                    .background(Color.theme.card)
                    .cornerRadius(12)
                    .opacity(0.6)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                Task {
                    await viewModel.saveProfile(
                        name: newName, email: newEmail, image: newImage)

                    try? await Task.sleep(nanoseconds: 300_000_000)

                
                    await MainActor.run {
                        coordinator.pop()
                    }
                }
            }) {
                Text("common.save_changes")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .onAppear {
            newName = viewModel.userName
            newEmail = viewModel.userEmail
        }
        .sheet(isPresented: $showImagePicker) { ImagePicker(image: $newImage) }
    }
}


extension View {
    func profileCircleStyle() -> some View {
        self.aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}
