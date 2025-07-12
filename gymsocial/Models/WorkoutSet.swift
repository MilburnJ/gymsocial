//
//  WorkoutSet.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/26/25.
//


import Foundation

/// A single set within an exercise
struct WorkoutSet: Identifiable, Codable {
    let id = UUID()
    var reps: Int
    var weight: Double
}
