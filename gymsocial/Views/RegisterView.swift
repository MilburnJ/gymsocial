//
//  RegisterView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/5/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMsg = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account").font(.largeTitle).bold()
            
            TextField("Display Name", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMsg.isEmpty {
                Text(errorMsg)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                createAccount()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty || displayName.isEmpty)
            .padding(10)
            
            Spacer()
        }
        .padding()
    }
    
    private func createAccount() {
        isLoading = true
        errorMsg = ""
        AuthService.shared.signUp(email: email, password: password, displayName: displayName) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    //Dismiss back to login view. SessionViewModel will catch this
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMsg = "Sign up failed: \(error)"
                }
            }
        }
    }
}
