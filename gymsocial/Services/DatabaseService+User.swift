// Services/DatabaseService+User.swift
// gymsocial
//
// Uses the default Storage bucket from GoogleService-Info.plist and
// setData(merge: true) to create or merge the user document.

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension DatabaseService {
    /// Uploads a UIImage as the current user’s profile pic,
    /// stores it in Firebase Storage, then writes the downloadURL
    /// into the Firestore users collection (creating/merging the doc).
    func uploadProfileImage(
        _ image: UIImage,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // 1) Prepare UID & JPEG data
        guard
            let uid = Auth.auth().currentUser?.uid,
            let data = image.jpegData(compressionQuality: 0.8)
        else {
            completion(.failure(NSError(
                domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Auth/image error"]
            )))
            return
        }
        
        // 2) Reference your app’s Storage bucket (auto‑configured)
        let storageRef = Storage
            .storage()
            .reference()
            .child("profileImages/\(uid).jpg")
        
        // 3) Upload the image data
        storageRef.putData(data, metadata: nil) { _, uploadError in
            if let uploadError = uploadError {
                return completion(.failure(uploadError))
            }
            
            // 4) Retrieve the download URL
            storageRef.downloadURL { url, urlError in
                if let urlError = urlError {
                    return completion(.failure(urlError))
                }
                guard let url = url else {
                    return completion(.failure(NSError(
                        domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No download URL"]
                    )))
                }
                
                // 5) Write the URL into Firestore (create or merge user doc)
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData(
                        ["photoURL": url.absoluteString],
                        merge: true
                    ) { firestoreError in
                        if let firestoreError = firestoreError {
                            completion(.failure(firestoreError))
                        } else {
                            completion(.success(url))
                        }
                    }
            }
        }
    }
    
    /// Fetch list of users following `userId`.
    func fetchFollowers(for userId: String,
                        completion: @escaping (Result<[User], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
          .document(userId)
          .collection("followers")
          .getDocuments { snap, error in
            if let error = error {
                return completion(.failure(error))
            }
            let ids = snap?.documents.map { $0.documentID } ?? []
            self.fetchUsersByIds(ids, completion: completion)
        }
    }

    /// Fetch list of users that `userId` is following.
    func fetchFollowing(for userId: String,
                        completion: @escaping (Result<[User], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
          .document(userId)
          .collection("following")
          .getDocuments { snap, error in
            if let error = error {
                return completion(.failure(error))
            }
            let ids = snap?.documents.map { $0.documentID } ?? []
            self.fetchUsersByIds(ids, completion: completion)
        }
    }

    /// Helper to fetch User records for up to 10 IDs at a time.
    private func fetchUsersByIds(_ ids: [String],
                                 completion: @escaping (Result<[User], Error>) -> Void) {
        guard !ids.isEmpty else {
            return completion(.success([]))
        }
        let db = Firestore.firestore()
        var all: [User] = []
        var lastError: Error?
        let group = DispatchGroup()

        for chunk in ids.chunked(into: 10) {
            group.enter()
            db.collection("users")
              .whereField(FieldPath.documentID(), in: chunk)
              .getDocuments { snap, error in
                if let error = error {
                  lastError = error
                } else {
                  let fetched = snap?.documents.compactMap { doc -> User? in
                      let d = doc.data()
                      return User(
                        id: doc.documentID,
                        displayName: d["displayName"] as? String ?? "",
                        email:       d["email"]       as? String ?? "",
                        photoURL:    (d["photoURL"] as? String).flatMap(URL.init(string:))
                      )
                  } ?? []
                  all.append(contentsOf: fetched)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = lastError {
                completion(.failure(error))
            } else {
                completion(.success(all))
            }
        }
    }
    
    /// Fetch a single user’s profile data by UID.
    func fetchUser(withId userId: String,
                   completion: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
          .document(userId)
          .getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = snapshot?.data(), snapshot?.exists == true else {
                completion(.failure(NSError(
                  domain: "DatabaseService",
                  code: -1,
                  userInfo: [NSLocalizedDescriptionKey: "User not found"]
                )))
                return
            }
            let user = User(
                id: snapshot!.documentID,
                displayName: data["displayName"] as? String ?? "",
                email:       data["email"]       as? String ?? "",
                photoURL:    (data["photoURL"] as? String).flatMap(URL.init(string:))
            )
            completion(.success(user))
        }
    }
    
    /// Fetch up to `limit` users for default display.
    /// Logs returned document IDs.
    ///
    ///
    func fetchPosts(for userId: String,
                    completion: @escaping (Result<[Post], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("posts")
            .whereField("authorID", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    return completion(.failure(error))
                }
                let docs = snapshot?.documents ?? []
                let posts: [Post] = docs.compactMap { doc in
                    let d = doc.data()

                    // required top-level fields
                    guard
                        let authorID   = d["authorID"]   as? String,
                        let authorName = d["authorName"] as? String,
                        let ts         = d["timestamp"]  as? Timestamp,
                        let likes      = d["likes"]      as? Int,
                        let title      = d["title"]      as? String,
                        let workoutMap = d["workout"]    as? [String: Any]
                    else {
                        return nil  // filtered out by compactMap
                    }

                    let description = d["description"] as? String

                    // required workout payload fields
                    guard
                        let startTS      = workoutMap["startTime"]  as? Timestamp,
                        let endTS        = workoutMap["endTime"]    as? Timestamp,
                        let exercisesArr = workoutMap["exercises"] as? [[String: Any]]
                    else {
                        return nil
                    }

                    // build ExerciseLog array
                    let exercises: [ExerciseLog] = exercisesArr.compactMap { exDict in
                        guard
                            let name         = exDict["name"]         as? String,
                            let groupStrings = exDict["muscleGroups"] as? [String],
                            let setsArr      = exDict["sets"]         as? [[String: Any]]
                        else { return nil }

                        let groups = groupStrings.compactMap(MuscleGroup.init)
                        let sets = setsArr.compactMap { setDict -> WorkoutSet? in
                            guard
                                let reps   = setDict["reps"]   as? Int,
                                let weight = setDict["weight"] as? Double
                            else { return nil }
                            return WorkoutSet(reps: reps, weight: weight)
                        }

                        return ExerciseLog(name: name, sets: sets, muscleGroups: groups)
                    }

                    let payload = WorkoutPayload(
                        startTime: startTS.dateValue(),
                        endTime:   endTS.dateValue(),
                        exercises: exercises
                    )

                    // now return a non-optional Post
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
                completion(.success(posts))
            }
    }
    
    func fetchUsers(limit: Int = 5,
                    completion: @escaping (Result<[User], Error>) -> Void) {
        let db = Firestore.firestore()
        // Raw fetch without ordering
        db.collection("users")
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("fetchUsers raw error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    print("fetchUsers raw: no snapshot.documents")
                    completion(.success([]))
                    return
                }
                print("fetchUsers raw returned IDs: \(docs.map { $0.documentID })")
                let users = docs.compactMap { doc -> User? in
                    let data = doc.data()
                    return User(
                        id: doc.documentID,
                        displayName: data["displayName"] as? String ?? "",
                        email:       data["email"]       as? String ?? "",
                        photoURL:    (data["photoURL"] as? String).flatMap(URL.init(string:))
                    )
                }
                completion(.success(users))
            }
    }

    /// Search users whose displayName starts with `name`
    /// Logs returned document IDs.
    func searchUsers(byName name: String,
                     completion: @escaping (Result<[User], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .order(by: "displayName")
            .start(at: [name])
            .end(at: [name + "\u{f8ff}"])
            .limit(to: 20)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("searchUsers error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    print("searchUsers: no snapshot.documents for prefix '\(name)'")
                    completion(.success([]))
                    return
                }
                print("searchUsers(\"\(name)\") returned IDs: \(docs.map { $0.documentID })")
                let users = docs.compactMap { doc -> User? in
                    let data = doc.data()
                    return User(
                        id: doc.documentID,
                        displayName: data["displayName"] as? String ?? "",
                        email:       data["email"]       as? String ?? "",
                        photoURL:    (data["photoURL"] as? String).flatMap(URL.init(string:))
                    )
                }
                completion(.success(users))
            }
    }
}
