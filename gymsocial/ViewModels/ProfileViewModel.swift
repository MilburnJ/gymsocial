// ViewModels/ProfileViewModel.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

final class ProfileViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var user: User?
    @Published var profileImage: UIImage?
    @Published var workouts: [Post] = []
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var recentHighlighted: Set<MuscleGroup> = []

    // MARK: - Private listeners
    private var userListener: ListenerRegistration?
    private var workoutListener: ListenerRegistration?

    /// Subscribe to user doc, workouts, and follower/following counts.
    func subscribe(userId: String) {
        listenToUser(userId: userId)
        listenToWorkouts(userId: userId)
        fetchFollowersCount(userId: userId)
        fetchFollowingCount(userId: userId)
    }

    private func listenToUser(userId: String) {
        userListener?.remove()
        userListener = Firestore.firestore()
            .collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self,
                      let data = snap?.data() else { return }

                let id = snap!.documentID
                let displayName = data["displayName"] as? String ?? ""
                let email       = data["email"]       as? String ?? ""
                let urlString   = data["photoURL"]    as? String
                let photoURL    = urlString.flatMap(URL.init)

                DispatchQueue.main.async {
                    self.user = User(
                        id: id,
                        displayName: displayName,
                        email: email,
                        photoURL: photoURL
                    )
                }

                if let url = photoURL {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let img = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profileImage = img
                            }
                        }
                    }
                    .resume()
                }
            }
    }

    private func listenToWorkouts(userId: String) {
        workoutListener?.remove()
        workoutListener = Firestore.firestore()
            .collection("posts")
            .whereField("type",     isEqualTo: "workout")
            .whereField("authorID", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self,
                      let docs = snap?.documents else { return }

                var loaded: [Post] = []
                for doc in docs {
                    let d = doc.data()
                    guard
                        let authorID   = d["authorID"]   as? String,
                        let authorName = d["authorName"] as? String,
                        let ts         = d["timestamp"]  as? Timestamp,
                        let likes      = d["likes"]      as? Int,
                        let title      = d["title"]      as? String,
                        let workoutMap = d["workout"]    as? [String:Any]
                    else { continue }
                    let description = d["description"] as? String

                    guard
                        let startTS      = workoutMap["startTime"]  as? Timestamp,
                        let endTS        = workoutMap["endTime"]    as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String:Any]]
                    else { continue }

                    var logs: [ExerciseLog] = []
                    for ex in exercisesArr {
                        guard
                            let name         = ex["name"]         as? String,
                            let groupStrings = ex["muscleGroups"] as? [String],
                            let setsArr      = ex["sets"]         as? [[String:Any]]
                        else { continue }

                        let groups = groupStrings.compactMap { MuscleGroup(rawValue: $0) }
                        var sets: [WorkoutSet] = []
                        for s in setsArr {
                            if let reps = s["reps"] as? Int,
                               let weight = s["weight"] as? Double {
                                sets.append(WorkoutSet(reps: reps, weight: weight))
                            }
                        }
                        logs.append(ExerciseLog(
                            name:          name,
                            sets:          sets,
                            muscleGroups: groups
                        ))
                    }

                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: logs
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
                    loaded.append(post)
                }

                let cutoff = Date().addingTimeInterval(-48*3600)
                let recentGroups = loaded
                    .filter { $0.timestamp >= cutoff }
                    .flatMap { $0.workout.exercises.flatMap { $0.muscleGroups } }

                DispatchQueue.main.async {
                    self.workouts          = loaded
                    self.recentHighlighted = Set(recentGroups)
                }
            }
    }

    // MARK: - Follower / Following counts

    private func fetchFollowersCount(userId: String) {
        DatabaseService.shared.fetchFollowers(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.followersCount = users.count
                case .failure:
                    self.followersCount = 0
                }
            }
        }
    }

    private func fetchFollowingCount(userId: String) {
        DatabaseService.shared.fetchFollowing(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.followingCount = users.count
                case .failure:
                    self.followingCount = 0
                }
            }
        }
    }

    // MARK: - Uploading a new profile image

    func uploadProfileImage(_ image: UIImage) {
        DatabaseService.shared.uploadProfileImage(image) { [weak self] (result: Result<URL, Error>) in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profileImage = img
                        }
                    }
                }
                .resume()
            case .failure(let err):
                print("Failed to upload profile image:", err)
            }
        }
    }

    deinit {
        userListener?.remove()
        workoutListener?.remove()
    }
}
