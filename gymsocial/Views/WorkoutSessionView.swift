import SwiftUI

struct WorkoutSessionView: View {
    @StateObject private var vm = WorkoutSessionViewModel()
    @EnvironmentObject var session: SessionViewModel

    @State private var sessionActive = false
    @State private var showingAdd = false
    @State private var globalSearch = ""
    @State private var showEndAlert = false
    @State private var navigateToConfirm = false

    // Combine built-in + custom for global search
    private var globalFilteredExercises: [String] {
        let builtIn = Exercise.all.map(\.name)
            .filter { globalSearch.isEmpty || $0.localizedCaseInsensitiveContains(globalSearch) }
        let custom = vm.customExercises.map(\.name)
            .filter { globalSearch.isEmpty || $0.localizedCaseInsensitiveContains(globalSearch) }
        return (builtIn + custom).sorted()
    }

    private var elapsedText: String {
        Duration.seconds(vm.elapsed)
          .formatted(.time(pattern: .hourMinuteSecond))
    }

    var body: some View {
        VStack(spacing: 16) {
            if !sessionActive {
                Spacer()
                Button("Start Workout") {
                    vm.startSession()
                    sessionActive = true
                }
                .font(.title2)
                .buttonStyle(.borderedProminent)
                .padding()
                Spacer()
            } else {
                Text(elapsedText)
                    .font(.largeTitle).bold()
                    .padding(.top)

                // Muscle-group carousel
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

                // Add custom
                HStack {
                    Spacer()
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingAdd) {
                        AddCustomExerciseView()
                            .environmentObject(vm)
                    }
                    .padding(.trailing)
                }

                // Global search
                TextField("Search all exercises…", text: $globalSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if !globalSearch.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(globalFilteredExercises, id: \.self) { name in
                                NavigationLink {
                                    ExerciseLoggingView(
                                        log: ExerciseLog(name: name, sets: []),
                                        index: nil
                                    )
                                    .environmentObject(vm)
                                } label: {
                                    Text(name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(8)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    globalSearch = ""
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                } else {
                    // Completed exercises
                    if vm.draft.exercises.isEmpty {
                        Text("No exercises logged yet")
                            .foregroundColor(.secondary)
                            .italic()
                            .padding()
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
                }

                Spacer()

                Button("Finish Workout") {
                    showEndAlert = true
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .padding()
                .alert("End workout?", isPresented: $showEndAlert) {
                    Button("Not yet", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        vm.pauseSession()
                        navigateToConfirm = true
                    }
                }

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
        .onChange(of: navigateToConfirm) { active in
            if !active {
                sessionActive = false
            }
        }
    }
}

private struct CompletedExerciseRow: View {
    let log: ExerciseLog

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.name).font(.headline)
                Text(log.sets.map { "\($0.reps)x\($0.weight)" }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}
