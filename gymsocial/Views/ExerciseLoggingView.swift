// Views/ExerciseLoggingView.swift

import SwiftUI

extension Notification.Name {
    /// Posted when the user finishes logging an exercise
    static let didFinishLoggingExercise = Notification.Name("didFinishLoggingExercise")
}

struct ExerciseLoggingView: View {
    @EnvironmentObject var workoutVM: WorkoutSessionViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var log: ExerciseLog
    private let index: Int?

    @State private var currentReps: Int
    @State private var currentWeight: Double

    init(log: ExerciseLog, index: Int?) {
        self.index = index
        _log = State(initialValue: log)
        let last = log.sets.last ?? WorkoutSet(reps: 5, weight: 135)
        _currentReps   = State(initialValue: last.reps)
        _currentWeight = State(initialValue: last.weight)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(log.name)
                    .font(.title2).bold()
                    .padding(.top)

                // Past sets
                if !log.sets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past Sets").font(.headline)
                        ForEach(log.sets.indices, id: \.self) { idx in
                            HStack {
                                Text("Set \(idx+1):")
                                Spacer()
                                Text("\(log.sets[idx].reps)x\(log.sets[idx].weight, specifier: "%.1f")")
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Divider().padding(.vertical)

                // Next-set controls
                Text("Set \(log.sets.count + 1)")
                    .font(.headline)

                Stepper("Reps: \(currentReps)", value: $currentReps, in: 1...50)
                    .padding(.horizontal)

                WeightSlider(weight: $currentWeight)
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    Button("Complete Set") {
                        let newSet = WorkoutSet(reps: currentReps, weight: currentWeight)
                        log.sets.append(newSet)
                        currentReps   = newSet.reps
                        currentWeight = newSet.weight
                    }
                    .disabled(currentReps < 1)

                    Spacer()

                    Button("Done") {
                        // 1) Save or overwrite in the session
                        if let i = index {
                            workoutVM.draft.exercises[i] = log
                        } else {
                            workoutVM.addCompletedExercise(log)
                        }
                        // 2) Dismiss this logging view
                        presentationMode.wrappedValue.dismiss()
                        // 3) Tell the exercise-list to pop itself too
                        NotificationCenter.default.post(
                            name: .didFinishLoggingExercise,
                            object: nil
                        )
                    }
                    .disabled(log.sets.isEmpty)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Log \(log.name)")
    }
}

/*
#if DEBUG
struct ExerciseLoggingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExerciseLoggingView(
                log: ExerciseLog(name: "Squat", sets: []),
                index: nil
            )
            .environmentObject(WorkoutSessionViewModel())
        }
    }
}
#endif
*/
