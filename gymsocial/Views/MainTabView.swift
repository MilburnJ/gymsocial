import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var workoutVM = WorkoutSessionViewModel()

    var body: some View {
        TabView {
            // Feed Tab
            NavigationStack {
                FeedView()
                    .navigationTitle("Feed")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Feed", systemImage: "house")
            }

            // Workout Tab
            NavigationStack {
                WorkoutSessionView()
                    .navigationTitle("Workout")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(session)
            .environmentObject(workoutVM)
            .tabItem {
                Label("Workout", systemImage: "play.circle")
            }

            // Profile Tab
            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")                  // ← single nav title here
                    .navigationBarTitleDisplayMode(.inline)      // ← inline style
            }
            .environmentObject(session)
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
        .environmentObject(session)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(SessionViewModel())
    }
}
#endif
