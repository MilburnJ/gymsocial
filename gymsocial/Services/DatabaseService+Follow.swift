import Foundation
import FirebaseFirestore
import FirebaseAuth

extension DatabaseService {

    /// Check if the current user is following `userId`
    func isFollowing(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return completion(.success(false))
        }
        let docRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("following")
            .document(userId)
        docRef.getDocument { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            completion(.success(snapshot?.exists ?? false))
        }
    }

    /// Follow user with `userId`
    func follow(userId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return completion(NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
        }
        let batch = Firestore.firestore().batch()
        let followingRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("following")
            .document(userId)
        let followerRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("followers")
            .document(currentUID)
        batch.setData([:], forDocument: followingRef)
        batch.setData([:], forDocument: followerRef)
        batch.commit { error in
            completion(error)
        }
    }

    /// Unfollow user with `userId`
    func unfollow(userId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return completion(NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
        }
        let batch = Firestore.firestore().batch()
        let followingRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("following")
            .document(userId)
        let followerRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("followers")
            .document(currentUID)
        batch.deleteDocument(followingRef)
        batch.deleteDocument(followerRef)
        batch.commit { error in
            completion(error)
        }
    }

    /// Fetch posts for the main feed: your own posts and those of people you follow.
    func fetchFeedPosts(limit: Int = 20,
                        completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return completion(.success([]))
        }
        let db = Firestore.firestore()
        // First get the list of users you follow
        db.collection("users")
            .document(currentUID)
            .collection("following")
            .getDocuments { snap, err in
                if let err = err {
                    return completion(.failure(err))
                }
                let followingIDs = snap?.documents.map { $0.documentID } ?? []
                // Include yourself
                var authors = [currentUID] + followingIDs
                // Firestore 'in' queries support up to 10 values
                if authors.count > 10 {
                    authors = Array(authors.prefix(10))
                }
                // Now fetch posts by those authors
                db.collection("posts")
                    .whereField("authorID", in: authors)
                    .order(by: "timestamp", descending: true)
                    .limit(to: limit)
                    .getDocuments { snap2, err2 in
                        if let err2 = err2 {
                            return completion(.failure(err2))
                        }
                        let docs = snap2?.documents ?? []
                        let posts: [Post] = docs.compactMap { doc in
                            let d = doc.data()
                            guard
                                let authorID   = d["authorID"]   as? String,
                                let authorName = d["authorName"] as? String,
                                let ts         = d["timestamp"]  as? Timestamp,
                                let likes      = d["likes"]      as? Int,
                                let title      = d["title"]      as? String,
                                let workoutMap = d["workout"]    as? [String: Any]
                            else {
                                return nil
                            }
                            let description = d["description"] as? String

                            // Parse workout payload
                            guard
                                let startTS      = workoutMap["startTime"]  as? Timestamp,
                                let endTS        = workoutMap["endTime"]    as? Timestamp,
                                let exercisesArr = workoutMap["exercises"] as? [[String: Any]]
                            else {
                                return nil
                            }
                            var logs: [ExerciseLog] = []
                            for ex in exercisesArr {
                                guard
                                    let name         = ex["name"]         as? String,
                                    let groupStrings = ex["muscleGroups"] as? [String],
                                    let setsArr      = ex["sets"]         as? [[String: Any]]
                                else { continue }
                                let groups = groupStrings.compactMap { MuscleGroup(rawValue: $0) }
                                var sets: [WorkoutSet] = []
                                for s in setsArr {
                                    if let reps = s["reps"] as? Int,
                                       let weight = s["weight"] as? Double {
                                        sets.append(WorkoutSet(reps: reps, weight: weight))
                                    }
                                }
                                logs.append(ExerciseLog(name: name, sets: sets, muscleGroups: groups))
                            }
                            let payload = WorkoutPayload(
                                startTime: startTS.dateValue(),
                                endTime:   endTS.dateValue(),
                                exercises: logs
                            )
                            return Post(
                                id: doc.documentID,
                                authorID:   authorID,
                                authorName: authorName,
                                timestamp:  ts.dateValue(),
                                likes:      likes,
                                title:      title,
                                description: description,
                                workout:    payload
                            )
                        }
                        completion(.success(posts))
                    }
            }
    }
}
