import SwiftUI
import MultipeerConnectivity

struct ChatView: View {
    @EnvironmentObject var peerService: PeerService
    @ObservedObject var messageStore: MessageStore

    let peer: MCPeerID

    @State private var messageText = ""
    @State private var showSafetyCode = false

    private var messages: [Message] {
        messageStore.getConversation(forPeer: peer.displayName)?.messages ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, isFromCurrentUser: message.sender != peer.displayName)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input Bar
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit(sendMessage)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .secondary : .accentColor)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(peer.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSafetyCode.toggle() }) {
                    Image(systemName: "checkmark.shield")
                }
            }
        }
        .sheet(isPresented: $showSafetyCode) {
            SafetyCodeView(peerService: peerService, peer: peer)
        }
        .onReceive(peerService.$receivedMessages) { receivedMessages in
            // Add received messages to store
            for message in receivedMessages where message.sender == peer.displayName {
                if !(messageStore.getConversation(forPeer: peer.displayName)?.messages.contains(message) ?? false) {
                    messageStore.addMessage(message, forPeer: peer.displayName)
                }
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        do {
            try peerService.sendMessage(messageText, to: peer)

            // Add to local store
            let message = Message(
                id: UUID(),
                text: messageText,
                sender: UIDevice.current.name,
                timestamp: Date(),
                isEncrypted: true
            )
            messageStore.addMessage(message, forPeer: peer.displayName)

            messageText = ""
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isFromCurrentUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(18)

                HStack(spacing: 4) {
                    if message.isEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                    }
                    Text(message.formattedTimestamp)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

struct SafetyCodeView: View {
    @ObservedObject var peerService: PeerService
    let peer: MCPeerID
    @Environment(\.dismiss) var dismiss

    var safetyCode: String {
        peerService.getSafetyCode(for: peer) ?? "N/A"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Safety Code")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Compare this code with \(peer.displayName) to verify your connection is secure.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Text(safetyCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                Text("If the codes match, your connection is encrypted and secure.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Verify Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView(peer: MCPeerID(displayName: "Test Device"), messageStore: MessageStore())
        .environmentObject(PeerService())
}
