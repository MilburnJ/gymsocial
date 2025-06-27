import SwiftUI

struct SelectExerciseView: View {
    @EnvironmentObject var workoutVM: WorkoutSessionViewModel
    let muscleGroup: MuscleGroup

    // Only show exercises for the chosen muscle group
    private var exercises: [Exercise] {
        Exercise.all.filter { $0.muscleGroup == muscleGroup }
    }

    var body: some View {
        List(exercises) { exercise in
            NavigationLink {
                // Create a brand-new ExerciseLog (no sets yet) and pass index = nil
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
