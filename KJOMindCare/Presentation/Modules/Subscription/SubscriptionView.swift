import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedCategories: Set<String> = []

    let categories = ["Meditation", "Yoga", "Sleep", "Focus", "Anxiety"]

    var body: some View {
        VStack {
            Text("Choose Your Plan")
                .font(.theme.title)
                .fontWeight(.bold)
                .padding()

            Text("Select categories you are interested in.")
                .foregroundColor(Color.theme.textSecondary)
                .padding(.bottom)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }) {
                            HStack {
                                Text(category)
                                    .foregroundColor(Color.theme.text)
                                Spacer()
                                if selectedCategories.contains(category) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.theme.primary)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }

            Spacer()

            HStack {
                Button("Skip") {
                    coordinator.showMain()
                }
                .foregroundColor(Color.theme.textSecondary)

                Spacer()

                Button("Continue") {
                    coordinator.showMain()
                }
                .foregroundColor(Color.theme.primaryContent)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.theme.primary)
                .cornerRadius(20)
            }
            .padding()
        }
        .background(Color.theme.background.ignoresSafeArea())
    }
}

#Preview {
    SubscriptionView()
}
