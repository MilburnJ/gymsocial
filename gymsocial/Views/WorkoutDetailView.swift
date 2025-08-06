// Views/WorkoutDetailView.swift

import SwiftUI

struct WorkoutDetailView: View {
    let post: Post

    // Formatted duration
    private var durationText: String {
        guard let end = post.workout.endTime.timeIntervalSinceReferenceDate > post.workout.startTime.timeIntervalSinceReferenceDate
              ? post.workout.endTime.timeIntervalSince(post.workout.startTime)
              : nil
        else { return "--:--:--" }
        return Duration
            .seconds(end)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    // Formatted date
    private var dateText: String {
        post.workout.startTime.formatted(
            .dateTime.month().day().year().hour().minute()
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(post.title)
                    .font(.title2).bold()

                // Description
                if let desc = post.description, !desc.isEmpty {
                    Text(desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Date & duration
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Duration: \(durationText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Exercises & sets
                ForEach(post.workout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.headline)

                        ForEach(exercise.sets.indices, id: \.self) { idx in
                            let set = exercise.sets[idx]
                            HStack {
                                Text("Set \(idx+1):")
                                Spacer()
                                Text("\(set.reps) reps  •  \(set.weight, specifier: "%.1f") lb")
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*
#if DEBUG
struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailView(post:
                Post(
                    id: "1",
                    authorID: "u1",
                    authorName: "Jane",
                    timestamp: Date(),
                    likes: 0,
                    title: "Leg Day Blast",
                    description: "Felt strong today, nailed my squat PR!",
                    workout: WorkoutPayload(
                        startTime: Date().addingTimeInterval(-3600),
                        endTime: Date(),
                        exercises: [
                            ExerciseLog(name: "Squat", sets: [
                                WorkoutSet(reps: 5, weight: 200),
                                WorkoutSet(reps: 5, weight: 205)
                            ], muscleGroups: ["quads"]),
                            ExerciseLog(name: "Leg Press", sets: [
                                WorkoutSet(reps: 10, weight: 300)
                            ],muscleGroups: ["quads"])
                        ]
                    )
                )
            )
        }
    }
}
#endif
*/
