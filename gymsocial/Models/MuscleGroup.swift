import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest
    case shoulders
    case core
    case lats
    case traps
    case calves
    case hamstrings
    case quads
    case biceps
    case triceps

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chest:      return "Chest"
        case .shoulders:  return "Shoulders"
        case .core:       return "Core"
        case .lats:       return "Lats"
        case .traps:      return "Traps"
        case .calves:     return "Calves"
        case .hamstrings: return "Hamstrings"
        case .quads:      return "Quads"
        case .biceps:     return "Biceps"
        case .triceps:    return "Triceps"
        }
    }
}

extension MuscleGroup {
    var sfSymbolName: String {
        switch self {
        case .chest:      return "shield.lefthalf.fill"
        case .shoulders:  return "figure.stand"
        case .core:       return "circle.grid.cross.fill"
        case .lats:       return "bolt.fill"
        case .traps:      return "bolt.horizontal.fill"
        case .calves:     return "figure.walk"
        case .hamstrings: return "figure.run"
        case .quads:      return "figure.stand.line.dotted.figure.stand"
        case .biceps:     return "figure.strengthtraining.traditional"
        case .triceps:    return "figure.cooldown"
        }
    }
}
