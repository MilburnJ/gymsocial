//
//  WorkoutDetailView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/26/25.
//


// Views/WorkoutDetailView.swift

import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutPayload

    // Compute human-readable duration
    private var durationText: String {
        guard let duration = workout.endTime.timeIntervalSinceReferenceDate > workout.startTime.timeIntervalSinceReferenceDate
                ? workout.endTime.timeIntervalSince(workout.startTime)
                : nil
        else { return "--:--:--" }
        return Duration
            .seconds(duration)
            .formatted(.time(pattern: .hourMinuteSecond))
    }

    // Format the date of the workout
    private var dateText: String {
        workout.startTime.formatted(.dateTime.month().day().year().hour().minute())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header: date & duration
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateText)
                        .font(.headline)
                    Text("Duration: \(durationText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Divider()

                // Exercises and their sets
                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.title3)
                            .bold()
                            .padding(.bottom, 4)

                        ForEach(exercise.sets.indices, id: \.self) { idx in
                            let set = exercise.sets[idx]
                            HStack {
                                Text("Set \(idx+1):")
                                    .font(.subheadline)
                                Spacer()
                                let weightString = String(format: "%.1f", set.weight)
                                Text("Set \(idx + 1): \(set.reps)x\(weightString) lb")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
            .padding(.top)
        }
        .navigationTitle("Workout Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailView(
                workout: WorkoutPayload(
                    startTime: Date().addingTimeInterval(-3600),
                    endTime:   Date(),
                    exercises: [
                        ExerciseLog(name: "Bench Press", sets: [
                            WorkoutSet(reps: 5, weight: 135),
                            WorkoutSet(reps: 5, weight: 140),
                            WorkoutSet(reps: 3, weight: 145)
                        ]),
                        ExerciseLog(name: "Squat", sets: [
                            WorkoutSet(reps: 5, weight: 225),
                            WorkoutSet(reps: 5, weight: 230)
                        ])
                    ]
                )
            )
        }
    }
}
#endif
