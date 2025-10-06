import SwiftUI
import MultipeerConnectivity

struct DiscoveryView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var isDiscovering = false

    var body: some View {
        ZStack {
            // Background
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DISCOVERY")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textTertiary)
                                .tracking(2)

                            Text("Secure Network Scan")
                                .font(Theme.Typography.title2)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }

                        Spacer()

                        // Status indicator
                        if isDiscovering {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Theme.Colors.success)
                                    .frame(width: 8, height: 8)
                                    .pulse()

                                Text("SCANNING")
                                    .font(Theme.Typography.caption2)
                                    .foregroundColor(Theme.Colors.success)
                                    .tracking(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.Colors.success.opacity(0.15))
                            .cornerRadius(Theme.CornerRadius.full)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)
                }

                if isDiscovering {
                    if peerService.discoveredPeers.isEmpty {
                        // Scanning state
                        VStack(spacing: Theme.Spacing.xl) {
                            Spacer()

                            ZStack {
                                // Radar rings
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 2)
                                        .frame(width: 200 + CGFloat(index * 40))
                                        .scaleEffect(isDiscovering ? 1.0 : 0.5)
                                        .opacity(isDiscovering ? 0.0 : 1.0)
                                        .animation(
                                            Animation.easeOut(duration: 2.0)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(index) * 0.4),
                                            value: isDiscovering
                                        )
                                }

                                // Center icon
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.Colors.primary)
                                    .glow(color: Theme.Colors.primary, radius: 20)
                            }

                            VStack(spacing: Theme.Spacing.sm) {
                                Text("Scanning for devices...")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Text("Looking for nearby encrypted nodes")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }

                            Spacer()
                        }
                    } else {
                        // Devices list
                        ScrollView {
                            VStack(spacing: Theme.Spacing.md) {
                                ForEach(peerService.discoveredPeers, id: \.self) { peer in
                                    ModernPeerRow(peer: peer)
                                }
                            }
                            .padding(Theme.Spacing.lg)
                        }
                    }
                } else {
                    // Initial state
                    VStack(spacing: Theme.Spacing.xl) {
                        Spacer()

                        VStack(spacing: Theme.Spacing.lg) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 80))
                                .foregroundColor(Theme.Colors.primary)
                                .glow(color: Theme.Colors.primary, radius: 15)

                            VStack(spacing: Theme.Spacing.sm) {
                                Text("Encrypted P2P Network")
                                    .font(Theme.Typography.title)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Text("Military-grade encryption • Zero trust architecture • No servers")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Theme.Spacing.xl)
                            }
                        }

                        Spacer()

                        // Start button
                        Button(action: startDiscovery) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 20))

                                Text("INITIATE SCAN")
                                    .font(Theme.Typography.headline)
                                    .tracking(1)
                            }
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(Theme.Colors.primary)
                            .cornerRadius(Theme.CornerRadius.md)
                            .glow(color: Theme.Colors.primary, radius: 10)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }

                // Stop button (when scanning)
                if isDiscovering {
                    Button(action: stopDiscovery) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "stop.circle.fill")
                            Text("TERMINATE SCAN")
                                .font(Theme.Typography.callout)
                                .tracking(1)
                        }
                        .foregroundColor(Theme.Colors.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.danger.opacity(0.15))
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
        }
    }

    private func startDiscovery() {
        withAnimation(.spring()) {
            isDiscovering = true
        }
        peerService.startDiscovery()
    }

    private func stopDiscovery() {
        withAnimation(.spring()) {
            isDiscovering = false
        }
        peerService.stopDiscovery()
    }
}

struct ModernPeerRow: View {
    @EnvironmentObject var peerService: PeerService
    let peer: MCPeerID

    var isConnected: Bool {
        peerService.connectedPeers.contains(peer)
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
            .glow(color: isConnected ? Theme.Colors.success : Theme.Colors.primary, radius: 8)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(peer.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(isConnected ? Theme.Colors.success : Theme.Colors.warning)
                        .frame(width: 6, height: 6)

                    Text(isConnected ? "CONNECTED" : "AVAILABLE")
                        .font(Theme.Typography.caption2)
                        .foregroundColor(isConnected ? Theme.Colors.success : Theme.Colors.warning)
                        .tracking(1)
                }
            }

            Spacer()

            // Action button
            if !isConnected {
                Button(action: { peerService.invitePeer(peer) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))

                        Text("CONNECT")
                            .font(Theme.Typography.caption)
                            .tracking(1)
                    }
                    .foregroundColor(Color.black)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            } else {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.Colors.success)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    DiscoveryView()
        .environmentObject(PeerService())
}
