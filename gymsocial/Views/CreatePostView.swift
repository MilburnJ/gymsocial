//
//  CreatePostView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import SwiftUI
import FirebaseFirestore

struct CreatePostView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var postText = ""
    @State private var isPosting = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $postText)
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1))

                Button(action: submitPost) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Text("Post")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(postText.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(postText.isEmpty || isPosting)

                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
        }
    }

    private func submitPost() {
        guard let user = session.currentUser else { return }
        isPosting = true
        DatabaseService.shared.createPost(
            contentText: postText,
            imageURL: nil,
            author: user
        ) { result in
            DispatchQueue.main.async {
                isPosting = false
                switch result {
                case .success():
                    postText = ""
                case .failure(let error):
                    print("Error creating post:", error)
                    // Optionally show an alert here
                }
            }
        }
    }

}
