// Views/WorkoutConfirmView.swift

import SwiftUI

struct WorkoutConfirmView: View {
    @EnvironmentObject var vm: WorkoutSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var isPosting = false
    @State private var errorText: String?

    private var elapsedText: String {
        Duration
            .seconds(vm.elapsed)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    var body: some View {
        Form {
            Section(header: Text("Summary")) {
                Text("Time: \(elapsedText)")
                ForEach(vm.draft.exercises) { log in
                    Text("\(log.name): " +
                         log.sets.map { "\($0.reps)x\($0.weight)" }
                                 .joined(separator: ", "))
                        .font(.subheadline)
                }
            }

            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
            }

            if let error = errorText {
                Section { Text(error).foregroundColor(.red) }
            }

            Section {
                Button {
                    post()
                } label: {
                    if isPosting { ProgressView() }
                    else         { Text("Post Workout") }
                }
                .disabled(title.isEmpty || isPosting)
            }
        }
        .navigationTitle("Finish Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.pauseSession()
        }
    }

    private func post() {
        isPosting = true
        errorText = nil

        vm.publishWorkout(title: title, description: description) { result in
            DispatchQueue.main.async {
                isPosting = false
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .didFinishLoggingExercise, object: nil)
                    dismiss()  // back to “Start Workout” screen
                case .failure(let err):
                    errorText = err.localizedDescription
                }
            }
        }
    }
}

#if DEBUG
struct WorkoutConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutConfirmView()
                .environmentObject(WorkoutSessionViewModel())
        }
    }
}
#endif
