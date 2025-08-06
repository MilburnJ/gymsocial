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
    let muscleGroups: [MuscleGroup]

    // Sample data; in a real app you might fetch these
    static let all: [Exercise] = [
      .init(name: "Bench Press", muscleGroups: [.chest]),
      .init(name: "Push-Up",    muscleGroups: [.chest]),
      .init(name: "Pull-Up",    muscleGroups: [.lats]),
      .init(name: "Deadlift",   muscleGroups: [.hamstrings]),
      .init(name: "Squat",      muscleGroups: [.quads]),
      .init(name: "Lunge",      muscleGroups: [.hamstrings]),
      .init(name: "Shoulder Press", muscleGroups: [.shoulders]),
      .init(name: "Lateral Raise",   muscleGroups: [.shoulders]),
      .init(name: "Bicep Curl",      muscleGroups: [.biceps]),
      .init(name: "Tricep Dip",      muscleGroups: [.triceps]),
      .init(name: "Plank",           muscleGroups: [.core]),
      .init(name: "Sit-Up",          muscleGroups: [.core])
    ]
}
