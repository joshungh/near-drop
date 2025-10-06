import SwiftUI
import MultipeerConnectivity

struct ChatsListView: View {
    @EnvironmentObject var peerService: PeerService
    @StateObject private var messageStore = MessageStore()

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MESSAGES")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textTertiary)
                            .tracking(2)

                        Text("Encrypted Channels")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }

                    Spacer()

                    // Connection count badge
                    if !peerService.connectedPeers.isEmpty {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.Colors.success)
                                .frame(width: 8, height: 8)

                            Text("\(peerService.connectedPeers.count)")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.success)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.success.opacity(0.15))
                        .cornerRadius(Theme.CornerRadius.full)
                    }
                }
                .padding(Theme.Spacing.lg)

                if peerService.connectedPeers.isEmpty {
                    // Empty state
                    VStack(spacing: Theme.Spacing.xl) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Theme.Colors.surface)
                                .frame(width: 120, height: 120)

                            Image(systemName: "message.badge.filled.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Theme.Colors.textTertiary)
                        }

                        VStack(spacing: Theme.Spacing.sm) {
                            Text("No Active Channels")
                                .font(Theme.Typography.title2)
                                .foregroundColor(Theme.Colors.textPrimary)

                            Text("Connect to nearby devices to start encrypted messaging")
                                .font(Theme.Typography.callout)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Theme.Spacing.xl)
                        }

                        Spacer()
                    }
                } else {
                    // Chats list
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            ForEach(peerService.connectedPeers, id: \.self) { peer in
                                NavigationLink(destination: ChatView(messageStore: messageStore, peer: peer)) {
                                    ModernChatListRow(peerName: peer.displayName, messageStore: messageStore)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ModernChatListRow: View {
    let peerName: String
    @ObservedObject var messageStore: MessageStore

    var conversation: Conversation? {
        messageStore.getConversation(forPeer: peerName)
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.primary, Theme.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color.black)
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: Theme.Spacing.sm) {
                    Text(peerName)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.Colors.success)
                }

                if let lastMessage = conversation?.lastMessage {
                    Text(lastMessage.text)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                } else {
                    Text("New encrypted channel")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textTertiary)
                        .italic()
                }
            }

            Spacer()

            // Metadata
            VStack(alignment: .trailing, spacing: 6) {
                if let lastMessage = conversation?.lastMessage {
                    Text(lastMessage.formattedTimestamp)
                        .font(Theme.Typography.caption2)
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    ChatsListView()
        .environmentObject(PeerService())
}
