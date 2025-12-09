import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.theme.primary  // Ensure this color exists in Assets
                .ignoresSafeArea()

            VStack {
                Image("kjo_icon")  // Placeholder logo
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
            // Simulate loading delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    coordinator.showWelcome()
                }
            }
        }
    }
}

#Preview {
    let coordinator = AppCoordinator()
    SplashView().environmentObject(coordinator)
}
