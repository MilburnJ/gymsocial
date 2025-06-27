import SwiftUI

struct MainTabView: View {
    // your existing session view model
    @EnvironmentObject var session: SessionViewModel

    // create one WorkoutSessionViewModel for the entire workout flow
    @StateObject private var workoutVM = WorkoutSessionViewModel()

    var body: some View {
        TabView {
            // Feed tab
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Label("Feed", systemImage: "house")
            }

            // New Post tab
            NavigationStack {
                CreatePostView()
            }
            .environmentObject(session)
            .tabItem {
                Label("New Post", systemImage: "plus.square")
            }

            // Workout tab — inject the workoutVM here
            NavigationStack {
                WorkoutSessionView()
            }
            .environmentObject(workoutVM)
            .tabItem {
                Label("Workout", systemImage: "play.circle")
            }

            // Profile tab
            NavigationStack {
                ProfileView()
            }
            .environmentObject(session)
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
        // make sure session is available everywhere
        .environmentObject(session)
    }
}
