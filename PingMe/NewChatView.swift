//
//  NewChatView.swift
//  PingMe
//
//  Created by Harshit Agarwal on 28/10/24.

//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NewChatView: View {
    @Binding var isShowingNewChatView: Bool
    @State private var newChatEmail = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.colorScheme) var colorScheme

    // Add email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header image or icon
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 32)
                
                Text("Start a New Conversation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Email input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("example@email.com", text: $newChatEmail)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal)
                
                // Create chat button
                Button(action: createChat) {
                    HStack {
                        Image(systemName: "plus.message.fill")
                        Text("Create Chat")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: { isShowingNewChatView = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
            )
        }
    }

    private func createChat() {
        // Trim whitespace
        let trimmedEmail = newChatEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate empty email
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter an email address"
            showError = true
            return
        }
        
        // Validate email format
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        // Prevent creating chat with own email
        guard trimmedEmail.lowercased() != currentUserEmail.lowercased() else {
            errorMessage = "You cannot create a chat with yourself"
            showError = true
            return
        }
        
        let db = Firestore.firestore()
        let chatID = getConversationID(for: currentUserEmail, and: trimmedEmail)
        
        db.collection("chats").document(chatID).setData(["participants": [currentUserEmail, trimmedEmail]]) { error in
            if let error = error {
                errorMessage = "Error creating chat: \(error.localizedDescription)"
                showError = true
            } else {
                isShowingNewChatView = false
            }
        }
    }
}
