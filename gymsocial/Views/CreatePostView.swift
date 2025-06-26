//
//  CreatePostView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import SwiftUI

struct CreatePostView: View {
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
        isPosting = true
        // TODO: call DatabaseService to save postText
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPosting = false
            postText = ""
        }
    }
}
