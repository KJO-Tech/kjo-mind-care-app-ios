//
//  MoodDistributionItem.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation


struct MoodDistributionItem: Identifiable {
    let id = UUID()
    let emotion: String
    let percentage: CGFloat 
    let displayPercentage: String
}
