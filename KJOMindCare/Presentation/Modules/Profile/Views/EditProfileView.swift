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

            // Image Picker
            ZStack(alignment: .bottomTrailing) {
                if let newImg = newImage {
                    Image(uiImage: newImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } else if let currentImg = viewModel.profileImage {
                } else if let url = viewModel.profileImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(Color.theme.card)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.theme.card)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(Color.theme.card)
                        )
                }

                Image(systemName: "camera.fill")
                    .padding(8)
                    .background(Color.theme.primary)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 20)

            Text(String(localized: "profile.edit.tap_to_change"))
                .font(.theme.caption)
                .foregroundColor(Color.theme.textSecondary)

            VStack(spacing: 16) {
                TextField(String(localized: "auth.register.fullName.title"), text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    // Or custom styling if available, using standard for now or similar to theme
                    // Let's use standard modifier for theming if we had a custom field component
                    .padding()
                    .background(Color.theme.card)
                    .cornerRadius(8)
                    .foregroundColor(Color.theme.text)
                    .font(.theme.body)
                // If placeholder color needed, requires custom view modifiers or placeholder view

                TextField(String(localized: "auth.email"), text: $newEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.theme.card)  // Consistent with theme
                    .cornerRadius(8)
                    .foregroundColor(Color.theme.text)
                    .font(.theme.body)
                    .disabled(true)  // Typically email change requires re-auth or special flow
                    .opacity(0.7)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                Task {
                    await viewModel.saveProfile(name: newName, email: newEmail, image: newImage)
                    coordinator.pop()
                }
            }) {
                Text(String(localized: "common.save_changes"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle(String(localized: "profile.edit_profile"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage)
        }
        .onAppear {
            // Populate fields from ViewModel properties
            newName = viewModel.userName
            newEmail = viewModel.userEmail
        }
    }
}
