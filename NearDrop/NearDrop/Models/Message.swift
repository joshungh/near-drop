import Foundation

/// Represents a message in NearDrop
struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let sender: String
    let timestamp: Date
    let isEncrypted: Bool

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: timestamp)
    }
}

/// Represents a conversation with a peer
struct Conversation: Identifiable, Codable {
    let id: UUID
    let peerName: String
    var messages: [Message]
    let createdAt: Date
    var lastMessageAt: Date

    var lastMessage: Message? {
        messages.last
    }
}
