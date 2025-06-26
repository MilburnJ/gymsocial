import Foundation

/// A log of one exercise within a workout, containing multiple sets
struct ExerciseLog: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: [WorkoutSet]
}
