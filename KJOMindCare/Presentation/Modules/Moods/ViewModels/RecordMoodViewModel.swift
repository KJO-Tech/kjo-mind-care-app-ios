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
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private let getMoodsUseCase: GetMoodsUseCase
    private let saveMoodEntryUseCase: SaveMoodEntryUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        getMoodsUseCase: GetMoodsUseCase,
        saveMoodEntryUseCase: SaveMoodEntryUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.getMoodsUseCase = getMoodsUseCase
        self.saveMoodEntryUseCase = saveMoodEntryUseCase
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
        }
    }

    func saveMood() {
        guard let mood = selectedMood else {
            errorMessage = "Please select a mood"
            return
        }
        
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        // Get current user ID
        checkUserSessionUseCase.execute()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] userResource -> AnyPublisher<Resource<MoodEntry>, Never> in
                guard let self = self else {
                    return Just(.error("User session error")).eraseToAnyPublisher()
                }
                
                switch userResource {
                case .success(let user):
                    // Save mood entry with user ID and mood name
                    let moodName = mood.name["es"] ?? mood.name["en"] ?? "Unknown"
                    return self.saveMoodEntryUseCase.execute(
                        userId: user.uid,
                        mood: moodName,
                        note: self.noteText
                    )
                case .error(let message):
                    return Just(.error(message)).eraseToAnyPublisher()
                default:
                    return Just(.error("Unknown error")).eraseToAnyPublisher()
                }
            }
            .sink { [weak self] resource in
                guard let self = self else { return }
                self.isSaving = false
                
                switch resource {
                case .success(let entry):
                    self.successMessage = "Mood saved successfully!"
                    print("✅ Mood Entry guardado: \(entry.mood) - \(entry.note)")
                    // Clear form
                    self.selectedMood = nil
                    self.noteText = ""
                case .error(let message):
                    self.errorMessage = "Error saving mood: \(message)"
                    print("❌ Error guardando mood: \(message)")
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
