//
//  ChatView.swift
//  PingMe
//
//  Created by Harshit Agarwal on 05/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    let chat: Chat
    @Binding var isUserLoggedIn: Bool
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    @State private var userEmail: String?
    @Environment(\.dismiss) private var dismiss
    @Namespace private var bottomID
    @State private var scrollToBottom = false

    var conversationID: String {
        getConversationID(for: chat.otherUserEmail, and: userEmail ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            if isUserLoggedIn {
                // Profile Header
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        // Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.accentColor)
                                .frame(width: 30, height: 30)
                        }
                        
                        // Avatar
                        Circle()
                            .fill(Color(UIColor.systemGray4))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(chat.otherUserEmail.prefix(1).uppercased())
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.otherUserEmail)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Active Now") // You can make this dynamic
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemBackground))
                    
                    Divider()
                }
                
                // Existing ScrollView with messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageView(message: message)
                                    .padding(.horizontal)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(bottomID)
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Message input area
                HStack(spacing: 12) {
                    TextField("Message", text: $newMessage)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    Button(action: {
                        sendMessage(to: conversationID)
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(newMessage.isEmpty ? Color.gray : Color.accentColor)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Divider(), alignment: .top
                )
            } else {
                Text("You are not logged in. Please sign in to join the chat.")
                    .padding()
            }
        }
        
        .onAppear {
            loadUserEmail()
            print("Current user email: \(userEmail ?? "nil")")
            print("Other user email: \(chat.otherUserEmail)")
            print("Conversation ID: \(conversationID)")
            loadMessages(for: conversationID)
        }
        
        .onChange(of: messages) { newMessages in
            print("Messages array updated:")
            newMessages.forEach { message in
                print("Message: \(message.text) from \(message.email)")
            }
        }
        
        .toolbar(.hidden, for: .navigationBar)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 && gesture.translation.height < 50 {
                        dismiss()
                    }
                }
        )
    }

    private func loadMessages(for conversationID: String) {
        guard !conversationID.isEmpty else {
            print("Error: Empty conversation ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("chats")
            .document(conversationID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("No snapshot received")
                    return
                }

                self.messages = snapshot.documents.compactMap { document in
                    let data = document.data()
                    guard let text = data["text"] as? String,
                          let email = data["email"] as? String else {
                        return nil
                    }

                    return Message(
                        id: document.documentID,
                        text: text,
                        email: email,
                        timestamp: data["timestamp"] as? Timestamp
                    )
                }
            }
    }

    private func sendMessage(to conversationID: String) {
        guard !conversationID.isEmpty else {
            print("Error: Empty conversation ID")
            return
        }
        
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Error: Empty message")
            return
        }
        
        guard let userEmail = userEmail else {
            print("Error: No user email available")
            return
        }
        
        print("Sending message: '\(newMessage)' to conversation: \(conversationID)")
        
        let db = Firestore.firestore()
        let messageData: [String: Any] = [
            "text": newMessage.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": userEmail,
            "timestamp": FieldValue.serverTimestamp()
        ]
        self.newMessage = ""
        db.collection("chats")
            .document(conversationID)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message sent successfully")
                }
            }
    }

    private func loadUserEmail() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No authenticated user")
            return
        }
        userEmail = currentUser.email
        print("Loaded user email: \(userEmail ?? "nil")")
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(bottomID, anchor: .bottom)
        }
    }
}

struct MessageView: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    
    var isCurrentUser: Bool {
        message.email == Auth.auth().currentUser?.email
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                Spacer()
            }
        }
    }
}
 