//
//  MoodsViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation

import SwiftUI

class MoodsViewModel: ObservableObject {
    


    @Published var selectedTimeframe: String = "Weekly" {
        didSet {
            loadData()
        }
    }
    

    @Published var chartData: [MoodChartPoint] = []
    @Published var distributionData: [MoodDistributionItem] = []
    

    @Published var mostFrequentMood: String = ""
    @Published var moodTrend: String = ""
    @Published var overallMood: String = ""
    
    let timeframes = ["Weekly", "Monthly"]
    
    init() {
        loadData()
    }
    
    func loadData() {
        switch selectedTimeframe {
        case "Weekly":
         
            chartData = [
                MoodChartPoint(day: "Mon", value: 3),
                MoodChartPoint(day: "Tue", value: 4),
                MoodChartPoint(day: "Wed", value: 5),
                MoodChartPoint(day: "Thu", value: 2),
                MoodChartPoint(day: "Fri", value: 4),
                MoodChartPoint(day: "Sat", value: 5),
                MoodChartPoint(day: "Sun", value: 4)
            ]
            
          
            mostFrequentMood = String(localized: "Alegre")
            moodTrend = "+15%"
            overallMood = String(localized: "Bueno")
            
            
            distributionData = [
                MoodDistributionItem(emotion: String(localized: "Alegre"), percentage: 0.4, displayPercentage: "40%"),
                MoodDistributionItem(emotion: String(localized: "Neutro"), percentage: 0.3, displayPercentage: "30%"),
                MoodDistributionItem(emotion: String(localized: "Cansado"), percentage: 0.3, displayPercentage: "30%")
            ]
            
        case "Monthly":
            
            chartData = [
                MoodChartPoint(day: "W1", value: 3),
                MoodChartPoint(day: "W2", value: 2),
                MoodChartPoint(day: "W3", value: 4),
                MoodChartPoint(day: "W4", value: 5)
            ]
            mostFrequentMood = String(localized: "Estresado")
            moodTrend = "-5%"
            overallMood = String(localized: "Regular")
            
            distributionData = [
                MoodDistributionItem(emotion: String(localized: "Estresado"), percentage: 0.5, displayPercentage: "50%"),
                MoodDistributionItem(emotion: String(localized: "Feliz"), percentage: 0.25, displayPercentage: "25%"),
                MoodDistributionItem(emotion: String(localized: "Triste"), percentage: 0.25, displayPercentage: "25%")
            ]
            
        default:
            break
        }
    }
}
