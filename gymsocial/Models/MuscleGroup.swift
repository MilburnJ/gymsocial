//
//  MuscleGroup.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/26/25.
//


import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest, back, legs, shoulders, arms, core

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .chest:      return "Chest"
        case .back:       return "Back"
        case .legs:       return "Legs"
        case .shoulders:  return "Shoulders"
        case .arms:       return "Arms"
        case .core:       return "Core"
        }
    }
}
extension MuscleGroup {
    var sfSymbolName: String {
        switch self {
        case .chest:     return "shield.lefthalf.fill"
        case .back:      return "bolt.fill"
        case .legs:      return "figure.walk"
        case .shoulders: return "figure.stand"
        case .arms:      return "figure.strengthtraining.traditional"
        case .core:      return "circle.grid.cross.fill"
        }
    }
}
