//
//  MoodDistributionRow.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import SwiftUI
import Charts

import SwiftUI

struct MoodDistributionRow: View {
    let item: MoodDistributionItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(item.emotion)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                Text(item.displayPercentage)
                    .foregroundColor(.blue)
            }
            .font(.subheadline)
            
            
            ZStack(alignment: .leading) {
                
                Capsule()
                    .frame(height: 6)
                    .foregroundColor(Color.white.opacity(0.1))
                
               
                GeometryReader { geometry in
                    Capsule()
                        .frame(width: geometry.size.width * item.percentage, height: 6)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 6)
        }
    }
}
//#Preview {
//    MoodDistributionRow()
//}
