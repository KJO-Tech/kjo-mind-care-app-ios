//
//  ProfileView.swift
//  KJOMindCare
//
//  Created by Sebas on 10/12/25.
//

import SwiftUI


struct ProfileSettingView: View {
    
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // FOTO DE PERFIL
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("No Img")
                                    .foregroundColor(.gray)
                            )
                    }

                    // NOMBRE
                    Text(viewModel.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    // EMAIL
                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Divider().padding(.vertical)

                    // ESTADÍSTICAS (sin crear otros modelos)
                    VStack(spacing: 10) {
                        HStack {
                            Text("Planes completados")
                            Spacer()
                            Text("\(viewModel.completedPlans)")
                                .bold()
                        }

                        HStack {
                            Text("Días estudiados")
                            Spacer()
                            Text("\(viewModel.studyDays)")
                                .bold()
                        }

                        HStack {
                            Text("Racha actual")
                            Spacer()
                            Text("\(viewModel.streak)")
                                .bold()
                        }
                    }
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    // CONFIGURACIÓN DE NOTIFICACIONES
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notificaciones")
                            .font(.headline)

                        Toggle("Activar recordatorios", isOn: $viewModel.notificationsEnabled)

                        if viewModel.notificationsEnabled {
                            DatePicker("Hora del recordatorio",
                                       selection: $viewModel.notificationTime,
                                       displayedComponents: .hourAndMinute)
                        }
                    }
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    // MODO OSCURO
                    Toggle(isOn: $viewModel.isDarkMode) {
                        Text("Modo oscuro")
                    }
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    // BOTÓN PARA EDITAR PERFIL
                    NavigationLink(destination: EditProfileView(viewModel: viewModel)) {
                        Text("Editar perfil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                }
                .padding()
            }
            .navigationTitle("Perfil")
        }
    }
}

#Preview {
    ProfileSettingView(viewModel: <#T##SettingsViewModel#>)
}
