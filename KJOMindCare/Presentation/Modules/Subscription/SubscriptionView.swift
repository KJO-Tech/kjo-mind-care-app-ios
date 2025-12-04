import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedCategories: Set<String> = []

    let categories = ["Meditation", "Yoga", "Sleep", "Focus", "Anxiety"]

    var body: some View {
        VStack {
            Text("Choose Your Focus")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("Select categories you are interested in.")
                .foregroundColor(.gray)
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
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedCategories.contains(category) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
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
                .foregroundColor(.gray)

                Spacer()

                Button("Continue") {
                    coordinator.showMain()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(20)
            }
            .padding()
        }
    }
}

#Preview {
    SubscriptionView()
}
