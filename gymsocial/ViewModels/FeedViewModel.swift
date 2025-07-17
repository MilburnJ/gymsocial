// ViewModels/FeedViewModel.swift

import Foundation
import FirebaseFirestore

final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var listener: ListenerRegistration?

    func reload() {
        listener?.remove()
        subscribe()
    }

    init() {
        subscribe()
    }

    deinit {
        listener?.remove()
    }

    private func subscribe() {
        listener = Firestore.firestore()
            .collection("posts")
            .whereField("type", isEqualTo: "workout")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil, let docs = snapshot?.documents else {
                    print("Firestore error:", error ?? "unknown")
                    return
                }

                // Decode each document into a Post? via compactMap
                let decoded: [Post] = docs.compactMap { doc in
                    let d = doc.data()

                    // Required top‐level Post fields
                    guard
                        let authorID   = d["authorID"]   as? String,
                        let authorName = d["authorName"] as? String,
                        let ts         = d["timestamp"]  as? Timestamp,
                        let likes      = d["likes"]      as? Int,
                        let title      = d["title"]      as? String,
                        let workoutMap = d["workout"]    as? [String:Any]
                    else {
                        return nil
                    }

                    let description = d["description"] as? String

                    // Required workout payload fields
                    guard
                        let startTS      = workoutMap["startTime"]  as? Timestamp,
                        let endTS        = workoutMap["endTime"]    as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                    else {
                        return nil
                    }

                    // Decode each ExerciseLog via compactMap
                    let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                        // 1) Basic exercise info
                        guard
                            let name         = exDict["name"]         as? String,
                            let groupStrings = exDict["muscleGroups"] as? [String],
                            let setsArr      = exDict["sets"]         as? [[String:Any]]
                        else {
                            return nil
                        }

                        // 2) Parse muscle groups
                        let groups: [MuscleGroup] = groupStrings.compactMap {
                            MuscleGroup(rawValue: $0)
                        }

                        // 3) Parse sets
                        let sets: [WorkoutSet] = setsArr.compactMap { setDict in
                            guard
                                let reps   = setDict["reps"]   as? Int,
                                let weight = setDict["weight"] as? Double
                            else {
                                return nil
                            }
                            return WorkoutSet(reps: reps, weight: weight)
                        }

                        // 4) Build the ExerciseLog (no `id:` argument)
                        return ExerciseLog(
                            name: name,
                            sets: sets,
                            muscleGroups: groups
                        )
                    }

                    // Build the workout payload
                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exercises
                    )

                    // Return the fully decoded Post
                    return Post(
                        id:           doc.documentID,
                        authorID:     authorID,
                        authorName:   authorName,
                        timestamp:    ts.dateValue(),
                        likes:        likes,
                        title:        title,
                        description:  description,
                        workout:      payload
                    )
                }

                // Publish on the main thread
                DispatchQueue.main.async {
                    self?.posts = decoded
                }
            }
    }
}
