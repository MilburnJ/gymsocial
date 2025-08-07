import SwiftUI

extension Notification.Name {
    static let followingDidChange = Notification.Name("followingDidChange")
}

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
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
        .refreshable { vm.reload() }
        .onReceive(NotificationCenter.default.publisher(for: .followingDidChange)) { _ in
            vm.reload()
        }
        .onAppear { vm.reload() }
    }
}

private struct WorkoutRow: View {
    let post: Post
    @State private var authorPhotoURL: URL?

    /// All the muscle groups this workout hit
    private var muscleHighlights: Set<MuscleGroup> {
        Set(post.workout.exercises.flatMap { $0.muscleGroups })
    }

    private func loadAuthorPhoto() {
        DatabaseService.shared.fetchUser(withId: post.authorID) { result in
            if case .success(let user) = result {
                DispatchQueue.main.async {
                    authorPhotoURL = user.photoURL
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile header
            HStack(spacing: 12) {
                if let url = authorPhotoURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }

                NavigationLink(destination: PublicProfileView(userId: post.authorID)) {
                    Text(post.authorName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(post.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .onAppear(perform: loadAuthorPhoto)

            // Post title & description
            Text(post.title)
                .font(.headline)
            if let desc = post.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Workout diagram
            MuscleDiagramView(highlight: muscleHighlights)
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 400)
                .clipped()

            // Summary line
            Text(post.workout.summary
                    .components(separatedBy: "\n")
                    .first ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}
