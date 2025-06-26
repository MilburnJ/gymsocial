import Foundation

/// A workout in progress, with live timer, until posted
struct DraftWorkout: Identifiable, Codable {
    let id = UUID()
    let userId: String
    let startTime: Date
    var endTime: Date?
    var exercises: [ExerciseLog]

    /// Computed duration in seconds (nil until endTime set)
    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
}
