import SwiftUI

struct SelectExerciseView: View {
    let muscleGroup: MuscleGroup

    // Filtered list of built-in exercises
    private var exercises: [Exercise] {
        Exercise.all.filter { $0.muscleGroup == muscleGroup }
    }

    var body: some View {
        List(exercises) { exercise in
            NavigationLink(exercise.name) {
                ExerciseLoggingView(exercise: exercise)
            }
        }
        .navigationTitle(muscleGroup.displayName)
    }
}
