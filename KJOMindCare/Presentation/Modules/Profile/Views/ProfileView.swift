import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ---------- TITULO PRINCIPAL ----------
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    // ---------- FOTO Y DATOS ----------
                    VStack(spacing: 12) {
                        if let img = viewModel.profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        if let p = viewModel.profile {
                            Text(p.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(p.email)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    
                    

                    // ---------- ESTADÍSTICAS ----------
                    HStack(spacing: 16) {
                        statBox(title: "Check-ins", value: "28", systemIcon: "")
                        statBox(title: "Post", value: "14", systemIcon: "")
                        statBox(title: "Badges", value: "3", systemIcon: "")
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    
                    
                    
                  
                    
                    // ---------- SUBTITULO SETTINGS ----------
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {

                            accountNavigationRow(
                                icon: "pencil",
                                title: "Edit Profile",
                                destination: EditProfileView(viewModel: viewModel)
                            )
                            Divider()

                            
                           
                            accountNavigationRow(
                                icon: "checklist",
                                title: "Edit subscription",
                                destination: EditSubsView(viewModel: viewModel)
                            )
                            Divider()

                            Divider()
                            
                            
                            

                            // --- TOGGLE NOTIFICACIONES DIARIAS ---
                            VStack(alignment: .leading, spacing: 12) {

                                HStack {
                                    Image(systemName: "bell.badge")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)

                                    Toggle(isOn: Binding(
                                        get: { viewModel.profile?.notificationsEnabled ?? false },
                                        set: { newValue in
                                            Task {
                                                await viewModel.updateNotifications(
                                                    enabled: newValue,
                                                    hour: viewModel.profile?.notificationHour ?? Date()
                                                )
                                            }
                                        }
                                    )) {
                                        Text("Notification")
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)

                                // 👇 APARECE SOLO SI ESTÁ ACTIVO
                                if viewModel.profile?.notificationsEnabled == true {

                                    HStack {
                                        Text("Hour")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Spacer()

                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { viewModel.profile?.notificationHour ?? Date() },
                                                set: { newHour in
                                                    Task {
                                                        await viewModel.updateNotifications(
                                                            enabled: true,
                                                            hour: newHour
                                                        )
                                                    }
                                                }
                                            ),
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut, value: viewModel.profile?.notificationsEnabled)


                            Divider()

                            // --- TOGGLE MODO OSCURO ---
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.purple)
                                    .frame(width: 24)

                                Toggle(isOn: Binding(
                                    get: { viewModel.profile?.darkModeEnabled ?? false },
                                    set: { newValue in
                                        Task {
                                            await viewModel.updateDarkMode(newValue)
                                        }
                                    }
                                )) {
                                    Text("Modo Oscuro")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.top, 6)

                    
                    
                    // ---------- LOG OUT BUTTON FULL WIDTH + CENTERED ----------
                    Button(action: {
                        print("Cerrando sesión...")
                    }) {
                        HStack {
                            Spacer() // centro

                            Image(systemName: "arrow.uturn.left.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)

                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.red)

                            Spacer() // centro
                        }
                        .padding(.vertical, 14)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    .shadow(radius: 1)

                    
                    
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .onAppear {
                Task { await viewModel.loadProfile() }
            }
            .sheet(isPresented: $showEdit) {
                EditProfileView(viewModel: viewModel)
            }
        }
    }
    
    
    // MARK: - COMPONENTES AUXILIARES
    
    private func statBox(title: String, value: String, systemIcon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemIcon)
                .font(.title2)
                .foregroundColor(.accentColor)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 110, height: 100)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
    
    private func accountRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.blue)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
    
    private func supportRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.green)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        
        
        
    }
    
    
    
    
    private func accountNavigationRow(
        icon: String,
        title: String,
        destination: some View
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.blue)

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }


}

#Preview {
    ProfileView()
}

