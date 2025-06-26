//
//  FeedView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.authorName)
                        .font(.headline)
                    if let content = post.contentText {
                        Text(content)
                            .font(.body)
                    }
                    Text(post.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Feed")
        }
    }
}
