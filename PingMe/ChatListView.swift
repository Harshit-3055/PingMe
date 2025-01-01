//
//  ChatListView.swift
//  PingMe
//
//  Created by Harshit Agarwal on 28/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

struct ChatListView: View {
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @State private var chats: [Chat] = []
    @State private var isShowingNewChatView = false
    @State private var showAuth = false
    @State private var isShowingProfile = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isUserLoggedIn {
                    List {
                        Section {
                            ForEach(chats) { chat in
                                NavigationLink(destination: ChatView(chat: chat, isUserLoggedIn: $isUserLoggedIn)) {
                                    HStack {
                                        // Avatar circle with initials
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text(chat.otherUserEmail.prefix(2).uppercased())
                                                    .foregroundColor(.blue)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chat.otherUserEmail)
                                                .font(.headline)
                                            Text("Tap to start chatting")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.leading, 8)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteChat(chat)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onAppear {
                        loadChats()
                    }
                    
                    .navigationBarTitle("Chats")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { isShowingProfile = true }) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(Auth.auth().currentUser?.email?.prefix(2).uppercased() ?? "")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    )
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isShowingNewChatView = true
                            }) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                    .sheet(isPresented: $isShowingNewChatView) {
                        NewChatView(isShowingNewChatView: $isShowingNewChatView)
                    }
                } else {
                    // Show authentication view if not logged in
                    AuthenticationView(isUserLoggedIn: $isUserLoggedIn)
                }
            }
        }
        .onAppear {
            // Check auth state when view appears
            if Auth.auth().currentUser == nil {
                isUserLoggedIn = false
                showAuth = true
            }
        }
        .sheet(isPresented: $isShowingProfile) {
            NavigationStack {
                VStack(spacing: 20) {
                    // Profile Avatar
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(Auth.auth().currentUser?.email?.prefix(2).uppercased() ?? "")
                                .font(.title)
                                .foregroundColor(.blue)
                        )
                        .padding(.top, 20)
                    
                    // Email
                    Text(Auth.auth().currentUser?.email ?? "")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
                            isUserLoggedIn = false
                            showAuth = true
                            isShowingProfile = false
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .navigationTitle("My Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isShowingProfile = false
                        }
                    }
                }
            }
        }
    }
    
    private func loadChats() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()
        
        db.collection("chats").whereField("participants", arrayContains: currentUserEmail).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching chats: \(error)")
                return
            }
            
            self.chats = snapshot?.documents.compactMap { document -> Chat? in
                let data = document.data()
                let id = document.documentID
                let participants = data["participants"] as? [String] ?? []
                let otherUserEmail = participants.first { $0 != currentUserEmail }
                return otherUserEmail != nil ? Chat(id: id, otherUserEmail: otherUserEmail!) : nil
            } ?? []
        }
    }
    
    private func deleteChat(_ chat: Chat) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()
        
        // Delete the chat document
        db.collection("chats").document(chat.id).delete { error in
            if let error = error {
                print("Error deleting chat: \(error)")
            }
        }
        
        // Also delete all messages in the chat
        db.collection("chats").document(chat.id).collection("messages").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching messages to delete: \(error)")
                return
            }
            
            let batch = db.batch()
            snapshot?.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting messages: \(error)")
                }
            }
        }
    }
}

struct Chat: Identifiable {
    var id: String
    var otherUserEmail: String
}




