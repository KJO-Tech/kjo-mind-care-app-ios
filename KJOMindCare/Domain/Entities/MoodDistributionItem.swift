//
//  MoodDistributionItem.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation

public struct MoodDistributionItem: Identifiable {
    public let id = UUID()
    public let emotion: String
    public let percentage: CGFloat
    public let displayPercentage: String
}
