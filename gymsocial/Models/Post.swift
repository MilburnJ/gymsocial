//
//  Post.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import Foundation

/// Model representing a social post in Firestore
struct Post: Identifiable {
    var id: String            // Firestore document ID
    var authorID: String      // UID of the author
    var authorName: String    // Display name of the author
    var contentText: String?  // Optional text content
    var imageURL: String?     // Optional URL string for an image
    var timestamp: Date       // Date the post was created
    var likes: Int            // Number of likes
}
