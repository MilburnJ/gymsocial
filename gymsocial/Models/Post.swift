import Foundation

/// The nested workout data for a post
struct WorkoutPayload: Codable {
    let startTime: Date
    let endTime: Date
    let exercises: [ExerciseLog]

    /// “Bench Press: 5x135, Squat: 3x225” style summary
    var summary: String {
        exercises
            .map { log in
                let sets = log.sets.map { "\($0.reps)x\($0.weight)" }
                                   .joined(separator: ", ")
                return "\(log.name): \(sets)"
            }
            .joined(separator: "\n")
    }
}

/// A feed post (now _only_ workouts)
struct Post: Identifiable {
  let id: String
  let authorID: String
  let authorName: String
  let timestamp: Date
  let likes: Int
  let title: String           // new
  let description: String?    // new, optional
  let workout: WorkoutPayload
}
