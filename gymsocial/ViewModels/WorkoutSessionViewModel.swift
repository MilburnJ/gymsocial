import Foundation
import Combine
import FirebaseAuth

/// Manages a workout session: timer, exercise logs, and posting
final class WorkoutSessionViewModel: ObservableObject {
    @Published var draft: DraftWorkout
    @Published private(set) var elapsed: TimeInterval = 0

    private var timerCancellable: AnyCancellable?

    init() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        draft = DraftWorkout(userId: uid, startTime: Date(), endTime: nil, exercises: [])
        startTimer()
    }

    deinit {
        timerCancellable?.cancel()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self else { return }
                self.elapsed = now.timeIntervalSince(self.draft.startTime)
            }
    }

    /// Adds a new exercise with one default set
    func addExercise(named name: String) {
        let defaultSet = WorkoutSet(reps: 5, weight: 135)
        draft.exercises.append(ExerciseLog(name: name, sets: [defaultSet]))
    }

    /// Finishes the workout and posts it
    func finishAndPost(completion: @escaping (Result<Void, Error>) -> Void) {
        draft.endTime = Date()
        DatabaseService.shared.createWorkoutPost(draft: draft) { result in
            completion(result)
        }
    }
}
