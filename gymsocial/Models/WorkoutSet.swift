import Foundation

/// A single set within an exercise
struct WorkoutSet: Identifiable, Codable {
    let id = UUID()
    var reps: Int
    var weight: Double
}
