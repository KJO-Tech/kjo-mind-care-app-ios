//
//  RecordMoodViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 24/11/25.
//

import SwiftUI


struct MoodOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let color: Color
}

class RecordMoodViewModel: ObservableObject {
    
    @Published var selectedMood: MoodOption?
    @Published var noteText: String = ""
    

    let moodOptions: [MoodOption] = [
            MoodOption(
                name: String(localized: "Alegre"),
                description: String(localized: "Sentir gran alegría o deleite"),
                iconName: "joyful",
                color: .yellow
            ),
            MoodOption(
                name: String(localized: "Feliz"),
                description: String(localized: "Contento"),
                iconName: "happy",
                color: .orange
            ),
            MoodOption(
                name: String(localized: "Emocionado(a)"),
                description: String(localized: "Entusiasta, ansioso"),
                iconName: "excited",
                color: .yellow
            ),
            MoodOption(
                name: String(localized: "Neutro"),
                description: String(localized: "Ni buena ni mala(o)="),
                iconName: "neutral",
                color: .gray
            ),
            MoodOption(
                name: String(localized: "Cansado"),
                description: String(localized: "Fatigado, baja energía"),
                iconName: "tired",
                color: .blue
            ),
            MoodOption(
                name: String(localized: "Triste"),
                description: String(localized: "Infeliz, abajo"),
                iconName: "sad",
                color: .indigo
            ),
            MoodOption(
                name: String(localized: "Ansioso"),
                description: String(localized: "Preocupado(a)"),
                iconName: "anxious",
                color: .purple
            ),
            MoodOption(
                name: String(localized: "Enojado"),
                description: String(localized: "Molesto, disgustado"),
                iconName: "angry",
                color: .red
            ),
            MoodOption(
                name: String(localized: "Enfermo(a)"),
                description: String(localized: "Indispuesta(o)"),
                iconName: "sick",
                color: .green
            )
        ]
    
    func selectMood(_ mood: MoodOption) {
        selectedMood = mood
    }
    
    func saveMood() {
        guard let mood = selectedMood else { return }
        print("Guardando Mood: \(mood.name) con nota: \(noteText)")
    }
}
