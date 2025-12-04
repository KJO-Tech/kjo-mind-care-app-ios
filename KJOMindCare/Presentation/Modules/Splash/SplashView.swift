import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color(.primary)  // Ensure this color exists in Assets
                .ignoresSafeArea()

            VStack {
                Image("kjo_icon")  // Placeholder logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)

                Text("KJO Mind Care")
                    .font(.largeTitle)
                    .fontWeight(.bold)
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
    SplashView()
}
