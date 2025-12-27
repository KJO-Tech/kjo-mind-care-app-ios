import SwiftUI

struct CategoryRadioButton: View {
    let category: Category?
    let isSelected: Bool
    var isClearOption: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isClearOption {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(isSelected ? .theme.primary : .theme.textSecondary)
                    Text("Clear Filter")
                        .foregroundColor(isSelected ? .theme.primary : .theme.textSecondary)
                } else if let category = category {
                    // No icon in Category entity, simple text
                    Text(
                        category.getLocalizedName(
                            languageCode: Locale.current.language.languageCode?.identifier ?? "en")
                    )
                    .foregroundColor(isSelected ? .theme.primary : .theme.text)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.theme.primary)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.theme.textSecondary)
                }
            }
            .padding()
            .background(Color.theme.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 1)
            )
        }
    }
}
