//
//  DatabaseService.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import Foundation
import FirebaseFirestore

/// Service for interacting with Firestore collections (e.g., posts).
final class DatabaseService {
    static let shared = DatabaseService()
    private init() { }

    private let db = Firestore.firestore()

    /// Creates a new post document in "posts" collection.
    /// - Parameters:
    ///   - contentText: Optional text content of the post.
    ///   - imageURL: Optional URL string for an image.
    ///   - author: The User who is creating the post.
    ///   - completion: Called with success or error when write completes.
    func createPost(
        contentText: String,
        imageURL: String? = nil,
        author: User,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Build dictionary for Firestore
        var data: [String: Any] = [
            "authorID": author.id,
            "authorName": author.displayName,
            "timestamp": FieldValue.serverTimestamp(),
            "likes": 0
        ]
        if !contentText.isEmpty {
            data["contentText"] = contentText
        }
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }

        // Write to Firestore
        db.collection("posts").addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
