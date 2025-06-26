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
    
    @StateObject private var session = SessionViewModel()
    var body: some Scene {
        WindowGroup {
            Group{
                if session.currentUser == nil {
                    LoginView()
                } else {
                    MainTabView()
                      .environmentObject(session)
                }
            }
        }
    }
}
