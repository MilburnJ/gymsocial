// Services/DatabaseService+Workout.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension DatabaseService {
    /// Creates a workout‐type post in /posts with a title & optional description
    func createWorkoutPost(
        draft: DraftWorkout,
        title: String,
        description: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 1) Build nested workout payload
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

        // 2) Assemble post data
        var data: [String: Any] = [
            "type":       "workout",
            "authorID":   draft.userId,
            "authorName": Auth.auth().currentUser?.displayName ?? "Unknown",
            "timestamp":  FieldValue.serverTimestamp(),
            "likes":      0,
            "title":      title,
            "workout":    workoutPayload
        ]
        if let desc = description, !desc.isEmpty {
            data["description"] = desc
        }

        // 3) Write to Firestore
        Firestore
            .firestore()
            .collection("posts")
            .addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
