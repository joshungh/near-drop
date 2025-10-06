import SwiftUI
import MultipeerConnectivity

struct DiscoveryView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var isDiscovering = false

    var body: some View {
        NavigationView {
            VStack {
                if isDiscovering {
                    if peerService.discoveredPeers.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Searching for nearby devices...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List(peerService.discoveredPeers, id: \.self) { peer in
                            PeerRow(peer: peer)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "wave.3.right.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)

                        Text("Discover Nearby Devices")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Start discovering to find devices nearby and send encrypted messages")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        Button(action: startDiscovery) {
                            Text("Start Discovery")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("Discover")
            .toolbar {
                if isDiscovering {
                    Button(action: stopDiscovery) {
                        Text("Stop")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private func startDiscovery() {
        isDiscovering = true
        peerService.startDiscovery()
    }

    private func stopDiscovery() {
        isDiscovering = false
        peerService.stopDiscovery()
    }
}

struct PeerRow: View {
    @EnvironmentObject var peerService: PeerService
    let peer: MCPeerID

    var isConnected: Bool {
        peerService.connectedPeers.contains(peer)
    }

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(peer.displayName)
                    .fontWeight(.medium)

                if isConnected {
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if !isConnected {
                Button(action: { peerService.invitePeer(peer) }) {
                    Text("Connect")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DiscoveryView()
        .environmentObject(PeerService())
}
