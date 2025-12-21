import Combine
import FirebaseFirestore
import Foundation

class MoodEntryRepositoryImpl: MoodEntryRepository {
    private let firestore = Firestore.firestore()
    private let firestoreService: FireStoreService
    private let collectionName = "moodEntries"

    // Inject GetMoodsUseCase to Resolve Mood Objects
    // Using Resource pattern means GetMoodsUseCase returns AnyPublisher<Resource<[Mood]>, Never>
    private let getMoodsUseCase: GetMoodsUseCase

    init(firestoreService: FireStoreService, getMoodsUseCase: GetMoodsUseCase) {
        self.firestoreService = firestoreService
        self.getMoodsUseCase = getMoodsUseCase
    }

    func addMoodEntry(_ entry: MoodEntry) -> AnyPublisher<Resource<Void>, Never> {
        return Future<Resource<Void>, Never> { promise in
            Task {
                do {
                    try await self.firestoreService.save(entry, at: self.collectionName)
                    promise(.success(.success(())))
                } catch {
                    promise(.success(.error(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getMoodEntries(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        let subject = CurrentValueSubject<Resource<[MoodEntry]>, Never>(.loading)

        // Match the pattern from CommentRepositoryImpl: Listen directly with Firebase logic if needed, or check if firestoreService.getCollection provides real-time updates.
        // CommentRepositoryImpl uses manual addSnapshotListener. Let's do that to be safe.

        let listener = firestore.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    return
                }

                guard let documents = snapshot?.documents else {
                    subject.send(.success([]))
                    return
                }

                // Manual mapping or Codable
                let entries = documents.compactMap { document -> MoodEntry? in
                    try? document.data(as: MoodEntry.self)
                }
                subject.send(.success(entries))
            }

        return
            subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }

    func getMoodEntries(
        userId: String, limit: Int, lastDocument: DocumentSnapshot?
    ) -> AnyPublisher<Resource<([MoodEntry], DocumentSnapshot?)>, Never> {
        return Future<Resource<([MoodEntry], DocumentSnapshot?)>, Never> { promise in
            var query = self.firestore.collection(self.collectionName)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)

            if let lastDocument = lastDocument {
                query = query.start(afterDocument: lastDocument)
            }

            query.getDocuments { snapshot, error in
                if let error = error {
                    promise(.success(.error(error.localizedDescription)))
                    return
                }

                guard let snapshot = snapshot else {
                    promise(.success(.success(([], nil))))
                    return
                }

                let entries = snapshot.documents.compactMap { document -> MoodEntry? in
                    try? document.data(as: MoodEntry.self)
                }

                promise(
                    .success(
                        .success(
                            (
                                entries, snapshot.documents.last
                            ))))
            }
        }
        .eraseToAnyPublisher()
    }

    func getMoodEntries(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<
        Resource<[MoodEntry]>, Never
    > {
        let subject = CurrentValueSubject<Resource<[MoodEntry]>, Never>(.loading)

        let listener = firestore.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("createdAt", isGreaterThanOrEqualTo: startDate)
            .whereField("createdAt", isLessThanOrEqualTo: endDate)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    return
                }

                guard let documents = snapshot?.documents else {
                    subject.send(.success([]))
                    return
                }

                let entries = documents.compactMap { document -> MoodEntry? in
                    try? document.data(as: MoodEntry.self)
                }
                subject.send(.success(entries))
            }

        return
            subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }

    func getWeeklyMoods(userId: String, date: Date) -> AnyPublisher<
        Resource<[WeeklyMoodEntry]>, Never
    > {
        let calendar = Calendar.current
        let today = date
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday == 1 ? 6 : weekday - 2)
        let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        let startOfWeek = calendar.startOfDay(for: monday)
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        // Fetch entries
        return getMoodEntries(userId: userId, startDate: startOfWeek, endDate: endOfWeek)
            .flatMap { [weak self] resource -> AnyPublisher<Resource<[WeeklyMoodEntry]>, Never> in
                guard let self = self else {
                    return Just(.error("Repository released")).eraseToAnyPublisher()
                }

                switch resource {
                case .loading:
                    return Just(.loading).eraseToAnyPublisher()
                case .error(let msg):
                    return Just(.error(msg)).eraseToAnyPublisher()
                case .success(let entries):
                    return self.processWeeklyEntries(entries, startOfWeek: startOfWeek)
                }
            }
            .eraseToAnyPublisher()
    }

    private func processWeeklyEntries(_ entries: [MoodEntry], startOfWeek: Date) -> AnyPublisher<
        Resource<[WeeklyMoodEntry]>, Never
    > {
        return getMoodsUseCase.execute()
            .map { moodsResource -> Resource<[WeeklyMoodEntry]> in
                switch moodsResource {
                case .loading: return .loading
                case .error(let msg): return .error(msg)
                case .success(let moods):
                    var weeklyEntries: [WeeklyMoodEntry] = []
                    let calendar = Calendar.current
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE"

                    for i in 0...6 {
                        if let targetDate = calendar.date(byAdding: .day, value: i, to: startOfWeek)
                        {
                            let dayName = dateFormatter.string(from: targetDate).capitalized
                            let dayEntries = entries.filter {
                                calendar.isDate($0.createdAt, inSameDayAs: targetDate)
                            }

                            var resolvedMood: Mood? = nil
                            var entryId: String = UUID().uuidString

                            let validDayEntries = dayEntries.filter { $0.moodId != nil }

                            if !validDayEntries.isEmpty {
                                let moodCounts = validDayEntries.reduce(into: [String: Int]()) {
                                    counts, entry in
                                    guard let moodId = entry.moodId else { return }
                                    counts[moodId, default: 0] += 1
                                }

                                if let mostFrequentId = moodCounts.max(by: { $0.value < $1.value })?
                                    .key
                                {
                                    resolvedMood = moods.first(where: { $0.id == mostFrequentId })
                                }

                                // ID from the last entry or just generated if we pick a representative
                                entryId = validDayEntries.first?.id ?? UUID().uuidString
                            }

                            weeklyEntries.append(
                                WeeklyMoodEntry(
                                    id: entryId, day: dayName, date: targetDate, mood: resolvedMood)
                            )
                        }
                    }
                    return .success(weeklyEntries)
                }
            }
            .eraseToAnyPublisher()
    }

    func getMoodStatistics(userId: String, range: TimeRange) -> AnyPublisher<
        Resource<MoodStatisticsDTO>, Never
    > {
        let endDate = Date()
        let startDate: Date
        let calendar = Calendar.current

        switch range {
        case .weekly: startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        case .monthly: startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        case .threeMonths: startDate = calendar.date(byAdding: .month, value: -3, to: endDate)!
        case .yearly: startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        }

        return getMoodEntries(userId: userId, startDate: startDate, endDate: endDate)
            .flatMap { [weak self] resource -> AnyPublisher<Resource<MoodStatisticsDTO>, Never> in
                guard let self = self else {
                    return Just(.error("Repository released")).eraseToAnyPublisher()
                }

                switch resource {
                case .loading:
                    return Just(.loading).eraseToAnyPublisher()
                case .error(let msg):
                    return Just(.error(msg)).eraseToAnyPublisher()
                case .success(let entries):
                    return self.calculateStatistics(
                        entries, moodsPublisher: self.getMoodsUseCase.execute(), range: range)
                }
            }
            .eraseToAnyPublisher()
    }

    private func calculateStatistics(
        _ entries: [MoodEntry], moodsPublisher: AnyPublisher<Resource<[Mood]>, Never>,
        range: TimeRange
    ) -> AnyPublisher<Resource<MoodStatisticsDTO>, Never> {
        return
            moodsPublisher
            .map { [weak self] resource in
                guard let self = self else { return .error("Reference lost") }
                return self.processStatistics(resource, entries: entries, range: range)
            }
            .eraseToAnyPublisher()
    }

    private func processStatistics(
        _ resource: Resource<[Mood]>, entries: [MoodEntry], range: TimeRange
    ) -> Resource<
        MoodStatisticsDTO
    > {
        switch resource {
        case .loading: return .loading
        case .error(let msg): return .error(msg)
        case .success(let moods):
            let validEntries = entries.filter { $0.moodId != nil }

            let moodCounts = validEntries.reduce(into: [String: Int]()) { counts, entry in
                guard let moodId = entry.moodId else { return }
                counts[moodId, default: 0] += 1
            }
            let mostFrequentId = moodCounts.max(by: { $0.value < $1.value })?.key
            let mostFrequentMood = moods.first(where: { $0.id == mostFrequentId })

            let totalValue = validEntries.compactMap { entry in
                moods.first(where: { $0.id == entry.moodId })?.value
            }.reduce(0, +)

            let average = validEntries.isEmpty ? 0 : Double(totalValue) / Double(validEntries.count)
            let moodTrend = String(format: "Avg: %.1f", average)

            let overallMood = moods.min(by: {
                abs(Double($0.value) - average) < abs(Double($1.value) - average)
            })

            var distribution: [MoodDistributionItem] = []
            let totalEntries = Double(validEntries.count)
            if totalEntries > 0 {
                for (moodId, count) in moodCounts {
                    if let mood = moods.first(where: { $0.id == moodId }) {
                        let name = mood.getName()
                        let percentage = Double(count) / totalEntries
                        let display = String(format: "%.0f%%", percentage * 100)
                        distribution.append(
                            MoodDistributionItem(
                                emotion: name, percentage: percentage,
                                displayPercentage: display,
                                colorHex: mood.color
                            )
                        )
                    }
                }
                distribution.sort(by: { $0.percentage > $1.percentage })
            }

            let dateFormatter = DateFormatter()
            if range == .monthly || range == .threeMonths || range == .yearly {
                dateFormatter.dateFormat = "d/M"
            } else {
                dateFormatter.dateFormat = "EEE"  // Weekly or default
            }

            var chartPoints: [MoodChartPoint] = []

            let calendar = Calendar.current
            var grouped: [Date: [MoodEntry]] = [:]
            for entry in entries {
                let day = calendar.startOfDay(for: entry.createdAt)
                grouped[day, default: []].append(entry)
            }

            let sortedDays = grouped.keys.sorted()
            for day in sortedDays {
                // Filter only valid mood entries for this day
                let dayEntries = (grouped[day] ?? []).filter { $0.moodId != nil }

                guard !dayEntries.isEmpty else { continue }

                let dayTotal = dayEntries.compactMap { entry in
                    moods.first(where: { $0.id == entry.moodId })?.value
                }.reduce(0, +)

                let dayAvg = Double(dayTotal) / Double(dayEntries.count)
                let label = dateFormatter.string(from: day)

                // Determine dominant color for the day
                let dayMoodCounts = dayEntries.reduce(into: [String: Int]()) { counts, entry in
                    guard let moodId = entry.moodId else { return }
                    counts[moodId, default: 0] += 1
                }
                let dominantMoodId = dayMoodCounts.max(by: { $0.value < $1.value })?.key
                let dominantColor = moods.first(where: { $0.id == dominantMoodId })?.color

                chartPoints.append(
                    MoodChartPoint(day: label, value: dayAvg, colorHex: dominantColor))
            }

            return .success(
                MoodStatisticsDTO(
                    mostFrequentMood: mostFrequentMood,
                    moodTrend: moodTrend,
                    overallMood: overallMood,
                    distribution: distribution,
                    chartData: chartPoints
                ))
        }
    }
}
