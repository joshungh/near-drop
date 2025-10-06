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
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack(spacing: Theme.Spacing.md) {
                    // Back button (if needed in NavigationView context)

                    // Peer info
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.Colors.primary, Theme.Colors.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.black)
                    }
                    .glow(color: Theme.Colors.success, radius: 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(peer.displayName)
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(Theme.Colors.success)
                                .frame(width: 6, height: 6)

                            Text("ENCRYPTED")
                                .font(Theme.Typography.caption2)
                                .foregroundColor(Theme.Colors.success)
                                .tracking(1)
                        }
                    }

                    Spacer()

                    // Safety code button
                    Button(action: { showSafetyCode.toggle() }) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.Colors.primary)
                            .glow(color: Theme.Colors.primary, radius: 4)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)

                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(messages) { message in
                                ModernMessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.sender != peer.displayName
                                )
                                .id(message.id)
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                    .onChange(of: messages.count) {
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input Bar
                HStack(spacing: Theme.Spacing.md) {
                    // Text field
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.primary)

                        TextField("Encrypted message...", text: $messageText)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .onSubmit(sendMessage)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.lg)

                    // Send button
                    Button(action: sendMessage) {
                        ZStack {
                            Circle()
                                .fill(messageText.isEmpty ? Theme.Colors.surface : Theme.Colors.primary)
                                .frame(width: 44, height: 44)

                            Image(systemName: "arrow.up")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(messageText.isEmpty ? Theme.Colors.textTertiary : Color.black)
                        }
                        .glow(
                            color: messageText.isEmpty ? .clear : Theme.Colors.primary,
                            radius: 8
                        )
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.background)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSafetyCode) {
            ModernSafetyCodeView(peerService: peerService, peer: peer)
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

struct ModernMessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
                // Message content
                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(isFromCurrentUser ? Color.black : Theme.Colors.textPrimary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm + 2)
                    .background(
                        isFromCurrentUser ?
                        AnyView(Theme.Colors.messageSent) :
                        AnyView(Theme.Colors.messageReceived)
                    )
                    .cornerRadius(Theme.CornerRadius.md)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)

                // Metadata
                HStack(spacing: 6) {
                    if message.isEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Theme.Colors.success)
                    }

                    Text(message.formattedTimestamp)
                        .font(Theme.Typography.caption2)
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(.horizontal, 4)
            }

            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}

struct ModernSafetyCodeView: View {
    @ObservedObject var peerService: PeerService
    let peer: MCPeerID
    @Environment(\.dismiss) var dismiss

    var safetyCode: String {
        peerService.getSafetyCode(for: peer) ?? "N/A"
    }

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                // Header
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.lg)

                Spacer()

                VStack(spacing: Theme.Spacing.xl) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.success.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.success)
                            .glow(color: Theme.Colors.success, radius: 20)
                    }

                    VStack(spacing: Theme.Spacing.sm) {
                        Text("SAFETY CODE")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textTertiary)
                            .tracking(3)

                        Text("Verify Connection")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }

                    Text("Compare this code with \(peer.displayName) to ensure your connection is secure and encrypted.")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Safety code
                    VStack(spacing: Theme.Spacing.sm) {
                        Text(safetyCode)
                            .font(Theme.Typography.monoLarge)
                            .foregroundColor(Theme.Colors.primary)
                            .tracking(4)
                            .padding(Theme.Spacing.lg)
                            .background(Theme.Colors.surface)
                            .cornerRadius(Theme.CornerRadius.md)
                            .glow(color: Theme.Colors.primary, radius: 8)

                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.Colors.success)

                            Text("End-to-end encrypted")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.success)
                        }
                    }
                }

                Spacer()

                // Info
                VStack(spacing: Theme.Spacing.sm) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Theme.Colors.secondary)

                        Text("Codes must match on both devices")
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
    }
}

#Preview {
    ChatView(messageStore: MessageStore(), peer: MCPeerID(displayName: "Test Device"))
        .environmentObject(PeerService())
}
