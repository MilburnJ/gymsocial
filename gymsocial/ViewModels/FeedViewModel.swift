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

    init() { subscribe() }
    deinit { listener?.remove() }

    private func subscribe() {
        listener = Firestore
            .firestore()
            .collection("posts")
            .whereField("type", isEqualTo: "workout")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }

                let decoded: [Post] = docs.compactMap { doc in
                    let d = doc.data()

                    // required fields
                    guard
                        let authorID   = d["authorID"]   as? String,
                        let authorName = d["authorName"] as? String,
                        let ts         = d["timestamp"]  as? Timestamp,
                        let likes      = d["likes"]      as? Int,
                        let title      = d["title"]      as? String,
                        // description is optional
                        let workoutMap = d["workout"]    as? [String:Any]
                    else {
                        return nil
                    }

                    // decode workout payload
                    guard
                        let startTS      = workoutMap["startTime"]  as? Timestamp,
                        let endTS        = workoutMap["endTime"]    as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                    else {
                        return nil
                    }

                    let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                        guard
                            let name    = exDict["name"] as? String,
                            let setsArr = exDict["sets"] as? [[String:Any]]
                        else { return nil }
                        let sets: [WorkoutSet] = setsArr.compactMap { s in
                            guard
                                let reps   = s["reps"]   as? Int,
                                let weight = s["weight"] as? Double
                            else { return nil }
                            return WorkoutSet(reps: reps, weight: weight)
                        }
                        return ExerciseLog(name: name, sets: sets)
                    }

                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exercises
                    )

                    // pull optional description
                    let desc = d["description"] as? String

                    return Post(
                        id:           doc.documentID,
                        authorID:     authorID,
                        authorName:   authorName,
                        timestamp:    ts.dateValue(),
                        likes:        likes,
                        title:        title,
                        description:  desc,
                        workout:      payload
                    )
                }

                DispatchQueue.main.async {
                    self?.posts = decoded
                }
            }
    }
}
