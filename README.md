# gymsocial

gymsocial is a social fitness app for iOS that lets users log workouts, track muscle group activity, and share progress with friends. Built with SwiftUI and Firebase, it combines workout logging with social features to create a motivating experience for lifters.

## Features

- Log sets, reps, and weight across custom or predefined exercises
- Track which muscle groups were hit per workout
- View a social feed of friends' workouts and progress
- Create and edit custom exercises
- Highlight active muscle groups in a visual diagram
- Register and authenticate users via Firebase Auth
- Upload profile pictures and workout images using Firebase Storage
- Persist and retrieve workouts using Firebase Firestore

## Architecture

The project follows a modular MVVM structure with the following components:
- Models/: Data models such as WorkoutSet, Exercise, MuscleGroup, Post, and User
- ViewModels/: State and logic for views, including WorkoutSessionViewModel, FeedViewModel, and ProfileViewModel
- Views/: SwiftUI views for logging, profile, social feed, and muscle diagram
- Services/: Firebase integrations for authentication and Firestore CRUD operations

## Tech Stack

- Swift 5
- SwiftUI
- Firebase Auth
- Firebase Firestore
- Firebase Storage
- Firebase Analytics


## Future Improvements

- Add follower/following system
- Integrate charts for performance trends
- Include workout challenges or streaks
- Notifications for likes and comments
- Group-based fitness challenges or leaderboards
