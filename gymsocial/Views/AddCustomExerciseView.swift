//
//  AddCustomExerciseView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/30/25.
//


import SwiftUI

struct AddCustomExerciseView: View {
    @EnvironmentObject var vm: WorkoutSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedGroups: Set<MuscleGroup> = []
    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Exercise name", text: $name)
                }
                Section("Muscle Groups") {
                    ForEach(MuscleGroup.allCases) { group in
                        Toggle(group.displayName, isOn:
                            Binding(
                                get: { selectedGroups.contains(group) },
                                set: {
                                    if $0 { selectedGroups.insert(group) }
                                    else  { selectedGroups.remove(group) }
                                }
                            )
                        )
                    }
                }
                if let err = errorText {
                    Section { Text(err).foregroundColor(.red) }
                }
                Section {
                    Button {
                        save()
                    } label: {
                        if isSaving { ProgressView() }
                        else         { Text("Save") }
                    }
                    .disabled(name.isEmpty || selectedGroups.isEmpty || isSaving)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        isSaving = true
        vm.createCustomExercise(name: name,
                                muscleGroups: Array(selectedGroups)) { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let err):
                errorText = err.localizedDescription
            }
        }
    }
}
