//
//  FeedViewModel.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import Foundation
import Combine
import FirebaseFirestore

/// ViewModel for the Feed screen, listens to Firestore for new posts.
final class FeedViewModel: ObservableObject {
    /// Published list of posts to display
    @Published var posts: [Post] = []
    private var listener: ListenerRegistration?

    init() {
        fetchPosts()
    }

    deinit {
        listener?.remove()
    }

    /// Attaches a real-time listener to the "posts" collection,
    /// ordering by timestamp descending.
    private func fetchPosts() {
        let db = Firestore.firestore()
        listener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else {
                    return
                }
                // Map Firestore documents into Post models
                self.posts = documents.compactMap { doc in
                    let data = doc.data()
                    // Manual decoding since FirebaseFirestoreSwift isn't available
                    guard let authorID = data["authorID"] as? String,
                          let authorName = data["authorName"] as? String,
                          let timestampValue = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    let contentText = data["contentText"] as? String
                    let imageURL    = data["imageURL"] as? String
                    let likes       = data["likes"] as? Int ?? 0

                    return Post(
                        id: doc.documentID,
                        authorID: authorID,
                        authorName: authorName,
                        contentText: contentText,
                        imageURL: imageURL,
                        timestamp: timestampValue.dateValue(),
                        likes: likes
                    )
                }
            }
    }
}
