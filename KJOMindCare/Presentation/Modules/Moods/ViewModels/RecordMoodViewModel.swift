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

    private let getMoodsUseCase: GetMoodsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getMoodsUseCase: GetMoodsUseCase) {
        self.getMoodsUseCase = getMoodsUseCase
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
        guard let mood = selectedMood else { return }
        // Implement save logic (e.g., SaveMoodUseCase)
        print("Guardando Mood: \(mood.name["es"] ?? "") con nota: \(noteText)")
    }
}
