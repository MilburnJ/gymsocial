// ExerciseLoggingView.swift
import SwiftUI

// Allow Int to be used with .sheet(item:)
extension Int: Identifiable {
    public var id: Int { self }
}

struct ExerciseLoggingView: View {
    @EnvironmentObject var workoutVM: WorkoutSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var log: ExerciseLog
    private let index: Int?

    @State private var currentReps: Int
    @State private var currentWeight: Double

    // Which set (if any) is being edited
    @State private var editingSetIndex: Int?

    init(log: ExerciseLog, index: Int?) {
        self.index = index
        _log = State(initialValue: log)
        let last = log.sets.last ?? WorkoutSet(reps: 5, weight: 135)
        _currentReps = State(initialValue: last.reps)
        _currentWeight = State(initialValue: last.weight)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text(log.name)
                    .font(.title2).bold()
                    .padding(.top)

                // — Past Sets (discrete rows) —
                if !log.sets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past Sets").font(.headline)
                        ForEach(log.sets.indices, id: \.self) { idx in
                            HStack {
                                Text("Set \(idx+1): \(log.sets[idx].reps)x"
                                     + String(format: "%.1f", log.sets[idx].weight))
                                Spacer()
                                Button("Edit") {
                                    editingSetIndex = idx
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }

                Divider().padding(.vertical)

                // — Next-Set Controls —
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
                        // default controls to the new last set
                        currentReps   = newSet.reps
                        currentWeight = newSet.weight
                    }
                    .disabled(currentReps < 1)

                    Spacer()

                    Button("Done") {
                        if let i = index {
                            workoutVM.draft.exercises[i] = log
                        } else {
                            workoutVM.addCompletedExercise(log)
                        }
                        // pop back two levels
                        dismiss()
                        DispatchQueue.main.async { dismiss() }
                    }
                    .disabled(log.sets.isEmpty)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Log \(log.name)")
        // — Edit sheet for a single set —
        .sheet(item: $editingSetIndex) { idx in
            EditSetView(
                reps: Binding(
                    get: { log.sets[idx].reps },
                    set: { log.sets[idx].reps = $0 }
                ),
                weight: Binding(
                    get: { log.sets[idx].weight },
                    set: { log.sets[idx].weight = $0 }
                )
            )
        }
    }
}

/// A small sheet to edit one set’s reps & weight
struct EditSetView: View {
    @Binding var reps: Int
    @Binding var weight: Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Reps") {
                    Stepper("\(reps) reps", value: $reps, in: 1...50)
                }
                Section("Weight") {
                    WeightSlider(weight: $weight)
                }
            }
            .navigationTitle("Edit Set")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
