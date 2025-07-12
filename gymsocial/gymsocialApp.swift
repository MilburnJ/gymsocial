//
//  gymsocialApp.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/4/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@main
struct gymsocialApp: App {
    
    init() {
        FirebaseApp.configure()
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
        // 1) One single SessionViewModel for the entire app
        @StateObject private var session = SessionViewModel()

        var body: some Scene {
            WindowGroup {
                // 2) Switch between LoginView and MainTabView based on currentUser
                Group {
                    if session.currentUser == nil {
                        LoginView()
                    } else {
                        MainTabView()
                    }
                }
                // 3) Inject session into every child, including LoginView!
                .environmentObject(session)
            }
        }
    }
