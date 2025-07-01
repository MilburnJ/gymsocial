import Foundation
import FirebaseAuth

final class WorkoutSessionViewModel: ObservableObject {
    @Published var draft: DraftWorkout = DraftWorkout(
        userId: "", startTime: Date(), endTime: nil, exercises: []
    )
    @Published var elapsed: TimeInterval = 0
    @Published var isSessionActive: Bool = false

    private var timer: Timer?

    /// Call when user taps “Start Workout”
    func startSession() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        draft = DraftWorkout(
            userId: uid,
            startTime: Date(),
            endTime: nil,
            exercises: []
        )
        elapsed = 0
        timer?.invalidate()
        isSessionActive = true
        startTimer()
    }

    /// Pause the timer and record endTime
    func pauseSession() {
        draft.endTime = Date()
        timer?.invalidate()
        // update elapsed one last time
        if let end = draft.endTime {
            elapsed = end.timeIntervalSince(draft.startTime)
        }
        isSessionActive = false
    }

    /// Reset everything back to initial “not started” state
    private func resetSession() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        draft = DraftWorkout(
            userId: uid,
            startTime: Date(),
            endTime: nil,
            exercises: []
        )
        elapsed = 0
        // leave isSessionActive = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsed = Date().timeIntervalSince(self.draft.startTime)
        }
    }

    deinit {
        timer?.invalidate()
    }

    func addCompletedExercise(_ log: ExerciseLog) {
        draft.exercises.append(log)
    }

    /// Called by the confirmation screen’s “Post Workout” button
    func publishWorkout(
        title: String,
        description: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // ensure endTime is set (in case pauseSession wasn’t called)
        if draft.endTime == nil {
            pauseSession()
        }

        DatabaseService.shared.createWorkoutPost(
            draft: draft,
            title: title,
            description: description
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // clear out this session so UI returns to “Start Workout”
                    self.resetSession()
                    completion(.success(()))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
        }
    }
}
