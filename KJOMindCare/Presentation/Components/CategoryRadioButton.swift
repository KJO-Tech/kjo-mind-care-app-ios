import SwiftUI

struct CategoryRadioButton: View {
    let category: BlogCategory?
    let isSelected: Bool
    let isClearOption: Bool
    let action: () -> Void
    
    init(
        category: BlogCategory?,
        isSelected: Bool,
        isClearOption: Bool = false,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.isSelected = isSelected
        self.isClearOption = isClearOption
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.purple : Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 14, height: 14)
                    }
                }
                
                Text(isClearOption ? "Clear selection" : category?.title ?? "")
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        CategoryRadioButton(
            category: nil,
            isSelected: true,
            isClearOption: true,
            action: {}
        )
        
        CategoryRadioButton(
            category: .sleep,
            isSelected: true,
            action: {}
        )
        
        CategoryRadioButton(
            category: .anxiety,
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
