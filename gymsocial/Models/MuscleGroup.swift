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
