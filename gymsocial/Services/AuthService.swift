//
//  AuthService.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

//simple enum for auth related errors
enum AuthError: Error {
    case invalidCredentials
    case unknownError
}

//Service that wraps firebase Auth + Firestore Calls
final class AuthService {
    static let shared = AuthService()
    private init() { }
    
    //
    //Register New User
    //
    
    func signUp(
        email: String,
        password: String,
        displayName: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ){
        Auth.auth().createUser(withEmail: email, password: password) {result, error in
            //if theres any eror creating the Auth user, map to invalidCredentials
            if let _ = error {
                completion(.failure(.invalidCredentials))
                return
            }
            //Ensure we get a valid FireBaseAuth user
            guard let firebaseUser = result?.user else {
                completion(.failure(.unknownError))
                return
            }
            //Build a plain Swift 'user' struct
            let newUser = User(
                id: firebaseUser.uid,
                displayName: displayName,
                email: firebaseUser.email ?? "",
                profilePhotoURL: nil
            )
            //Create a dictionary for Firestore with the fields we want
            let userData: [String: Any] = [
                "displayName": newUser.displayName,
                "email": newUser.email,
                "profilePhotoURL": newUser.profilePhotoURL as Any
            ]
            //Write that dictionary into Firestore under user/{uid}
            let db = Firestore.firestore()
            db.collection("users")
                .document(newUser.id)
                .setData(userData) {error in
                    if let _ = error {
                        completion(.failure(.unknownError))
                    } else {
                        completion(.success(newUser))
                    }
                }
        }
    }
    
    //
    // Login Existing User
    //
    
    func login(
            email: String,
            password: String,
            completion: @escaping (Result<User, AuthError>) -> Void
        ) {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                // 1) FirebaseAuth error
                if let err = error as NSError? {
                    print("[Auth] signIn error: \(err.localizedDescription) code: \(err.code)")
                    completion(.failure(.invalidCredentials))
                    return
                }
                // 2) Missing Firebase user?
                guard let firebaseUser = result?.user else {
                    print("[Auth] no user returned from signIn, result: \(String(describing: result))")
                    completion(.failure(.unknownError))
                    return
                }
                // 3) Fetch Firestore profile
                let docRef = Firestore.firestore().collection("users").document(firebaseUser.uid)
                docRef.getDocument { snapshot, error in
                    if let err = error {
                        print("[Auth] Firestore getUser error: \(err.localizedDescription)")
                        completion(.failure(.unknownError))
                        return
                    }
                    // Debug logging
                    print("[Auth] getUser snapshot exists? → \(snapshot?.exists ?? false)")
                    print("[Auth] getUser document path → \(docRef.path)")
                    print("[Auth] getUser raw snapshot data → \(String(describing: snapshot?.data()))")

                    guard let snap = snapshot, snap.exists, let data = snap.data() else {
                        print("[Auth] user document missing or malformed; data: \(String(describing: snapshot?.data()))")
                        completion(.failure(.unknownError))
                        return
                    }
                    // Decode fields
                    let id = snap.documentID
                    let displayName = data["displayName"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let photoURL = data["profilePhotoURL"] as? String
                    let user = User(id: id, displayName: displayName, email: email, profilePhotoURL: photoURL)
                    completion(.success(user))
                }
            }
        }

    
    //
    // Sign Out Current User
    //
    
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(.unknownError))
        }
    }
}
