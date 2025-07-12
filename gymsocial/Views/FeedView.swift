// Views/FeedView.swift

import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.posts, id: \.id) { post in
                        NavigationLink(destination: WorkoutDetailView(post: post)) {
                            WorkoutRow(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Feed")
            .refreshable { vm.reload() }
        }
    }
}

private struct WorkoutRow: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)

            if let desc = post.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("\(post.authorName) logged a workout")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(post.workout.summary.components(separatedBy: "\n").first ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
#endif
