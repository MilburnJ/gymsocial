import SwiftUI

struct WorkoutSessionView: View {
    @StateObject private var vm = WorkoutSessionViewModel()

    var body: some View {
        VStack {
            // Live timer display
            Text(vm.elapsed.formatted(.time(pattern: "HH:mm:ss")))
                .font(.largeTitle).bold()
                .padding()

            List {
                ForEach($vm.draft.exercises) { $exercise in
                    Section(header: Text(exercise.name)) {
                        ForEach($exercise.sets) { $set in
                            HStack {
                                // Reps stepper
                                Stepper("\(set.reps) reps", value: $set.reps, in: 1...50)
                                Spacer()
                                // Weight slider
                                WeightSlider(weight: $set.weight)
                            }
                        }
                        Button("Add Set") {
                            let last = exercise.sets.last!
                            exercise.sets.append(
                                WorkoutSet(reps: last.reps, weight: last.weight)
                            )
                        }
                    }
                }
            }

            // Finish & post button
            Button("Finish Workout & Post") {
                vm.finishAndPost { _ in
                    // You can navigate back or reset the session here
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .navigationTitle("Workout Session")
    }
}
