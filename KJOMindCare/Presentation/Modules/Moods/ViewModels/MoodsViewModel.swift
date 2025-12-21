//
//  MoodsViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

class MoodsViewModel: ObservableObject {

    private let getMoodStatisticsUseCase: GetMoodStatisticsUseCase
    private let getMoodEntriesUseCase: GetMoodEntriesUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let getMoodsUseCase: GetMoodsUseCase
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

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

    // Pagination properties
    // Pagination properties
    @Published var historyEntries: [MoodHistoryItem] = []
    @Published var isLoadingHistory: Bool = false
    @Published var canLoadMore: Bool = false
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 10
    private var moodsMap: [String: Mood] = [:]

    init(
        getMoodStatisticsUseCase: GetMoodStatisticsUseCase,
        getMoodEntriesUseCase: GetMoodEntriesUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        getMoodsUseCase: GetMoodsUseCase
    ) {
        self.getMoodStatisticsUseCase = getMoodStatisticsUseCase
        self.getMoodEntriesUseCase = getMoodEntriesUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getMoodsUseCase = getMoodsUseCase

        loadMoods()
        loadData()
        loadHistory(reset: true)
    }

    private func loadMoods() {
        getMoodsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] resource in
                if case .success(let moods) = resource {
                    self?.moodsMap = Dictionary(uniqueKeysWithValues: moods.map { ($0.id, $0) })
                    // We don't trigger history reload here, but next page load will have colors.
                }
            }
            .store(in: &cancellables)
    }

    func loadData() {
        let range: TimeRange
        switch selectedTimeframe {
        case "Weekly": range = .weekly
        case "Monthly": range = .monthly
        default: range = .weekly
        }

        guard let user = checkUserSessionUseCase.execute() else {
            errorMessage = "User not logged in"
            return
        }

        isLoading = true
        getMoodStatisticsUseCase.execute(userId: user.id, range: range)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<MoodStatisticsDTO>) in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .loading:
                    self.isLoading = true

                case .success(let dto):
                    self.chartData = dto.chartData
                    self.distributionData = dto.distribution

                    self.mostFrequentMood = dto.mostFrequentMood?.getName() ?? "-"
                    self.moodTrend = dto.moodTrend
                    self.overallMood = dto.overallMood?.getName() ?? "-"

                case .error(let message):
                    self.errorMessage = message
                }
            }
            .store(in: &cancellables)
    }

    func loadHistory(reset: Bool = false) {
        guard let user = checkUserSessionUseCase.execute() else { return }

        if reset {
            historyEntries = []
            lastDocument = nil
            canLoadMore = true
        }

        guard !isLoadingHistory && canLoadMore else { return }

        isLoadingHistory = true

        getMoodEntriesUseCase.execute(userId: user.id, limit: pageSize, lastDocument: lastDocument)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<([MoodEntry], DocumentSnapshot?)>) in
                guard let self = self else { return }
                self.isLoadingHistory = false

                switch resource {
                case .loading:
                    self.isLoadingHistory = true
                case .success(let (entries, lastDoc)):
                    let mappedItems = entries.compactMap { entry -> MoodHistoryItem? in
                        guard let moodId = entry.moodId else { return nil }
                        let mood = self.moodsMap[moodId]
                        return MoodHistoryItem(
                            id: entry.id ?? UUID().uuidString,
                            date: entry.createdAt,
                            moodName: mood?.getName() ?? "Unknown",
                            moodColorHex: mood?.color ?? "#CCCCCC",
                            moodImage: mood?.image ?? "",
                            note: entry.note
                        )
                    }

                    if reset {
                        self.historyEntries = mappedItems
                    } else {
                        self.historyEntries.append(contentsOf: mappedItems)
                    }
                    self.lastDocument = lastDoc
                    self.canLoadMore = entries.count == self.pageSize
                case .error(let message):
                    self.errorMessage = message
                }
            }
            .store(in: &cancellables)
    }
}

struct MoodHistoryItem: Identifiable {
    let id: String
    let date: Date
    let moodName: String
    let moodColorHex: String
    let moodImage: String
    let note: String
}
