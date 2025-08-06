// Services/AuthService.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: Error {
    case emailAlreadyInUse
    case invalidCredentials
    case unknownError
}

final class AuthService {
    static let shared = AuthService()
    private init() {}

    /// Sign up and return your Firestore-backed User model
    func signUp(
        email: String,
        password: String,
        displayName: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            // 1) FirebaseAuth errors
            if let err = error as NSError? {
                switch AuthErrorCode(rawValue: err.code) {
                case .emailAlreadyInUse:
                    completion(.failure(.emailAlreadyInUse))
                case .weakPassword:
                    completion(.failure(.invalidCredentials))
                default:
                    completion(.failure(.invalidCredentials))
                }
                return
            }

            guard let fbUser = result?.user else {
                completion(.failure(.unknownError))
                return
            }

            // 2) Set Auth displayName
            let changeRequest = fbUser.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { _ in
                // ignore errors here—Firestore is our source of truth
                // 3) Write Firestore user doc
                let data: [String: Any] = [
                    "displayName": displayName,
                    "email": email
                ]
                Firestore.firestore()
                    .collection("users")
                    .document(fbUser.uid)
                    .setData(data) { error in
                        if let _ = error {
                            completion(.failure(.unknownError))
                        } else {
                            // 4) Return your User model
                            let user = User(
                                id: fbUser.uid,
                                displayName: displayName,
                                email: email,
                                photoURL: nil
                            )
                            completion(.success(user))
                        }
                    }
            }
        }
    }

    /// Log in and return your Firestore-backed User model
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error as NSError? {
                completion(.failure(.invalidCredentials))
                return
            }
            guard let fbUser = result?.user else {
                completion(.failure(.unknownError))
                return
            }
            // Fetch Firestore user profile
            Firestore.firestore()
                .collection("users")
                .document(fbUser.uid)
                .getDocument { snap, error in
                    if let _ = error {
                        completion(.failure(.unknownError))
                        return
                    }
                    guard
                        let d = snap?.data(),
                        let name = d["displayName"] as? String,
                        let email = d["email"] as? String
                    else {
                        completion(.failure(.unknownError))
                        return
                    }
                    let user = User(
                        id: fbUser.uid,
                        displayName: name,
                        email: email,
                        photoURL: nil
                    )
                    completion(.success(user))
                }
        }
    }

    /// Synchronous sign‐out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
