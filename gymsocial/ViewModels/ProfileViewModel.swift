// ViewModels/ProfileViewModel.swift

import Foundation
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    @Published var workouts: [Post] = []
    private var listener: ListenerRegistration?

    /// Call once you have the signed-in user’s UID
    func subscribe(userId: String) {
        listener?.remove()
        listener = Firestore.firestore()
            .collection("posts")
            .whereField("type", isEqualTo: "workout")
            .whereField("authorID", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }

                let posts: [Post] = docs.compactMap { doc in
                    let data = doc.data()

                    // 1) Common post fields
                    guard
                        let authorID   = data["authorID"]   as? String,
                        let authorName = data["authorName"] as? String,
                        let ts         = data["timestamp"]  as? Timestamp,
                        let likes      = data["likes"]      as? Int,
                        let workoutMap = data["workout"]    as? [String:Any]
                    else {
                        return nil
                    }

                    // 2) Workout payload fields
                    guard
                        let startTS       = workoutMap["startTime"] as? Timestamp,
                        let endTS         = workoutMap["endTime"]   as? Timestamp,
                        let exercisesArr  = workoutMap["exercises"] as? [[String:Any]]
                    else {
                        return nil
                    }

                    // 3) Decode each ExerciseLog or drop it
                    let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                        guard
                            let name    = exDict["name"] as? String,
                            let setsArr = exDict["sets"] as? [[String:Any]]
                        else {
                            return nil
                        }
                        let sets: [WorkoutSet] = setsArr.compactMap { setDict in
                            guard
                                let reps   = setDict["reps"]   as? Int,
                                let weight = setDict["weight"] as? Double
                            else {
                                return nil
                            }
                            return WorkoutSet(reps: reps, weight: weight)
                        }
                        return ExerciseLog(name: name, sets: sets)
                    }

                    // 4) Build the Post
                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exercises
                    )
                    return Post(
                        id:           doc.documentID,
                        authorID:     authorID,
                        authorName:   authorName,
                        timestamp:    ts.dateValue(),
                        likes:        likes,
                        workout:      payload
                    )
                }

                DispatchQueue.main.async {
                    self?.workouts = posts
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
