import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: SplashViewModel

    var body: some View {
        ZStack {
            Color.theme.primary
                .ignoresSafeArea()

            VStack {
                Image("kjo_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                Text("KJO Mind Care")
                    .font(.custom("Righteous-Regular", size: 36))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            viewModel.checkUserSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    if viewModel.isAuthenticated {
                        coordinator.showMain()
                    } else {
                        coordinator.showWelcome()
                    }
                }
            }
        }
    }
}

#Preview {
    let coordinator = AppCoordinator()
    let splashVM = DIContainer.shared.container.resolve(SplashViewModel.self)!
    
    SplashView(viewModel: splashVM)
        .environmentObject(coordinator)
}
