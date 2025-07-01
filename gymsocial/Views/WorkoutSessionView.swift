// Views/WorkoutSessionView.swift

import SwiftUI

struct WorkoutSessionView: View {
    @StateObject private var vm = WorkoutSessionViewModel()
    @EnvironmentObject var session: SessionViewModel

    @State private var showEndAlert = false
    @State private var navigateToConfirm = false

    private var elapsedText: String {
        Duration
            .seconds(vm.elapsed)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    var body: some View {
        VStack(spacing: 16) {
            if !vm.isSessionActive {
                Spacer()
                Button("Start Workout") {
                    vm.startSession()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .padding()
                Spacer()
            } else {
                // Timer
                Text(elapsedText)
                    .font(.largeTitle).bold()
                    .padding(.top)

                // Muscle‐group carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MuscleGroup.allCases) { group in
                            NavigationLink {
                                SelectExerciseView(muscleGroup: group)
                                    .environmentObject(vm)
                            } label: {
                                VStack {
                                    Image(systemName: group.sfSymbolName)
                                        .font(.title2)
                                    Text(group.displayName)
                                        .font(.caption)
                                }
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Completed exercises
                if vm.draft.exercises.isEmpty {
                    Text("No exercises logged yet")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.draft.exercises) { log in
                                CompletedExerciseRow(log: log)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }

                Spacer()

                // Finish Workout → confirmation alert
                Button("Finish Workout") {
                    showEndAlert = true
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .padding()
                .alert("End workout?", isPresented: $showEndAlert) {
                    Button("Not yet", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        // First navigate, then pause in confirm view
                        navigateToConfirm = true
                    }
                }

                // Hidden link fires while session still active
                NavigationLink(
                    destination:
                        WorkoutConfirmView()
                            .environmentObject(vm)
                            .navigationBarBackButtonHidden(true),
                    isActive: $navigateToConfirm
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationTitle("Workout")
    }
}

// CompletedExerciseRow unchanged
private struct CompletedExerciseRow: View {
    let log: ExerciseLog
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(log.name).font(.headline)
            Text(
                log.sets
                   .map { "\($0.reps)x\($0.weight)" }
                   .joined(separator: ", ")
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}
