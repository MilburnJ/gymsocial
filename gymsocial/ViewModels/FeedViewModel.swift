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
                if let error = error {
                    print("Feed listener error:", error.localizedDescription)
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents in snapshot")
                    return
                }
                print("Fetched \(documents.count) post docs")
                documents.forEach { doc in
                    print(" • ", doc.documentID, doc.data())
                }

                self?.posts = documents.compactMap { doc in
                    let data = doc.data()

                    // Make sure these keys exist exactly as you expect in the console
                    guard
                      let authorID   = data["authorID"]   as? String,
                      let authorName = data["authorName"] as? String
                    else {
                        print("Missing authorID/authorName in", doc.documentID)
                        return nil
                    }

                    // The timestamp might not be set yet on first local write—
                    // let’s fall back to now if it’s missing:
                    let timestamp: Date
                    if let ts = data["timestamp"] as? Timestamp {
                        timestamp = ts.dateValue()
                    } else {
                        print("No timestamp in", doc.documentID, "- using Date() fallback")
                        timestamp = Date()
                    }

                    let contentText = data["contentText"] as? String
                    let imageURL    = data["imageURL"]    as? String
                    let likes       = data["likes"]       as? Int    ?? 0

                    return Post(
                      id:           doc.documentID,
                      authorID:     authorID,
                      authorName:   authorName,
                      contentText:  contentText,
                      imageURL:     imageURL,
                      timestamp:    timestamp,
                      likes:        likes
                    )
                }
            }
    }

}
