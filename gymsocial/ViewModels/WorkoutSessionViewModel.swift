import Foundation
import Combine
import FirebaseAuth

final class WorkoutSessionViewModel: ObservableObject {
    @Published var draft: DraftWorkout
    @Published private(set) var elapsed: TimeInterval = 0

    private var timerCancellable: AnyCancellable?

    init() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        draft = DraftWorkout(
            userId: uid,
            startTime: Date(),
            endTime: nil,
            exercises: []
        )
        startTimer()
    }

    deinit { timerCancellable?.cancel() }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
          .autoconnect()
          .sink { [weak self] now in
            guard let self = self else { return }
            self.elapsed = now.timeIntervalSince(self.draft.startTime)
        }
    }

    /// Called when user finishes logging one exercise
    func addCompletedExercise(_ log: ExerciseLog) {
        draft.exercises.append(log)
    }

    /// Post the full workout to Firestore
    func finishAndPost(completion: @escaping (Result<Void, Error>) -> Void) {
        draft.endTime = Date()
        DatabaseService.shared.createWorkoutPost(draft: draft) { result in
            completion(result)
        }
    }
}
