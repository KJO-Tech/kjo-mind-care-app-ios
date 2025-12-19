import SwiftUI

struct EditProfileView: View {

    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject var viewModel: SettingsViewModel

    @State private var newName: String = ""
    @State private var newEmail: String = ""
    @State private var newImage: UIImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {

            if let img = newImage ?? viewModel.profileImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .onTapGesture { showImagePicker.toggle() }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(Image(systemName: "person").font(.largeTitle))
                    .onTapGesture { showImagePicker.toggle() }
            }

            TextField("Nombre", text: $newName)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .onAppear { newName = viewModel.name }

            TextField("Correo", text: $newEmail)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .onAppear { newEmail = viewModel.email }

            Button("Guardar Cambios") {
                Task {
                    await viewModel.saveProfile(name: newName, email: newEmail, image: newImage)
                    coordinator.pop()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage)
        }
    }
}

#Preview {
    let viewModel = DIContainer.shared.container.resolve(SettingsViewModel.self)!
    EditProfileView(viewModel: viewModel)
}
