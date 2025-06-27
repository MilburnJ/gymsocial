// Views/FeedView.swift

import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.posts) { post in
                        NavigationLink(destination: WorkoutDetailView(workout: post.workout)) {
                            WorkoutRow(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Feed")
            .refreshable {
                vm.reload()
            }
        }
    }
}

private struct WorkoutRow: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(post.authorName) logged a workout")
                .font(.headline)
            Text(post.workout.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2)
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
#endif
