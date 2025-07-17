// ViewModels/ProfileViewModel.swift

import Foundation
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    @Published var workouts: [Post] = []
    @Published var recentHighlighted: Set<MuscleGroup> = []

    private var listener: ListenerRegistration?

    /// Call this with the signed‐in user’s UID to begin listening
    func subscribe(userId: String) {
        listener?.remove()
        listener = Firestore.firestore()
            .collection("posts")
            .whereField("type",     isEqualTo: "workout")
            .whereField("authorID", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                var loadedPosts: [Post] = []

                for doc in docs {
                    let data = doc.data()

                    // 1) Top‐level fields
                    guard
                        let authorID   = data["authorID"]   as? String,
                        let authorName = data["authorName"] as? String,
                        let ts         = data["timestamp"]  as? Timestamp,
                        let likes      = data["likes"]      as? Int,
                        let title      = data["title"]      as? String,
                        let workoutMap = data["workout"]    as? [String:Any]
                    else {
                        continue
                    }
                    let description = data["description"] as? String

                    // 2) Workout payload fields
                    guard
                        let startTS      = workoutMap["startTime"]  as? Timestamp,
                        let endTS        = workoutMap["endTime"]    as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                    else {
                        continue
                    }

                    // 3) Decode each ExerciseLog
                    var exerciseLogs: [ExerciseLog] = []
                    for exDict in exercisesArr {
                        guard
                            let name         = exDict["name"]         as? String,
                            let groupStrings = exDict["muscleGroups"] as? [String],
                            let setsArr      = exDict["sets"]         as? [[String:Any]]
                        else {
                            continue
                        }

                        // decode muscle groups
                        let groups = groupStrings.compactMap {
                            MuscleGroup(rawValue: $0)
                        }

                        // decode sets
                        var sets: [WorkoutSet] = []
                        for setDict in setsArr {
                            if let reps   = setDict["reps"]   as? Int,
                               let weight = setDict["weight"] as? Double {
                                sets.append(WorkoutSet(reps: reps, weight: weight))
                            }
                        }

                        let log = ExerciseLog(
                            name: name,
                            sets: sets,
                            muscleGroups: groups,
                        )
                        exerciseLogs.append(log)
                    }

                    // 4) Build payload & Post
                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exerciseLogs
                    )

                    let post = Post(
                        id:           doc.documentID,
                        authorID:     authorID,
                        authorName:   authorName,
                        timestamp:    ts.dateValue(),
                        likes:        likes,
                        title:        title,
                        description:  description,
                        workout:      payload
                    )
                    loadedPosts.append(post)
                }

                // 5) Compute recentHighlighted (last 48h)
                let cutoff = Date().addingTimeInterval(-48*3600)
                var recentGroups: [MuscleGroup] = []
                for post in loadedPosts {
                    if post.timestamp >= cutoff {
                        for log in post.workout.exercises {
                            recentGroups.append(contentsOf: log.muscleGroups)
                        }
                    }
                }
                let unique = Set(recentGroups)

                // 6) Publish results
                DispatchQueue.main.async {
                    self?.workouts = loadedPosts
                    self?.recentHighlighted = unique
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
