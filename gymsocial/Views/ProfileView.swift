// Views/ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // MARK: — Profile Header
                if let user = session.currentUser {
                    Text(user.displayName)
                        .font(.title2).bold()
                    Text(user.email)
                        .foregroundColor(.secondary)
                } else {
                    Text("Not signed in")
                        .foregroundColor(.secondary)
                }

                Divider()

                // MARK: — Workout History
                if vm.workouts.isEmpty {
                    Text("No workouts logged yet")
                        .italic()
                        .foregroundColor(.secondary)
                } else {
                    List(vm.workouts) { post in
                        NavigationLink(destination: WorkoutDetailView(post: post)) {
                            ProfileWorkoutRow(post: post)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()

                // MARK: — Sign Out
                Button("Sign Out") {
                    do { try AuthService.shared.signOut() }
                    catch { print("Sign out failed:", error) }
                }
                .foregroundColor(.red)
                .padding(.vertical, 8)
            }
            .padding()
            .navigationTitle("Profile")
            .onAppear {
                if let uid = session.currentUser?.id {
                    vm.subscribe(userId: uid)
                }
            }
        }
    }
}

private struct ProfileWorkoutRow: View {
    let post: Post

    private var dateText: String {
        post.timestamp.formatted(.dateTime.month().day().year())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            Text(post.title)
                .font(.headline)

            // Optional description
            if let desc = post.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Date and first-exercise summary
            HStack {
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(post.workout.summary
                        .components(separatedBy: "\n")
                        .first ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionViewModel())
    }
}
#endif
