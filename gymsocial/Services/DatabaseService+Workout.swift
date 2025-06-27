import Foundation
import FirebaseFirestore

extension DatabaseService {
    /// Creates a workout post in /posts with embedded workout data
    func createWorkoutPost(
        draft: DraftWorkout,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let payload: [String: Any] = [
            "type": "workout",
            "userId": draft.userId,
            "startTime": draft.startTime,
            "endTime": draft.endTime as Any,
            "exercises": draft.exercises.map { exercise in
                [
                    "name": exercise.name,
                    "sets": exercise.sets.map { set in
                        ["reps": set.reps, "weight": set.weight]
                    }
                ]
            }
        ]

        // Use Firestore.firestore() here so we don't rely on a private 'db' property
        Firestore
            .firestore()
            .collection("posts")
            .addDocument(data: payload) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
