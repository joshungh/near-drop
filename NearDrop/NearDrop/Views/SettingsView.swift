import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var peerService: PeerService

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SYSTEM")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textTertiary)
                                .tracking(2)

                            Text("Configuration")
                                .font(Theme.Typography.title2)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.lg)

                    // Device Section
                    VStack(spacing: Theme.Spacing.md) {
                        SectionHeader(title: "DEVICE INFO")

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "iphone",
                                iconColor: Theme.Colors.secondary,
                                title: "Device Name",
                                value: UIDevice.current.name
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            HStack(spacing: Theme.Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.success.opacity(0.2))
                                        .frame(width: 40, height: 40)

                                    Image(systemName: "wifi.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Theme.Colors.success)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Connection Status")
                                        .font(Theme.Typography.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    ModernStatusBadge(state: peerService.connectionState)
                                }

                                Spacer()
                            }
                            .padding(Theme.Spacing.md)
                        }
                        .cardStyle()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Connected Peers Section
                    VStack(spacing: Theme.Spacing.md) {
                        SectionHeader(title: "ACTIVE CONNECTIONS")

                        VStack(spacing: Theme.Spacing.sm) {
                            if peerService.connectedPeers.isEmpty {
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                        .foregroundColor(Theme.Colors.textTertiary)

                                    Text("No active connections")
                                        .font(Theme.Typography.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Spacer()
                                }
                                .padding(Theme.Spacing.md)
                                .cardStyle()
                            } else {
                                ForEach(peerService.connectedPeers, id: \.self) { peer in
                                    HStack(spacing: Theme.Spacing.md) {
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

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(peer.displayName)
                                                .font(Theme.Typography.headline)
                                                .foregroundColor(Theme.Colors.textPrimary)

                                            HStack(spacing: 4) {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 10))
                                                Text("Encrypted")
                                                    .font(Theme.Typography.caption2)
                                            }
                                            .foregroundColor(Theme.Colors.success)
                                        }

                                        Spacer()
                                    }
                                    .padding(Theme.Spacing.md)
                                    .cardStyle()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Security Section
                    VStack(spacing: Theme.Spacing.md) {
                        SectionHeader(title: "SECURITY")

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "lock.shield.fill",
                                iconColor: Theme.Colors.success,
                                title: "Encryption",
                                value: "AES-GCM 256-bit"
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "key.fill",
                                iconColor: Theme.Colors.primary,
                                title: "Key Exchange",
                                value: "X25519 ECDH"
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "signature",
                                iconColor: Theme.Colors.secondary,
                                title: "Signing",
                                value: "Ed25519"
                            )
                        }
                        .cardStyle()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Privacy Section
                    VStack(spacing: Theme.Spacing.md) {
                        SectionHeader(title: "PRIVACY")

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "externaldrive.fill",
                                iconColor: Theme.Colors.warning,
                                title: "Data Storage",
                                value: "Local Only"
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "chart.bar.fill",
                                iconColor: Theme.Colors.danger,
                                title: "Analytics",
                                value: "Disabled"
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "server.rack",
                                iconColor: Theme.Colors.primary,
                                title: "Servers",
                                value: "None"
                            )
                        }
                        .cardStyle()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // About Section
                    VStack(spacing: Theme.Spacing.md) {
                        SectionHeader(title: "ABOUT")

                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "info.circle.fill",
                                iconColor: Theme.Colors.secondary,
                                title: "Version",
                                value: "1.0.0 (PoC)"
                            )

                            Divider()
                                .background(Theme.Colors.textTertiary.opacity(0.2))
                                .padding(.leading, 60)

                            SettingsRow(
                                icon: "hammer.fill",
                                iconColor: Theme.Colors.primary,
                                title: "Build",
                                value: "Prototype"
                            )
                        }
                        .cardStyle()
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Disconnect Button
                    if !peerService.connectedPeers.isEmpty {
                        Button(action: {
                            peerService.disconnect()
                        }) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "xmark.circle.fill")
                                Text("DISCONNECT ALL")
                                    .font(Theme.Typography.headline)
                                    .tracking(1)
                            }
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(Theme.Colors.danger)
                            .cornerRadius(Theme.CornerRadius.md)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }

                    Spacer(minLength: Theme.Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(2)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.sm)
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Text(value)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
    }
}

struct ModernStatusBadge: View {
    let state: ConnectionState

    var statusText: String {
        switch state {
        case .disconnected:
            return "OFFLINE"
        case .discovering:
            return "SCANNING"
        case .connecting:
            return "CONNECTING"
        case .connected:
            return "ONLINE"
        }
    }

    var statusColor: Color {
        switch state {
        case .disconnected:
            return Theme.Colors.textTertiary
        case .discovering:
            return Theme.Colors.warning
        case .connecting:
            return Theme.Colors.secondary
        case .connected:
            return Theme.Colors.success
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(Theme.Typography.caption2)
                .foregroundColor(statusColor)
                .tracking(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.15))
        .cornerRadius(Theme.CornerRadius.full)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PeerService())
}
