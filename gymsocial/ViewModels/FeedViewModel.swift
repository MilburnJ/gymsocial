// ViewModels/FeedViewModel.swift

import Foundation
import FirebaseFirestore

final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var listener: ListenerRegistration?

    init() { subscribe() }
    deinit { listener?.remove() }

    /// Call this in a .refreshable to re-query the feed
    func reload() {
        listener?.remove()
        subscribe()
    }

    private func subscribe() {
        listener = Firestore.firestore()
            .collection("posts")
            .whereField("type", isEqualTo: "workout")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }

                // Decode each document into a Post, dropping any that fail
                let decoded: [Post] = documents.compactMap { doc in
                    let data = doc.data()

                    // 1) Common Post fields
                    guard
                        let authorID   = data["authorID"]   as? String,
                        let authorName = data["authorName"] as? String,
                        let ts         = data["timestamp"]  as? Timestamp,
                        let likes      = data["likes"]      as? Int,
                        let workoutMap = data["workout"]    as? [String:Any]
                    else {
                        return nil
                    }
                    let postID    = doc.documentID
                    let timestamp = ts.dateValue()

                    // 2) Workout payload fields
                    guard
                        let startTS      = workoutMap["startTime"] as? Timestamp,
                        let endTS        = workoutMap["endTime"]   as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                    else {
                        return nil
                    }

                    // 3) Decode each ExerciseLog, dropping any bad entries
                    let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                        guard
                            let name    = exDict["name"] as? String,
                            let setsArr = exDict["sets"] as? [[String:Any]]
                        else {
                            return nil
                        }
                        // Decode each WorkoutSet, dropping invalid ones
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

                    // 4) Build the WorkoutPayload & Post
                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exercises
                    )

                    return Post(
                        id:           postID,
                        authorID:     authorID,
                        authorName:   authorName,
                        timestamp:    timestamp,
                        likes:        likes,
                        workout:      payload
                    )
                }

                DispatchQueue.main.async {
                    self?.posts = decoded
                }
            }
    }
}
