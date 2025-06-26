import SwiftUI

struct ExerciseLoggingView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = WorkoutSessionViewModel() // or inject one shared VM
    let exercise: Exercise

    @State private var sets: [WorkoutSet] = []
    @State private var currentReps = 5
    @State private var currentWeight = 135.0

    var body: some View {
        VStack(spacing: 24) {
            Text(exercise.name)
                .font(.title2).bold()

            // Show current set number
            Text("Set \(sets.count + 1)")
                .font(.headline)

            // Reps slider / stepper
            Stepper("\(currentReps) reps", value: $currentReps, in: 1...50)

            // Weight slider
            WeightSlider(weight: $currentWeight)

            HStack(spacing: 16) {
                Button("Complete Set") {
                    let newSet = WorkoutSet(
                        reps: currentReps,
                        weight: currentWeight
                    )
                    sets.append(newSet)
                }
                .disabled(currentReps < 1)

                // Finish exercise and save
                Button("Done") {
                    let log = ExerciseLog(name: exercise.name, sets: sets)
                    vm.addCompletedExercise(log)
                    // Pop back one level
                    // (assuming NavigationStack context)
                    // Or use environment dismiss:
                    // presentationMode.wrappedValue.dismiss()
                }
                .disabled(sets.isEmpty)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Log \(exercise.name)")
    }
}
