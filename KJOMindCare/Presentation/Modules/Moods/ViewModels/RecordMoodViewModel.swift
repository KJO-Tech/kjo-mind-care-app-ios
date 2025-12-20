//
//  RecordMoodViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 24/11/25.
//

import Combine
import SwiftUI

class RecordMoodViewModel: ObservableObject {

    @Published var moods: [Mood] = []
    @Published var selectedMood: Mood?
    @Published var noteText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSaved: Bool = false

    private let getMoodsUseCase: GetMoodsUseCase
    private let addMoodEntryUseCase: AddMoodEntryUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private var cancellables = Set<AnyCancellable>()
    private var pendingMoodId: String?

    init(
        getMoodsUseCase: GetMoodsUseCase, addMoodEntryUseCase: AddMoodEntryUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.getMoodsUseCase = getMoodsUseCase
        self.addMoodEntryUseCase = addMoodEntryUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        fetchMoods()
    }

    func fetchMoods() {
        isLoading = true
        getMoodsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<[Mood]>) in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .success(let data):
                    self.moods = data
                    if let pendingId = self.pendingMoodId {
                        self.selectMood(byId: pendingId)
                        self.pendingMoodId = nil
                    }
                case .error(let message):
                    self.errorMessage = message
                default:
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }

    func selectMood(_ mood: Mood) {
        selectedMood = mood
    }

    func selectMood(byId id: String) {
        if let mood = moods.first(where: { $0.id == id }) {
            selectedMood = mood
        } else {
            pendingMoodId = id
        }
    }

    func saveMood() {
        guard let selectedMood = selectedMood else { return }
        guard let user = checkUserSessionUseCase.execute() else {
            errorMessage = "User not logged in"
            return
        }

        let entry = MoodEntry(
            moodId: selectedMood.id,
            note: noteText,
            userId: user.id
        )

        isLoading = true
        addMoodEntryUseCase.execute(entry: entry)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<Void>) in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .loading:
                    self.isLoading = true
                case .success:
                    self.noteText = ""
                    self.selectedMood = nil
                    self.isSaved = true
                case .error(let message):
                    self.errorMessage = message
                }
            }
            .store(in: &cancellables)
    }
}
