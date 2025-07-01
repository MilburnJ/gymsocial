//
//  CustomExercise.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/30/25.
//


import Foundation

struct CustomExercise: Identifiable, Codable {
    var id: String            // Firestore document ID
    var name: String
    var muscleGroups: [MuscleGroup]
}
