//
//  MoodChartPoint.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation

public struct MoodChartPoint: Identifiable {
    public let id = UUID()
    public let day: String
    public let value: Double
    public let colorHex: String?

    public init(day: String, value: Double, colorHex: String? = nil) {
        self.day = day
        self.value = value
        self.colorHex = colorHex
    }
}
