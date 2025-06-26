//
//  LoginView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMsg = ""
    @EnvironmentObject var session: SessionViewModel
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                Text("Login").font(.largeTitle).bold()
                
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
                    loginUser()
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.top, 10)
                
                NavigationLink("Create an Account", destination: RegisterView())
                    .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func loginUser(){
        isLoading = true
        errorMsg = ""
        AuthService.shared.login(email: email, password: password) {result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let user):
                    //SessionViewModel listener will catch this change and switch screens
                    print("Logged in as \(user.displayName)")
                case .failure(let error):
                    errorMsg = "Login failed \(error)"
                }
            }
        }
    }
}
