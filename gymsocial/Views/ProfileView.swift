// Views/ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var isSigningOut = false
    @State private var signOutError: String?

    var body: some View {
        VStack(spacing: 24) {
            if let user = session.currentUser {
                Text(user.displayName)
                    .font(.title2)
                    .bold()
                Text(user.email)
                    .foregroundColor(.secondary)
            } else {
                Text("Not signed in")
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                signOut()
            } label: {
                if isSigningOut {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
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
        .alert("Sign Out Failed", isPresented: Binding<Bool>(
            get: { signOutError != nil },
            set: { if !$0 { signOutError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(signOutError ?? "")
        }
    }

    private func signOut() {
        isSigningOut = true
        do {
            try AuthService.shared.signOut()
            // Your SessionViewModel should observe Auth state and handle navigation back to login
        } catch {
            signOutError = error.localizedDescription
        }
        isSigningOut = false
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(SessionViewModel())
        }
    }
}
#endif
