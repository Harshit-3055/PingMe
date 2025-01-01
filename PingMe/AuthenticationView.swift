//
//  AuthenticationView.swift
//  PingMe
//
//  Created by Harshit Agarwal on 05/10/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct AuthenticationView: View {
    @Binding var isUserLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var selectedTab = 0
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var isLoading = false

    init(isUserLoggedIn: Binding<Bool>) {
        print("AuthenticationView initialized")
        self._isUserLoggedIn = isUserLoggedIn
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    // Brand Logo and Title
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                        
                        Text("PingMe")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Connect instantly with anyone")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Auth Container
                    VStack(spacing: 25) {
                        CustomSegmentedControl(selectedIndex: $selectedTab)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            CustomTextField(text: $email, placeholder: "Email", isSecure: false, systemImage: "envelope")
                            CustomTextField(text: $password, placeholder: "Password", isSecure: true, systemImage: "lock")
                        }
                        .padding(.horizontal)
                        
                        Button(action: handleAction) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(selectedTab == 0 ? "Log In" : "Sign Up")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        .disabled(isLoading)
                    }
                    .padding(.vertical, 20)
                    
                    // Divider
                    HStack {
                        VStack { Divider() }
                        Text("OR")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        VStack { Divider() }
                    }
                    .padding(.horizontal)
                    
                    // Social Sign In
                    CustomGoogleSignInButton(action: handleGoogleSignIn)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarHidden(true)
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    private func handleAction() {
        // Prevent multiple taps while loading
        guard !isLoading else { return }
        
        isLoading = true
        if selectedTab == 0 {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false // Reset loading state after completion
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                showErrorAlert = true
                return
            }
            print("Login successful")
            isUserLoggedIn = true
            dismiss()
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false // Reset loading state after completion
            if let error = error {
                errorMessage = "Sign Up failed: \(error.localizedDescription)"
                showErrorAlert = true
                return
            }
            print("Account creation successful")
            isUserLoggedIn = true
            dismiss()
        }
    }
    
    private func handleGoogleSignIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                errorMessage = "Google Sign In failed: \(error.localizedDescription)"
                showErrorAlert = true
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("No user found or missing ID token")
                errorMessage = "Google Sign In failed: No user found or missing ID token"
                showErrorAlert = true
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    errorMessage = "Firebase sign-in error: \(error.localizedDescription)"
                    showErrorAlert = true
                    return
                }
                print("Google sign in successful")
                isUserLoggedIn = true
                dismiss()
            }
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selectedIndex: Int
    let options = ["Login", "Sign Up"]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemGray6))
                .frame(height: 46)
            
            HStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedIndex = index
                        }
                    }) {
                        Text(options[index])
                            .foregroundColor(selectedIndex == index ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                Group {
                                    if selectedIndex == index {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.accentColor)
                                            .matchedGeometryEffect(id: "SegmentedControlBackground", in: animation)
                                    }
                                }
                            )
                    }
                }
            }
            .frame(height: 46)
            .cornerRadius(23)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @Namespace private var animation
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool
    var systemImage: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct CustomGoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image("web_light_rd_na")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .foregroundColor(.primary)
    }
}
