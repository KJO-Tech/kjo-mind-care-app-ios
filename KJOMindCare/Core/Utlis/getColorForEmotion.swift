//
//  getColorForEmotion.swift
//  KJOMindCare
//
//  Created by Raydberg on 24/11/25.
//

import Foundation
import SwiftUICore

 func getColorForEmotion(_ emotion: String) -> Color {
    let lowerEmotion = emotion.lowercased()
    if lowerEmotion.contains("alegre") || lowerEmotion.contains("feliz") {
        return .yellow
    }
    if lowerEmotion.contains("estresado")
        || lowerEmotion.contains("enojado")
    {
        return .red
    }
    if lowerEmotion.contains("triste") || lowerEmotion.contains("cansado") {
        return .blue
    }
    if lowerEmotion.contains("neutro") { return .gray }
    return .teal
}
