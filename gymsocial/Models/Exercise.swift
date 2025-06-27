//
//  Exercise.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/26/25.
//


import Foundation

// Models/Exercise.swift

import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let muscleGroup: MuscleGroup

    // Sample data; in a real app you might fetch these
    static let all: [Exercise] = [
      .init(name: "Bench Press", muscleGroup: .chest),
      .init(name: "Push-Up",    muscleGroup: .chest),
      .init(name: "Pull-Up",    muscleGroup: .back),
      .init(name: "Deadlift",   muscleGroup: .back),
      .init(name: "Squat",      muscleGroup: .legs),
      .init(name: "Lunge",      muscleGroup: .legs),
      .init(name: "Shoulder Press", muscleGroup: .shoulders),
      .init(name: "Lateral Raise",   muscleGroup: .shoulders),
      .init(name: "Bicep Curl",      muscleGroup: .arms),
      .init(name: "Tricep Dip",      muscleGroup: .arms),
      .init(name: "Plank",           muscleGroup: .core),
      .init(name: "Sit-Up",          muscleGroup: .core)
    ]
}
