import Foundation
import FirebaseFirestore
import FirebaseAuth  // needed for Auth.auth()

extension DatabaseService {
    /// Creates a workout‐type post in /posts
    func createWorkoutPost(
        draft: DraftWorkout,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 1. Build the nested workout payload
        let workoutPayload: [String: Any] = [
            "startTime": draft.startTime,
            "endTime":   draft.endTime as Any,
            "exercises": draft.exercises.map { log in
                [
                    "name": log.name,
                    "sets": log.sets.map { set in
                        ["reps": set.reps, "weight": set.weight]
                    }
                ]
            }
        ]

        // 2. Assemble top‐level post data
        let data: [String: Any] = [
            "type":       "workout",
            "authorID":   draft.userId,
            "authorName": Auth.auth().currentUser?.displayName ?? "",
            "timestamp":  FieldValue.serverTimestamp(),
            "likes":      0,
            "workout":    workoutPayload
        ]

        // 3. Write to Firestore
        let db = Firestore.firestore()
        db.collection("posts")
          .addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
