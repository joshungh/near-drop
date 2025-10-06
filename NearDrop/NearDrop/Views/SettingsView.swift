import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var peerService: PeerService

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Device")) {
                    HStack {
                        Text("Device Name")
                        Spacer()
                        Text(UIDevice.current.name)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Status")
                        Spacer()
                        ConnectionStatusBadge(state: peerService.connectionState)
                    }
                }

                Section(header: Text("Connected Peers")) {
                    if peerService.connectedPeers.isEmpty {
                        Text("No connected peers")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(peerService.connectedPeers, id: \.self) { peer in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text(peer.displayName)
                            }
                        }
                    }
                }

                Section(header: Text("Security")) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.green)
                        Text("End-to-End Encryption")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.blue)
                        Text("Safety Codes")
                        Spacer()
                        Text("Ed25519")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Privacy")) {
                    HStack {
                        Text("Data Storage")
                        Spacer()
                        Text("Local Only")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Analytics")
                        Spacer()
                        Text("Disabled")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("PoC")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive, action: disconnectAll) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Disconnect All")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func disconnectAll() {
        peerService.disconnect()
    }
}

struct ConnectionStatusBadge: View {
    let state: ConnectionState

    var statusText: String {
        switch state {
        case .disconnected:
            return "Disconnected"
        case .discovering:
            return "Discovering"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        }
    }

    var statusColor: Color {
        switch state {
        case .disconnected:
            return .secondary
        case .discovering:
            return .orange
        case .connecting:
            return .yellow
        case .connected:
            return .green
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .foregroundColor(statusColor)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PeerService())
}
