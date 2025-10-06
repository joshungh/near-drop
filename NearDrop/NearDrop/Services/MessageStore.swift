import Foundation
import Combine

/// Manages message persistence and conversation state
class MessageStore: ObservableObject {

    @Published var conversations: [Conversation] = []

    private let conversationsKey = "neardrop.conversations"
    private let userDefaults = UserDefaults.standard

    init() {
        loadConversations()
    }

    // MARK: - Public Methods

    /// Add a message to a conversation with a peer
    func addMessage(_ message: Message, forPeer peerName: String) {
        if let index = conversations.firstIndex(where: { $0.peerName == peerName }) {
            // Existing conversation
            conversations[index].messages.append(message)
            conversations[index].lastMessageAt = message.timestamp
        } else {
            // New conversation
            let conversation = Conversation(
                id: UUID(),
                peerName: peerName,
                messages: [message],
                createdAt: Date(),
                lastMessageAt: message.timestamp
            )
            conversations.append(conversation)
        }

        saveConversations()
    }

    /// Get conversation with a specific peer
    func getConversation(forPeer peerName: String) -> Conversation? {
        conversations.first { $0.peerName == peerName }
    }

    /// Delete a conversation
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        saveConversations()
    }

    /// Clear all conversations
    func clearAll() {
        conversations.removeAll()
        saveConversations()
    }

    // MARK: - Persistence

    private func saveConversations() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(conversations)
            userDefaults.set(data, forKey: conversationsKey)
        } catch {
            print("❌ Failed to save conversations: \(error)")
        }
    }

    private func loadConversations() {
        guard let data = userDefaults.data(forKey: conversationsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            conversations = try decoder.decode([Conversation].self, from: data)
        } catch {
            print("❌ Failed to load conversations: \(error)")
        }
    }
}
