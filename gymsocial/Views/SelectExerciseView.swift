// Views/SelectExerciseView.swift

import SwiftUI

struct SelectExerciseView: View {
    @EnvironmentObject var vm: WorkoutSessionViewModel
    @Environment(\.presentationMode) private var presentationMode

    let muscleGroup: MuscleGroup
    @State private var searchText = ""

    // The custom exercise the user tapped “–” on
    @State private var exerciseToDelete: CustomExercise?
    // Controls showing the confirmation alert
    @State private var showDeleteAlert = false

    // MARK: – Built‐in exercises in this group, filtered by searchText
    private var builtIn: [Exercise] {
        Exercise.all
            .filter { $0.muscleGroup == muscleGroup }
            .filter {
                searchText.isEmpty ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
    }

    // MARK: – The user’s custom exercises for this group, filtered
    private var custom: [CustomExercise] {
        vm.customExercises
            .filter { $0.muscleGroups.contains(muscleGroup) }
            .filter {
                searchText.isEmpty ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        List {
            // 1) Search field
            Section {
                TextField("Search \(muscleGroup.displayName)…", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // 2) All exercises
            Section("Exercises") {
                // – built-in
                ForEach(builtIn) { ex in
                    NavigationLink {
                        ExerciseLoggingView(
                            log: ExerciseLog(name: ex.name, sets: []),
                            index: nil
                        )
                        .environmentObject(vm)
                    } label: {
                        Text(ex.name)
                    }
                }

                // – custom (italicized + delete button)
                ForEach(custom) { ex in
                    HStack {
                        NavigationLink {
                            ExerciseLoggingView(
                                log: ExerciseLog(name: ex.name, sets: []),
                                index: nil
                            )
                            .environmentObject(vm)
                        } label: {
                            Text(ex.name)
                                .italic()
                        }

                        Spacer()

                        Button {
                            // queue up this exercise for deletion
                            exerciseToDelete = ex
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(muscleGroup.displayName)
        // pop back to workout session when logging finishes
        .onReceive(NotificationCenter.default.publisher(
            for: .didFinishLoggingExercise)
        ) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        // 3) Confirmation alert, driven by $showDeleteAlert
        .alert("Delete Exercise?",
               isPresented: $showDeleteAlert
        ) {
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let toDelete = exerciseToDelete {
                    vm.deleteCustomExercise(toDelete) { _ in
                        // VM will update its array on success
                    }
                }
                exerciseToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete “\(exerciseToDelete?.name ?? "")”?")
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
