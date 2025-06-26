import SwiftUI

struct SelectMuscleGroupView: View {
    var body: some View {
        List(MuscleGroup.allCases) { group in
            NavigationLink(group.displayName) {
                SelectExerciseView(muscleGroup: group)
            }
        }
        .navigationTitle("Muscle Group")
    }
}
