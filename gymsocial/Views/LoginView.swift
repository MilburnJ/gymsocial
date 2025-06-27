// Views/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var email       = ""
    @State private var password    = ""
    @State private var isLoading   = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Email field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                // Password field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                // Error message
                if let error = errorText {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Login button
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                // Register link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink("Register") {
                        RegisterView()
                    }
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    private func login() {
        isLoading = true
        errorText = nil

        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let user):
                    session.currentUser = user
                case .failure(let error):
                    switch error {
                    case .invalidCredentials:
                        errorText = "Invalid email or password."
                    default:
                        errorText = "An unexpected error occurred."
                    }
                }
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
                .environmentObject(SessionViewModel())
        }
    }
}
#endif
