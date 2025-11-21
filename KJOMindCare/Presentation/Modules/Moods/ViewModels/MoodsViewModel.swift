//
//  MoodsViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation


class MoodsViewModel: ObservableObject {
    @Published var selectedTimeframe: String = "Week"
    let timeframes = ["Week", "Month"]
    
    
    @Published var chartData: [MoodChartPoint] = []
    @Published var distributionData: [MoodDistributionItem] = []
    
   
    let mostFrequentMood = "Happy"
    let moodTrend = "Improving"
    let overallMood = "Neutral"

    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        
        chartData = [
            MoodChartPoint(day: "Sat", value: 0),
            MoodChartPoint(day: "Sun", value: 3),
            MoodChartPoint(day: "Mon", value: 4),
            MoodChartPoint(day: "Tue", value: 1),
            MoodChartPoint(day: "Wed", value: 1),
            MoodChartPoint(day: "Thu", value: 4),
            MoodChartPoint(day: "Fri", value: 0)
        ]
        
        distributionData = [
            MoodDistributionItem(emotion: "Happy", percentage: 0.20, displayPercentage: "20%"),
            MoodDistributionItem(emotion: "Anxious", percentage: 0.20, displayPercentage: "20%"),
            MoodDistributionItem(emotion: "Sad", percentage: 0.20, displayPercentage: "20%")
        ]
    }
}
