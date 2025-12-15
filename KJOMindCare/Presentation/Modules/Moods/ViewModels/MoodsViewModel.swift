//
//  MoodsViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation
import SwiftUI
import Combine

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
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let timeframes = ["Weekly", "Monthly"]
    
    private let getMoodEntriesUseCase: GetMoodEntriesByDateRangeUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(
        getMoodEntriesUseCase: GetMoodEntriesByDateRangeUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.getMoodEntriesUseCase = getMoodEntriesUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        loadData()
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        // Get current user
        checkUserSessionUseCase.execute()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] userResource -> AnyPublisher<Resource<[MoodEntry]>, Never> in
                guard let self = self else {
                    return Just(.error("Session error")).eraseToAnyPublisher()
                }
                
                switch userResource {
                case .success(let user):
                    let (startDate, endDate) = self.getDateRange()
                    return self.getMoodEntriesUseCase.execute(
                        userId: user.uid,
                        startDate: startDate,
                        endDate: endDate
                    )
                case .error(let message):
                    return Just(.error(message)).eraseToAnyPublisher()
                default:
                    return Just(.error("Unknown error")).eraseToAnyPublisher()
                }
            }
            .sink { [weak self] resource in
                guard let self = self else { return }
                self.isLoading = false
                
                switch resource {
                case .success(let entries):
                    self.processEntries(entries)
                case .error(let message):
                    self.errorMessage = message
                    self.setEmptyData()
                default:
                    self.setEmptyData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func getDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case "Weekly":
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            return (startOfWeek, endOfWeek)
        case "Monthly":
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            return (startOfMonth, endOfMonth)
        default:
            return (now, now)
        }
    }
    
    private func processEntries(_ entries: [MoodEntry]) {
        if entries.isEmpty {
            setEmptyData()
            return
        }
        
        // Calculate chart data
        chartData = calculateChartData(from: entries)
        
        // Calculate distribution
        distributionData = calculateDistribution(from: entries)
        
        // Calculate most frequent mood
        mostFrequentMood = calculateMostFrequentMood(from: entries)
        
        // Calculate trend
        moodTrend = calculateTrend(from: entries)
        
        // Calculate overall mood
        overallMood = calculateOverallMood(from: entries)
    }
    
    private func calculateChartData(from entries: [MoodEntry]) -> [MoodChartPoint] {
        let calendar = Calendar.current
        var dataPoints: [MoodChartPoint] = []
        
        switch selectedTimeframe {
        case "Weekly":
            // Group by day of week
            let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let grouped = Dictionary(grouping: entries) { entry -> Int in
                let weekday = calendar.component(.weekday, from: entry.getLocalDateTime())
                return weekday == 1 ? 6 : weekday - 2 // Convert to Mon=0, Sun=6
            }
            
            for (index, day) in weekdays.enumerated() {
                let dayEntries = grouped[index] ?? []
                let avgValue = dayEntries.isEmpty ? 0 : dayEntries.map { getMoodValue($0.mood) }.reduce(0, +) / dayEntries.count
                dataPoints.append(MoodChartPoint(day: day, value: avgValue))
            }
            
        case "Monthly":
            // Group by week
            let weeks = ["W1", "W2", "W3", "W4"]
            let grouped = Dictionary(grouping: entries) { entry -> Int in
                let weekOfMonth = calendar.component(.weekOfMonth, from: entry.getLocalDateTime())
                return min(weekOfMonth - 1, 3)
            }
            
            for (index, week) in weeks.enumerated() {
                let weekEntries = grouped[index] ?? []
                let avgValue = weekEntries.isEmpty ? 0 : weekEntries.map { getMoodValue($0.mood) }.reduce(0, +) / weekEntries.count
                dataPoints.append(MoodChartPoint(day: week, value: avgValue))
            }
            
        default:
            break
        }
        
        return dataPoints
    }
    
    private func calculateDistribution(from entries: [MoodEntry]) -> [MoodDistributionItem] {
        let moodCounts = Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }
        
        let total = entries.count
        
        return moodCounts.map { mood, count in
            let percentage = CGFloat(count) / CGFloat(total)
            let displayPercentage = "\(Int(percentage * 100))%"
            return MoodDistributionItem(
                emotion: mood,
                percentage: percentage,
                displayPercentage: displayPercentage
            )
        }
        .sorted { $0.percentage > $1.percentage }
        .prefix(3)
        .map { $0 }
    }
    
    private func calculateMostFrequentMood(from entries: [MoodEntry]) -> String {
        let moodCounts = Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? String(localized: "N/A")
    }
    
    private func calculateTrend(from entries: [MoodEntry]) -> String {
        guard entries.count >= 2 else { return "0%" }
        
        let calendar = Calendar.current
        let now = Date()
        let midpoint: Date
        
        switch selectedTimeframe {
        case "Weekly":
            midpoint = calendar.date(byAdding: .day, value: -3, to: now)!
        case "Monthly":
            midpoint = calendar.date(byAdding: .day, value: -15, to: now)!
        default:
            return "0%"
        }
        
        let recentEntries = entries.filter { $0.getLocalDateTime() >= midpoint }
        let olderEntries = entries.filter { $0.getLocalDateTime() < midpoint }
        
        guard !recentEntries.isEmpty && !olderEntries.isEmpty else { return "0%" }
        
        let recentAvg = recentEntries.map { getMoodValue($0.mood) }.reduce(0, +) / recentEntries.count
        let olderAvg = olderEntries.map { getMoodValue($0.mood) }.reduce(0, +) / olderEntries.count
        
        let change = ((recentAvg - olderAvg) * 100) / max(olderAvg, 1)
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change)%"
    }
    
    private func calculateOverallMood(from entries: [MoodEntry]) -> String {
        guard !entries.isEmpty else { return String(localized: "N/A") }
        
        let avgValue = entries.map { getMoodValue($0.mood) }.reduce(0, +) / entries.count
        
        switch avgValue {
        case 0..<2:
            return String(localized: "Malo")
        case 2..<3:
            return String(localized: "Regular")
        case 3..<4:
            return String(localized: "Bueno")
        case 4...5:
            return String(localized: "Excelente")
        default:
            return String(localized: "N/A")
        }
    }
    
    private func getMoodValue(_ moodName: String) -> Int {
        // Map mood names to values (you might want to get this from the Mood entity)
        let moodValues: [String: Int] = [
            "Feliz": 5, "Happy": 5,
            "Alegre": 4, "Joyful": 4,
            "Neutral": 3, "Neutro": 3,
            "Triste": 2, "Sad": 2,
            "Estresado": 1, "Stressed": 1,
            "Cansado": 2, "Tired": 2
        ]
        return moodValues[moodName] ?? 3
    }
    
    private func setEmptyData() {
        chartData = []
        distributionData = []
        mostFrequentMood = String(localized: "N/A")
        moodTrend = "0%"
        overallMood = String(localized: "N/A")
    }
}
