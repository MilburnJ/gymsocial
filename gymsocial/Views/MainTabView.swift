import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var workoutVM = WorkoutSessionViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Label("Feed", systemImage: "house")
            }

            NavigationStack {
                WorkoutSessionView()
            }
            .environmentObject(session)
            .environmentObject(workoutVM)
            .tabItem {
                Label("Workout", systemImage: "play.circle")
            }

            NavigationStack {
                ProfileView()
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
