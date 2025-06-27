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
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    List(vm.workouts) { post in
                        NavigationLink(destination: WorkoutDetailView(workout: post.workout)) {
                            HStack {
                                // formatted date
                                Text(post.timestamp.formatted(.dateTime.month().day().year()))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                // show first exercise summary
                                Text(post.workout.summary.components(separatedBy: "\n").first ?? "")
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()

                // MARK: — Sign Out
                Button("Sign Out") {
                    do {
                        try AuthService.shared.signOut()
                    } catch {
                        print("Sign out error:", error)
                    }
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

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionViewModel())
    }
}
#endif
