//
//  MoodDistributionRow.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import SwiftUI

struct MoodDistributionRow: View {
    let item: MoodDistributionItem
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(item.emotion)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(item.displayPercentage)
                    .foregroundColor(color)
            }
            .font(.subheadline)
            
            
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundColor(Color.white.opacity(0.1))
                
                
                GeometryReader { geometry in
                    Capsule()
                        .frame(width: geometry.size.width * item.percentage, height: 6)
                        .foregroundColor(color)
                }
            }
            .frame(height: 6)
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            MoodDistributionRow(
                item: MoodDistributionItem( emotion: "Alegre", percentage: 0.7, displayPercentage: "70%"),
                color: .yellow
            )
            MoodDistributionRow(
                item: MoodDistributionItem(emotion: "Triste", percentage: 0.3, displayPercentage: "30%"),
                color: .blue
            )
        }
        .padding()
    }
}
