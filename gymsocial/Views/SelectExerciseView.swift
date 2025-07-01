// Views/SelectExerciseView.swift

import SwiftUI

struct SelectExerciseView: View {
    @EnvironmentObject var workoutVM: WorkoutSessionViewModel
    @Environment(\.presentationMode) private var presentationMode

    let muscleGroup: MuscleGroup

    // Filter exercises by the chosen muscle group
    private var exercises: [Exercise] {
        Exercise.all.filter { $0.muscleGroup == muscleGroup }
    }

    var body: some View {
        List(exercises) { exercise in
            NavigationLink {
                ExerciseLoggingView(
                    log: ExerciseLog(name: exercise.name, sets: []),
                    index: nil
                )
                .environmentObject(workoutVM)
            } label: {
                Text(exercise.name)
            }
        }
        .navigationTitle(muscleGroup.displayName)
        // Listen for the “done logging” notification and dismiss
        .onReceive(
            NotificationCenter.default.publisher(
                for: .didFinishLoggingExercise
            )
        ) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#if DEBUG
struct SelectExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectExerciseView(muscleGroup: .legs)
                .environmentObject(WorkoutSessionViewModel())
        }
    }
}
#endif
