//
//  ProfileView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var isSigningOut = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let user = session.currentUser {
                    Text(user.displayName)
                        .font(.title2).bold()
                    Text(user.email)
                        .font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                Button(action: signOut) {
                    if isSigningOut {
                        ProgressView()
                    } else {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .disabled(isSigningOut)
            }
            .padding()
            .navigationTitle("Profile")
        }
    }

    private func signOut() {
        isSigningOut = true
        AuthService.shared.signOut { _ in
            isSigningOut = false
        }
    }
}
