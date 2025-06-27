import SwiftUI

// Helper for each completed exercise row
private struct CompletedExerciseRow: View {
    let log: ExerciseLog

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.name)
                    .font(.headline)
                Text(log.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Extend ExerciseLog to provide a “5x135, 5x140” style summary
private extension ExerciseLog {
    var summary: String {
        sets
            .map { "\($0.reps)x\($0.weight)" }
            .joined(separator: ", ")
    }
}

struct WorkoutSessionView: View {
    @StateObject private var vm = WorkoutSessionViewModel()
    @EnvironmentObject var session: SessionViewModel

    // Format elapsed seconds as HH:mm:ss
    private var elapsedText: String {
        Duration.seconds(vm.elapsed)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    var body: some View {
        VStack(spacing: 16) {
            // 1) Timer
            Text(elapsedText)
                .font(.largeTitle).bold()
                .padding(.top)

            // 2) Muscle-group carousel → navigates to SelectExerciseView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MuscleGroup.allCases) { group in
                        NavigationLink {
                            SelectExerciseView(muscleGroup: group)
                                .environmentObject(vm)
                        } label: {
                            VStack {
                                Image(systemName: group.sfSymbolName)
                                    .font(.title2)
                                Text(group.displayName)
                                    .font(.caption)
                            }
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 3) Completed Exercises
            if vm.draft.exercises.isEmpty {
                Text("No exercises logged yet")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                List {
                    ForEach(vm.draft.exercises) { log in
                        CompletedExerciseRow(log: log)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 200) // adjust as you like
            }

            Spacer()

            // 4) Finish Workout & Post
            Button("Finish Workout & Post") {
                vm.finishAndPost { _ in /* handle success */ }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Workout")
    }
}

#if DEBUG
struct WorkoutSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutSessionView()
                .environmentObject(SessionViewModel())
        }
    }
}
#endif
