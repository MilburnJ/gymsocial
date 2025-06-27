import Foundation
import FirebaseAuth

final class WorkoutSessionViewModel: ObservableObject {
    @Published var draft: DraftWorkout
    @Published var elapsed: TimeInterval = 0

    private var timer: Timer?

    init() {
        // 1) Fully initialize 'draft' before using self
        let uid = Auth.auth().currentUser?.uid ?? ""
        let initialDraft = DraftWorkout(
            userId: uid,
            startTime: Date(),
            endTime: nil,
            exercises: []
        )
        self.draft = initialDraft

        // 2) Now it's safe to start the timer
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    private func startTimer() {
        // schedule a repeating timer that updates 'elapsed'
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsed = Date().timeIntervalSince(self.draft.startTime)
        }
    }

    func finishAndPost(completion: @escaping (Result<Void, Error>) -> Void) {
        draft.endTime = Date()
        DatabaseService.shared.createWorkoutPost(draft: draft) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // reset for the next session
                    let uid = Auth.auth().currentUser?.uid ?? ""
                    self.draft = DraftWorkout(
                        userId: uid,
                        startTime: Date(),
                        endTime: nil,
                        exercises: []
                    )
                    self.elapsed = 0
                    self.startTimer()
                    completion(.success(()))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
        }
    }

    func addCompletedExercise(_ log: ExerciseLog) {
        draft.exercises.append(log)
    }
}
