import SwiftUI
import MultipeerConnectivity

struct DiscoveryView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var isDiscovering = false

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Modern header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }

                    Spacer()

                    if isDiscovering {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)

                            Text("Scanning...")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.surfaceSecondary)
                        .cornerRadius(Theme.CornerRadius.full)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.sm)

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        if !isDiscovering {
                            // Onboarding state
                            VStack(spacing: Theme.Spacing.xl) {
                                Spacer()

                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.Colors.primary, Theme.Colors.secondary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)

                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                                .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 20, y: 10)

                                VStack(spacing: Theme.Spacing.sm) {
                                    Text("Find Nearby Devices")
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Text("Connect securely with people around you using end-to-end encryption")
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, Theme.Spacing.xl)
                                }

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xxl)
                        } else if peerService.discoveredPeers.isEmpty {
                            // Scanning empty state
                            VStack(spacing: Theme.Spacing.lg) {
                                Spacer()

                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding(.bottom, Theme.Spacing.lg)

                                Text("Looking for devices...")
                                    .font(Theme.Typography.title3)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Text("Make sure both devices have NearDrop open")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, Theme.Spacing.xl)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xxl)
                        } else {
                            // Devices list
                            VStack(spacing: Theme.Spacing.md) {
                                ForEach(peerService.discoveredPeers, id: \.self) { peer in
                                    ModernPeerRow(peer: peer)
                                }
                            }
                            .padding(.top, Theme.Spacing.md)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }

                // Action button
                VStack(spacing: 0) {
                    Divider()
                        .background(Theme.Colors.divider)

                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            if isDiscovering {
                                stopDiscovery()
                            } else {
                                startDiscovery()
                            }
                        }
                    }) {
                        Text(isDiscovering ? "Stop Scanning" : "Start Scanning")
                            .primaryButton(enabled: true)
                    }
                    .padding(Theme.Spacing.lg)
                }
                .background(Theme.Colors.surface)
            }
        }
        .navigationBarHidden(true)
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
                            colors: [Theme.Colors.primaryLight, Theme.Colors.secondaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Text(String(peer.displayName.prefix(1).uppercased()))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(peer.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(isConnected ? Theme.Colors.success : Theme.Colors.textTertiary)
                        .frame(width: 6, height: 6)

                    Text(isConnected ? "Connected" : "Available")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Spacer()

            // Action
            if !isConnected {
                Button(action: { peerService.invitePeer(peer) }) {
                    Text("Connect")
                        .font(Theme.Typography.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.CornerRadius.full)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
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
