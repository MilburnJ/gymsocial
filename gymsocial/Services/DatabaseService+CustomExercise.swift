//
//  DatabaseService+CustomExercise.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension DatabaseService {
    /// Add a new custom exercise under /users/{uid}/customExercises
    func addCustomExercise(
        _ exercise: CustomExercise,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(NSError(domain:"",code:-1)))
        }
        let data: [String:Any] = [
            "name":         exercise.name,
            "muscleGroups": exercise.muscleGroups.map { $0.rawValue }
        ]
        Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("customExercises")
          .addDocument(data: data) { err in
            if let e = err { completion(.failure(e)) }
            else          { completion(.success(())) }
          }
    }

    /// Fetch all custom exercises for the signed-in user
    func fetchCustomExercises(
        completion: @escaping (Result<[CustomExercise], Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success([]))
        }
        Firestore.firestore()
          .collection("users")
          .document(uid)
          .collection("customExercises")
          .getDocuments { snap, err in
            if let e = err { return completion(.failure(e)) }
            let exercises: [CustomExercise] = snap?.documents.compactMap { doc in
                let d = doc.data()
                guard
                  let name = d["name"] as? String,
                  let groups = d["muscleGroups"] as? [String]
                else { return nil }
                let mg = groups.compactMap { MuscleGroup(rawValue: $0) }
                return CustomExercise(id: doc.documentID, name: name, muscleGroups: mg)
            } ?? []
            completion(.success(exercises))
        }
    }
    
    /// Deletes a custom exercise document under the current user's customExercises subcollection
        func deleteCustomExercise(
            _ exerciseId: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            // 1) Make sure we have a signed-in user
            guard let uid = Auth.auth().currentUser?.uid else {
                let err = NSError(
                    domain: "DatabaseService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User not signed in"]
                )
                return completion(.failure(err))
            }

            // 2) Perform the delete
            Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("customExercises")
                .document(exerciseId)
                .delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        }
}
