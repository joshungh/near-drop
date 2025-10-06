import SwiftUI
import MultipeerConnectivity

struct ChatsListView: View {
    @EnvironmentObject var peerService: PeerService
    @StateObject private var messageStore = MessageStore()

    var body: some View {
        NavigationView {
            Group {
                if peerService.connectedPeers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No Active Chats")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Connect to a nearby device to start chatting")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(peerService.connectedPeers, id: \.self) { peer in
                        NavigationLink(destination: ChatView(peer: peer, messageStore: messageStore)) {
                            ChatListRow(peerName: peer.displayName, messageStore: messageStore)
                        }
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct ChatListRow: View {
    let peerName: String
    @ObservedObject var messageStore: MessageStore

    var conversation: Conversation? {
        messageStore.getConversation(forPeer: peerName)
    }

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(peerName)
                    .fontWeight(.semibold)

                if let lastMessage = conversation?.lastMessage {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Start a conversation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let lastMessage = conversation?.lastMessage {
                Text(lastMessage.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatsListView()
        .environmentObject(PeerService())
}
