// Services/DatabaseService+User.swift
// gymsocial
//
// Uses the default Storage bucket from GoogleService-Info.plist and
// setData(merge: true) to create or merge the user document.

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

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
}
