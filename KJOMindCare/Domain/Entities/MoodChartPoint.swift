//
//  MoodChartPoint.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation

struct MoodChartPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Int
}

