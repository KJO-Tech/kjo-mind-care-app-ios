import SwiftUI

struct SubscriptionCard: View {

    let item: SubscriptionType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: item.icon)
                    .font(.title2)

                Text(item.title)
                    .font(.headline)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .frame(height: 130)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray)
            )
        }
    }
}

#Preview {
    SubscriptionCard(
        item: SubscriptionType.meditation,
        isSelected: true,
        onTap: {}
    ).padding()
}
