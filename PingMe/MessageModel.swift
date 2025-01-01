//
//  MessageModel.swift
//  PingMe
//
//  Created by Harshit Agarwal on 28/10/24.
//

import Foundation
import FirebaseFirestore

// MARK: - Message Model
struct Message: Identifiable, Codable, Equatable {
    var id: String
    var text: String
    var email: String
    @ServerTimestamp var timestamp: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case email
        case timestamp
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.email == rhs.email
    }
}


// MARK: - Helper Function for Conversation ID
func getConversationID(for user1: String, and user2: String) -> String {
    return user1 < user2 ? "\(user1)_\(user2)" : "\(user2)_\(user1)"
}
