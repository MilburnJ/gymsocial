// ViewModels/FeedViewModel.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Simple Array extension to split into subarrays of a given max size.
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

final class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: String?

    /// Keep track of all snapshot listeners so we can remove them later.
    private var listeners: [ListenerRegistration] = []

    init() {
        subscribe()
    }

    deinit {
        removeListeners()
    }

    func reload() {
        removeListeners()
        posts.removeAll()
        subscribe()
    }

    private func removeListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    private func subscribe() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            errorMessage = "Not authenticated"
            return
        }

        let db = Firestore.firestore()
        // 1) Fetch the list of IDs you follow
        db.collection("users")
            .document(currentUID)
            .collection("following")
            .getDocuments { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    DispatchQueue.main.async {
                        self.errorMessage = err.localizedDescription
                    }
                    return
                }

                // 2) Build authors list (you + everyone you follow)
                var authors = [currentUID]
                if let docs = snap?.documents {
                    authors += docs.map { $0.documentID }
                }

                // 3) Split into chunks of max 10
                let authorChunks = authors.chunked(into: 10)

                // 4) For each chunk, add a snapshot listener
                for chunk in authorChunks {
                    let listener = db
                        .collection("posts")
                        .whereField("type", isEqualTo: "workout")
                        .whereField("authorID", in: chunk)
                        .order(by: "timestamp", descending: true)
                        .addSnapshotListener { snapshot, error in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.errorMessage = error.localizedDescription
                                }
                                return
                            }
                            guard let docs = snapshot?.documents else { return }

                            // Decode this chunk’s posts
                            let newPosts: [Post] = docs.compactMap { doc in
                                let d = doc.data()
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

                                guard
                                    let startTS      = workoutMap["startTime"]  as? Timestamp,
                                    let endTS        = workoutMap["endTime"]    as? Timestamp,
                                    let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                                else {
                                    return nil
                                }

                                let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                                    guard
                                        let name         = exDict["name"]         as? String,
                                        let groupStrings = exDict["muscleGroups"] as? [String],
                                        let setsArr      = exDict["sets"]         as? [[String:Any]]
                                    else { return nil }

                                    let groups = groupStrings.compactMap {
                                        MuscleGroup(rawValue: $0)
                                    }

                                    let sets: [WorkoutSet] = setsArr.compactMap { setDict in
                                        guard
                                            let reps   = setDict["reps"]   as? Int,
                                            let weight = setDict["weight"] as? Double
                                        else { return nil }
                                        return WorkoutSet(reps: reps, weight: weight)
                                    }

                                    return ExerciseLog(
                                        name: name,
                                        sets: sets,
                                        muscleGroups: groups
                                    )
                                }

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
                                    title:        title,
                                    description:  description,
                                    workout:      payload
                                )
                            }

                            // 5) Merge with existing posts and sort
                            DispatchQueue.main.async {
                                // Combine, then de-duplicate by ID
                                let combined = (self.posts + newPosts)
                                    .reduce(into: [String:Post]()) { dict, post in
                                        dict[post.id] = post
                                    }
                                    .values
                                    .sorted { $0.timestamp > $1.timestamp }

                                self.posts = combined
                            }
                        }

                    self.listeners.append(listener)
                }
            }
    }
}
