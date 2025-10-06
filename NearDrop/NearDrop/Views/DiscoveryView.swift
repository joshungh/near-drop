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
                // Compact header
                HStack {
                    Text("Discover")
                        .font(Theme.Typography.largeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Spacer()

                    if isDiscovering {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Scanning")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.surfaceSecondary)
                        .cornerRadius(Theme.CornerRadius.full)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, Theme.Spacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.Spacing.md) {
                        if !isDiscovering {
                            // Compact onboarding
                            VStack(spacing: Theme.Spacing.lg) {
                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [Theme.Colors.primary, Theme.Colors.primaryLight],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 80, height: 80)

                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                }

                                VStack(spacing: 6) {
                                    Text("Find Nearby Devices")
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Text("Connect securely with people around you")
                                        .font(Theme.Typography.callout)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xxl)
                        } else if peerService.discoveredPeers.isEmpty {
                            // Compact scanning state
                            VStack(spacing: Theme.Spacing.lg) {
                                Spacer()

                                ProgressView()
                                    .padding(.bottom, Theme.Spacing.md)

                                Text("Looking for devices...")
                                    .font(Theme.Typography.title2)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Text("Make sure both devices have NearDrop open")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xxl)
                            .padding(.horizontal, Theme.Spacing.xl)
                        } else {
                            // Devices list
                            ForEach(peerService.discoveredPeers, id: \.self) { peer in
                                PeerRow(peer: peer)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }

                // Compact bottom button
                VStack(spacing: 0) {
                    Divider()

                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isDiscovering.toggle()
                            isDiscovering ? peerService.startDiscovery() : peerService.stopDiscovery()
                        }
                    }) {
                        Text(isDiscovering ? "Stop" : "Start Scanning")
                            .primaryButton(enabled: true)
                    }
                    .padding(Theme.Spacing.lg)
                }
                .background(Theme.Colors.surface)
            }
        }
        .navigationBarHidden(true)
    }
}

struct PeerRow: View {
    @EnvironmentObject var peerService: PeerService
    let peer: MCPeerID

    var isConnected: Bool {
        peerService.connectedPeers.contains(peer)
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Compact avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Theme.Colors.primaryLight, Theme.Colors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)

                Text(String(peer.displayName.prefix(1).uppercased()))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Compact info
            VStack(alignment: .leading, spacing: 2) {
                Text(peer.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(isConnected ? Theme.Colors.success : Theme.Colors.textTertiary)
                        .frame(width: 5, height: 5)

                    Text(isConnected ? "Connected" : "Available")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Spacer()

            // Compact action
            if !isConnected {
                Button(action: { peerService.invitePeer(peer) }) {
                    Text("Connect")
                        .font(Theme.Typography.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.CornerRadius.full)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
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
